import XCTest
@testable import reflect

final class RegexParsingTests: XCTestCase {
    
    func testRegexParsing() {
        let metrics: [XCTMetric] = [XCTClockMetric()]
        let options = XCTMeasureOptions.default
        options.iterationCount = 100
        let parser = Parser.BMO
        
        measure(metrics: metrics, options: options) {
            _ = parser.searching(in: Parser.samples, for: .account)
            _ = parser.searching(in: Parser.samples, for: .date)
            _ = parser.searching(in: Parser.samples, for: .code)
            _ = parser.searching(in: Parser.samples, for: .amount)
        }
    }
}
