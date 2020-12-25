import Combine
import ComposableArchitecture
import MultipeerConnectivity

extension MultipeerConnectivity {
    public static let live: MultipeerConnectivity = {
        var client = MultipeerConnectivity()
        
        client.create = { id, displayName, serviceType, discoveryInfo in
            Effect.run { subscriber in
                let myPeerID = MCPeerID(displayName: displayName)
                
                let serviceBrowser = MCNearbyServiceBrowser(
                    peer: myPeerID,
                    serviceType: serviceType
                )
                
                var peerIdManager = PeerIDManager(myPeerId: myPeerID)
                
                let browserDelegate = NearbyServiceBrowserDelegate(subscriber, peerIdManager: peerIdManager)
                serviceBrowser.delegate = browserDelegate
        
                let advertiserService = MCNearbyServiceAdvertiser(peer: myPeerID, discoveryInfo: discoveryInfo, serviceType: serviceType)
                
                let session = MCSession(peer: myPeerID, securityIdentity: nil, encryptionPreference: .required)
                let sessionDelegate = SessionDelegate(subscriber: subscriber)
                session.delegate = sessionDelegate
                
                let advertiserDelegate = NearbyServiceAdvertiserDelegate(subscriber: subscriber, session: session)
                advertiserService.delegate = advertiserDelegate
                
                dependencies[id] = Dependencies(
                    browserdelegate: browserDelegate,
                    serviceBrowser: serviceBrowser,
                    advertiserdelegate: advertiserDelegate,
                    serviceAdvertiser: advertiserService,
                    subscriber: subscriber,
                    session: session,
                    sessionDelegate: sessionDelegate,
                    peerIdManager: peerIdManager
                )
                
                subscriber.send(.initialized)
                
                return AnyCancellable {
                    dependencies[id] = nil
                }
            }
        }
        
        client.destroy = { id in
            .fireAndForget {
                dependencies[id]?.subscriber.send(completion: .finished)
                dependencies[id] = nil
            }
        }
        
        client.startBrowsingForPeers = { id in
            .fireAndForget {
                dependencies[id]?.serviceBrowser.startBrowsingForPeers()
            }
        }
        
        client.stopBrowsingForPeers = { id in
            .fireAndForget {
                dependencies[id]?.serviceBrowser.stopBrowsingForPeers()
            }
        }
        
        client.startAdvertisingForPeers = { id in
            .fireAndForget {
                dependencies[id]?.serviceAdvertiser.startAdvertisingPeer()
            }
        }
        
        client.stopAdvertisingForPeers = { id in
            .fireAndForget {
                dependencies[id]?.serviceAdvertiser.stopAdvertisingPeer()
            }
        }
        
        client.invitePeer = { id, peerID, context, timeout in
            .fireAndForget {
                if let session = dependencies[id]?.session,
                   let peer = dependencies[id]?.peerIdManager.loadMCPeerID(for: peerID) {
                    dependencies[id]?.serviceBrowser.invitePeer(
                        peer,
                        to: session,
                        withContext: context,
                        timeout: timeout
                    )
                }
            }
        }
        
        client.invitationHandler = { id, accept in
            .fireAndForget {
                let session = dependencies[id]?.session
                dependencies[id]?.advertiserdelegate.acceptInvitation(accept, session: session)
            }
        }
        
        client.disconnectAllPeers = { id in
            .fireAndForget {
                guard let session = dependencies[id]?.session else {
                    return
                }
                
                session.connectedPeers.forEach { session.cancelConnectPeer($0) }
            }
        }
        
        client.send = { id, receiver, data in
            .fireAndForget {
                var peers: [MCPeerID] = []
                
                switch receiver {
                case .all:
                    peers = dependencies[id]?.session.connectedPeers ?? []
                case let.peers(selectedPeers):
                    peers = dependencies[id]?.peerIdManager.loadMCPeerIDs(for: selectedPeers) ?? []
                }
                
                do {
                    try dependencies[id]?.session.send(data, toPeers: peers, with: .unreliable)
                } catch {
                    dependencies[id]?.subscriber.send(.sendingError(.init(error)))
                }
            }
        }
        
        return client
    }()
}

private struct Dependencies {
    let browserdelegate: NearbyServiceBrowserDelegate
    let serviceBrowser: MCNearbyServiceBrowser
    
    let advertiserdelegate: NearbyServiceAdvertiserDelegate
    let serviceAdvertiser: MCNearbyServiceAdvertiser
    
    let subscriber: Effect<MultipeerConnectivity.Action, Never>.Subscriber
    let session: MCSession
    let sessionDelegate: SessionDelegate
    
    var peerIdManager: PeerIDManager
}

private var dependencies: [AnyHashable: Dependencies] = [:]

private class NearbyServiceBrowserDelegate: NSObject, MCNearbyServiceBrowserDelegate {
    
    private let subscriber: Effect<MultipeerConnectivity.Action, Never>.Subscriber
    private var peerIdManager: PeerIDManager
    
    init(_ subscriber: Effect<MultipeerConnectivity.Action, Never>.Subscriber, peerIdManager: PeerIDManager) {
        self.subscriber = subscriber
        self.peerIdManager = peerIdManager
      }
    
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        peerIdManager.add(peerID)
        subscriber.send(.foundPeer(.init(peerId: peerID), discoveryInfo: info))
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        peerIdManager.remove(peerID)
        subscriber.send(.lostPeer(.init(peerId: peerID)))
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: Error) {
        subscriber.send(.didNotStartBrowsingForPeers(.init(error)))
    }
}

private class NearbyServiceAdvertiserDelegate: NSObject, MCNearbyServiceAdvertiserDelegate {
    
    private var session: MCSession
    private let subscriber: Effect<MultipeerConnectivity.Action, Never>.Subscriber
    
    private let invitationHandlerSubject = PassthroughSubject<(Bool, MCSession?), Never>()
    private var cancellable: AnyCancellable?
    
    private var isConnecting: Bool = false
    private var invitationHandler: ((Bool, MCSession?) -> Void)?
        
    init(subscriber: Effect<MultipeerConnectivity.Action, Never>.Subscriber, session: MCSession) {
        self.subscriber = subscriber
        self.session = session
        super.init()
        
        cancellable = invitationHandlerSubject
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                let (accept, session) = $0
                self?.invitationHandler?(accept, session)
                self?.isConnecting = false
            }
    }
    
    // delegate values for the invitationHandler
    func acceptInvitation(_ accept: Bool, session: MCSession?) {
        invitationHandlerSubject.send((accept, session))
    }
    
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        print("advertiser_before_didReveiceInvitation")
        
        // automatically reject request if there are currently connecting an other peer
        guard !isConnecting else {
            invitationHandler(false, nil)
            return
        }
        
        isConnecting = true
        
        subscriber.send(.didReveiveInvitationFromPeer(.init(peerId: peerID), context: context))
        
        // store the invitationHandler and handle in the invitationHandlerSubject
        self.invitationHandler = invitationHandler
    }
    
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error) {
        subscriber.send(.didNotStartAdvertisingPeer(.init(error)))
    }
    
    deinit {
        cancellable?.cancel()
        cancellable = nil
        invitationHandler = nil
    }
}

private class SessionDelegate: NSObject, MCSessionDelegate {
    
    let subscriber: Effect<MultipeerConnectivity.Action, Never>.Subscriber
    
    init(subscriber: Effect<MultipeerConnectivity.Action, Never>.Subscriber) {
        self.subscriber = subscriber
    }
    
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        DispatchQueue.main.async { [weak self] in
            self?.subscriber.send(.didChangePeer(.init(peerId: peerID), state: state))
        }
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        subscriber.send(.didReceiveData(data, fromPeer: .init(peerId: peerID)))
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        subscriber.send(.didReceiveStream(stream, streamName: streamName, fromPeer: .init(peerId: peerID)))
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        subscriber.send(.didStartReveivingResourceWithName(resourceName, fromPeer: .init(peerId: peerID), progress: progress))
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        var localError: MultipeerConnectivity.Error?
        
        if let error = error {
            localError = .init(error)
        }
        
        subscriber.send(.didFinishReceivingResourceWithName(resourceName, fromPeer: .init(peerId: peerID), localURL: localURL, error: localError))
    }
    
    func session(_ session: MCSession, didReceiveCertificate certificate: [Any]?, fromPeer peerID: MCPeerID, certificateHandler: @escaping (Bool) -> Void) {
        certificateHandler(true)
    }
}
