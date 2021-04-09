import Combine
import ComposableArchitecture
import MultipeerConnectivity

public extension MultipeerConnectivity {
    static func unimplemented(
        create: @escaping (AnyHashable, String, String, [String : String]?) -> Effect<Action, Never>,
        destroy: @escaping (AnyHashable) -> Effect<Never, Never>,
        startBrowsingForPeers: @escaping (AnyHashable) -> Effect<Never, Never>,
        stopBrowsingForPeers: @escaping (AnyHashable) -> Effect<Never, Never>,
        startAdvertisingForPeers: @escaping (AnyHashable) -> Effect<Never, Never>,
        stopAdvertisingForPeers: @escaping (AnyHashable) -> Effect<Never, Never>,
        invitationHandler: @escaping (AnyHashable, Bool) -> Effect<Never, Never>,
        invitePeer: @escaping (AnyHashable, PeerID, Data?, TimeInterval) -> Effect<Never, Never>,
        disconnectAllPeers: @escaping (AnyHashable) -> Effect<Never, Never>,
        send: @escaping (AnyHashable, Receiver, Data) -> Effect<Never, Never>
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
