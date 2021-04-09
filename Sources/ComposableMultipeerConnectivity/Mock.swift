import Combine
import ComposableArchitecture
import MultipeerConnectivity

extension MultipeerConnectivity {
    
    public static func unimplemented(
        create: @escaping (AnyHashable, String, String, [String : String]?) -> Effect<Action, Never> = { _,_,_,_ in
            _unimplemented("create")
        },
        destroy: @escaping (AnyHashable) -> Effect<Never, Never> = { _ in
            _unimplemented("destroy")
        },
        startBrowsingForPeers: @escaping (AnyHashable) -> Effect<Never, Never> = { _ in
            _unimplemented("startBrowsingForPeers")
        },
        stopBrowsingForPeers: @escaping (AnyHashable) -> Effect<Never, Never> = { _ in
            _unimplemented("stopBrowsingForPeers")
        },
        startAdvertisingForPeers: @escaping (AnyHashable) -> Effect<Never, Never> = { _ in
            _unimplemented("startAdvertisingForPeers")
        },
        stopAdvertisingForPeers: @escaping (AnyHashable) -> Effect<Never, Never> = { _ in
            _unimplemented("stopAdvertisingForPeers")
        },
        invitationHandler: @escaping (AnyHashable, Bool) -> Effect<Never, Never> = { _,_ in
            _unimplemented("invitationHandler")
        },
        invitePeer: @escaping (AnyHashable, PeerID, Data?, TimeInterval) -> Effect<Never, Never> = { _,_,_,_ in
            _unimplemented("invitePeer")
        },
        disconnectAllPeers: @escaping (AnyHashable) -> Effect<Never, Never> = { _ in
            _unimplemented("disconnectAllPeers")
        },
        send: @escaping (AnyHashable, Receiver, Data) -> Effect<Never, Never> = { _,_,_ in
            _unimplemented("send")
        }
    ) -> Self {
        Self(
            create: create,
            destroy: destroy,
            startBrowsingForPeers: startBrowsingForPeers,
            stopBrowsingForPeers: stopBrowsingForPeers,
            startAdvertisingForPeers: startAdvertisingForPeers,
            stopAdvertisingForPeers: stopAdvertisingForPeers,
            invitationHandler: invitationHandler,
            invitePeer: invitePeer,
            disconnectAllPeers: disconnectAllPeers,
            send: send
        )
    }
}
