import Combine
import ComposableArchitecture
import MultipeerConnectivity

public extension MultipeerConnectivity {
    mutating func unimplemented(
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
    ) {
        self.create = create
        self.destroy = destroy
        self.startBrowsingForPeers = startBrowsingForPeers
        self.stopBrowsingForPeers = stopBrowsingForPeers
        self.startAdvertisingForPeers = startAdvertisingForPeers
        self.stopAdvertisingForPeers = stopAdvertisingForPeers
        self.invitationHandler = invitationHandler
        self.invitePeer = invitePeer
        self.disconnectAllPeers = disconnectAllPeers
        self.send = send
    }
}
