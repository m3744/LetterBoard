import XCTest
@testable import LetterBoard

/// 驗證 App 內附的資料檔可以載入，且選字引擎組得出常用詞
final class ResourceTests: XCTestCase {
    func testReadingTableCoversCommonSyllables() throws {
        let table = try ZhuyinReadingTable.load()
        XCTAssertEqual(table.convert("ㄋㄧˇㄏㄠˇ"), "你好")
        XCTAssertEqual(table.convert("ㄨㄛˇㄧㄠˋㄕㄨㄟˇ"), "我要水")
    }

    func testComposerAssemblesPhrase() throws {
        let composer = ZhuyinComposer(model: try LexiconLanguageModel.load())
        XCTAssertTrue(composer.insert(syllable: "ㄨㄛˇ"))
        XCTAssertTrue(composer.insert(syllable: "ㄧㄠˋ"))
        XCTAssertEqual(composer.text, "我要")
        XCTAssertFalse(composer.candidates(limit: 10).isEmpty)
    }

    func testComposerRejectsInvalidSyllable() throws {
        let composer = ZhuyinComposer(model: try LexiconLanguageModel.load())
        XCTAssertFalse(composer.insert(syllable: "ㄅㄩ"))
        XCTAssertTrue(composer.isEmpty)
    }

    func testPopLeadingWordsKeepsTail() throws {
        let composer = ZhuyinComposer(model: try LexiconLanguageModel.load())
        for syllable in ["ㄨㄛˇ", "ㄧㄠˋ", "ㄏㄜ", "ㄕㄨㄟˇ"] {
            composer.insert(syllable: syllable)
        }
        let popped = composer.popLeadingWords(keeping: 2)
        XCTAssertEqual(composer.syllableCount, 2)
        XCTAssertEqual(popped + composer.text, "我要喝水")
    }
}
