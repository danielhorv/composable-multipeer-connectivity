import Foundation
import MultipeerConnectivity

class PeerIDManager: NSObject {
    
    // found peerIDs
    private var peerIds: [MCPeerID] = []
    
    let myPeerId: MCPeerID
    
    init(myPeerId: MCPeerID) {
        self.myPeerId = myPeerId
    }
    
    func add(_ peerID: MCPeerID) {
        peerIds.append(peerID)
    }
    
    func remove(_ peerID: MCPeerID) {
        if peerIds.contains(peerID) {
            peerIds.removeAll(where: { $0 == peerID })
        }
    }
    
    func loadMCPeerIDs(for peerIDs: [PeerID]) -> [MCPeerID] {
        return peerIds.filter { peerIDs.map { $0.displayName }.contains($0.displayName) }
    }
    
    func loadMCPeerID(for peerID: PeerID) -> MCPeerID? {
        return peerIds.first(where: { $0.displayName == peerID.displayName })
    }
}
