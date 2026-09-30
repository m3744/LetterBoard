import XCTest
@testable import LetterBoard

final class SpeechPlannerTests: XCTestCase {
    private let readings = ZhuyinReadingTable(table: [
        "ㄨㄛˇ": "我",
        "ㄕㄨㄟˇ": "水",
        "ㄏㄜ": "呵",
    ])

    func testZhuyinIsReplacedByRepresentativeCharacters() {
        let segments = SpeechPlanner.segments(for: "ㄨㄛˇㄕㄨㄟˇ", readings: readings)
        XCTAssertEqual(segments, [SpeechSegment(text: "我水", language: .chinese)])
    }

    func testUnknownToneFallsBackToFirstTone() {
        XCTAssertEqual(readings.character(for: "ㄏㄜˋ"), "呵")
    }

    func testMixedChineseAndEnglishAreSplit() {
        let segments = SpeechPlanner.segments(for: "我要 apple。", readings: readings)
        XCTAssertEqual(segments, [
            SpeechSegment(text: "我要 ", language: .chinese),
            SpeechSegment(text: "apple", language: .english),
            SpeechSegment(text: "。", language: .chinese),
        ])
    }

    func testWhitespaceOnlyProducesNothing() {
        XCTAssertTrue(SpeechPlanner.segments(for: "   ", readings: readings).isEmpty)
    }
}
