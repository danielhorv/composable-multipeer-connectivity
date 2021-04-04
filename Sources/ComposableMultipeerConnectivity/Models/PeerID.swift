import Foundation
import MultipeerConnectivity

public struct PeerID: Equatable, Hashable, Codable {
    public let displayName: String
    
    public init(displayName: String) {
        self.displayName = displayName
    }
    
    public init(peerId: MCPeerID) {
        self.displayName = peerId.displayName
    }
}

extension PeerID: Identifiable {
    public var id: String {
        return displayName
    }
}
