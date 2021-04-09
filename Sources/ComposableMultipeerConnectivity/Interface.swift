import Foundation
import Combine
import ComposableArchitecture
import MultipeerConnectivity

public struct MultipeerConnectivity {
    
    public struct Error: Swift.Error, Equatable {
      public let error: NSError

      public init(_ error: Swift.Error) {
        self.error = error as NSError
      }
    }
    
    public enum Action: Equatable {
        // Client
        case initialized
        
        // Browsing
        case foundPeer(PeerID, discoveryInfo: [String: String]?)
        case lostPeer(PeerID)
        case didNotStartBrowsingForPeers(Error)
        
        // Advertising
        case didNotStartAdvertisingPeer(Error)
        case didReveiveInvitationFromPeer(PeerID, context: Data?)
        
        // Session
        case didChangePeer(PeerID, state: MCSessionState)
        case didReceiveData(Data, fromPeer: PeerID)
        case didReceiveStream(InputStream, streamName: String, fromPeer: PeerID)
        case didStartReveivingResourceWithName(String, fromPeer: PeerID, progress: Progress)
        case didFinishReceivingResourceWithName(String, fromPeer: PeerID, localURL: URL?, error: Error?)
        
        // Sending-receiving data
        case sendingError(Error)
        case receivingError(Error)
    }
    
    var create: (AnyHashable, String, String, [String : String]?) -> Effect<Action, Never> = { _,_,_,_  in
        _unimplemented("create")
    }

    var destroy: (AnyHashable) -> Effect<Never, Never> = { _ in
        _unimplemented("destroy")
    }

    var startBrowsingForPeers: (AnyHashable) -> Effect<Never, Never> = { _ in
        _unimplemented("startBrowsingForPeers")
    }
    
    var stopBrowsingForPeers: (AnyHashable) -> Effect<Never, Never> = { _ in
        _unimplemented("stopBrowsingForPeers")
    }
    
    var startAdvertisingForPeers: (AnyHashable) -> Effect<Never, Never> = { _ in
        _unimplemented("startAdvertisingForPeers")
    }
    
    var stopAdvertisingForPeers: (AnyHashable) -> Effect<Never, Never> = { _ in
        _unimplemented("stopAdvertisingForPeers")
    }
    
    var invitationHandler: (AnyHashable, Bool) -> Effect<Never, Never> = { _,_ in
        _unimplemented("invitationHandler")
    }

    var invitePeer: (AnyHashable, PeerID, Data?, TimeInterval) -> Effect<Never, Never> = { _,_,_,_ in
        _unimplemented("invitePeer")
    }
    
    var disconnectAllPeers: (AnyHashable) -> Effect<Never, Never> = { _ in
        _unimplemented("disconnectFromSession")
    }
    
    var send: (AnyHashable, Receiver, Data) -> Effect<Never, Never> = { _,_,_   in
        _unimplemented("send")
    }
    
    public func create(id: AnyHashable, displayName: String, serviceType: String, discoveryInfo: [String : String]?) -> Effect<Action, Never> {
        self.create(id, displayName, serviceType, discoveryInfo)
    }
    
    public func destroy(id: AnyHashable) -> Effect<Never, Never> {
        self.destroy(id)
    }
    
    public func startBrowsingForPeers(id: AnyHashable) -> Effect<Never, Never> {
        self.startBrowsingForPeers(id)
    }
    
    public func stopBrowsingForPeers(id: AnyHashable) -> Effect<Never, Never> {
        self.stopBrowsingForPeers(id)
    }
    
    public func startAdvertisingForPeers(id: AnyHashable) -> Effect<Never, Never> {
        self.startAdvertisingForPeers(id)
    }
    
    public func stopAdvertisingForPeers(id: AnyHashable) -> Effect<Never, Never> {
        self.stopAdvertisingForPeers(id)
    }
    
    public func invitationHandler(id: AnyHashable, connect: Bool) -> Effect<Never, Never> {
        self.invitationHandler(id, connect)
    }

    public func invitePeer(id: AnyHashable, peerID: PeerID, context: Data?, timeout: TimeInterval) -> Effect<Never, Never> {
        self.invitePeer(id, peerID, context, timeout)
    }
    
    public func disconnectAllPeers(id: AnyHashable) -> Effect<Never, Never> {
        self.disconnectAllPeers(id)
    }
    
    public func send(id: AnyHashable, to Receiver: Receiver, _ data: Data) -> Effect<Never, Never> {
        self.send(id, Receiver, data)
    }
}

public func _unimplemented(
  _ function: StaticString, file: StaticString = #file, line: UInt = #line
) -> Never {
  fatalError(
    """
    `\(function)` was called but is not implemented. Be sure to provide an implementation for
    this endpoint when creating the mock.
    """,
    file: file,
    line: line
  )
}
