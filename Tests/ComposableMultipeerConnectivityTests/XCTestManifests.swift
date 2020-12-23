import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(ComposableMultipeerConnectivityTests.allTests),
    ]
}
#endif
