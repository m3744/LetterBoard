import XCTest
@testable import LetterBoard

final class ZhuyinTests: XCTestCase {
    func testSplitSyllablesWithTones() {
        XCTAssertEqual(Zhuyin.splitSyllables("ㄋㄧˇㄏㄠˇ"), ["ㄋㄧˇ", "ㄏㄠˇ"])
    }

    func testSplitSyllablesStartsNewSyllableWhenSlotRepeats() {
        // ㄨㄛ 後面接 ㄧ（介音）不能放進同一音節，視為一聲後斷開
        XCTAssertEqual(Zhuyin.splitSyllables("ㄨㄛㄧㄠˋ"), ["ㄨㄛ", "ㄧㄠˋ"])
    }

    func testSplitSyllablesDropsOrphanToneAndBreaksOnOtherCharacters() {
        XCTAssertEqual(Zhuyin.splitSyllables("ˇㄕˋ ㄓ"), ["ㄕˋ", "ㄓ"])
    }

    func testSyllableBuilderOrdering() {
        var builder = SyllableBuilder()
        XCTAssertTrue(builder.canAppend("ㄋ"))
        builder.append("ㄋ")
        XCTAssertTrue(builder.canAppend("ㄧ"))
        builder.append("ㄧ")
        XCTAssertFalse(builder.canAppend("ㄏ"))
        XCTAssertTrue(builder.canAppend("ㄠ"))
        builder.append("ㄠ")
        XCTAssertEqual(builder.text, "ㄋㄧㄠ")
        builder.removeLast()
        XCTAssertEqual(builder.text, "ㄋㄧ")
    }
}
