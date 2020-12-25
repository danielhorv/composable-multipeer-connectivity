import XCTest
@testable import ComposableMultipeerConnectivity

final class ComposableMultipeerConnectivityTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
    }
    
    func testPeerIDEncodeDecode() {
        let myPeerID = PeerID(displayName: "myPeerID")
        let partnerPeerID = PeerID(displayName: "partnerPeerID")
        
        XCTAssertTrue(myPeerID == myPeerID)
        XCTAssertTrue(myPeerID == PeerID(displayName: "myPeerID"))
        XCTAssertFalse(myPeerID == partnerPeerID)
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
