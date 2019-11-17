import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(VehicleViewerMapViewTests.allTests),
    ]
}
#endif
