import Foundation

/// 注音音節中的位置：聲母 → 介音 → 韻母，聲調最後
enum ZhuyinSlot: Int, Comparable {
    case initial
    case medial
    case final

    static func < (lhs: ZhuyinSlot, rhs: ZhuyinSlot) -> Bool { lhs.rawValue < rhs.rawValue }
}

enum Zhuyin {
    static let initials: [Character] = Array("ㄅㄆㄇㄈㄉㄊㄋㄌㄍㄎㄏㄐㄑㄒㄓㄔㄕㄖㄗㄘㄙ")
    static let medials: [Character] = Array("ㄧㄨㄩ")
    static let finals: [Character] = Array("ㄚㄛㄜㄝㄞㄟㄠㄡㄢㄣㄤㄥㄦ")
    static let toneMarks: [Character] = Array("ˊˇˋ˙")

    private static let initialSet = Set(initials)
    private static let medialSet = Set(medials)
    private static let finalSet = Set(finals)
    private static let toneSet = Set(toneMarks)

    static func slot(of symbol: Character) -> ZhuyinSlot? {
        if initialSet.contains(symbol) { return .initial }
        if medialSet.contains(symbol) { return .medial }
        if finalSet.contains(symbol) { return .final }
        return nil
    }

    static func isToneMark(_ character: Character) -> Bool {
        toneSet.contains(character)
    }

    /// 注音符號或聲調符號
    static func isZhuyin(_ character: Character) -> Bool {
        slot(of: character) != nil || isToneMark(character)
    }

    /// 把一串注音拆成音節，例如 "ㄋㄧˇㄏㄠˇ" → ["ㄋㄧˇ", "ㄏㄠˇ"]。
    /// 沒有聲調符號的音節視為一聲；遇到不能接在後面的符號時自動斷開。
    static func splitSyllables(_ text: String) -> [String] {
        var result: [String] = []
        var builder = SyllableBuilder()

        func flush(tone: Character?) {
            guard !builder.isEmpty else { return }
            result.append(builder.text + (tone.map { String($0) } ?? ""))
            builder.reset()
        }

        for character in text {
            if isToneMark(character) {
                flush(tone: character)
            } else if slot(of: character) != nil {
                if !builder.canAppend(character) { flush(tone: nil) }
                builder.append(character)
            } else {
                flush(tone: nil)
            }
        }
        flush(tone: nil)
        return result
    }
}

/// 組合中的單一注音音節（尚未加聲調）
struct SyllableBuilder: Equatable {
    private(set) var initial: Character?
    private(set) var medial: Character?
    private(set) var final: Character?

    var isEmpty: Bool { initial == nil && medial == nil && final == nil }

    var text: String { String([initial, medial, final].compactMap { $0 }) }

    private var lastFilledSlot: ZhuyinSlot? {
        if final != nil { return .final }
        if medial != nil { return .medial }
        if initial != nil { return .initial }
        return nil
    }

    /// 符號必須排在目前已填位置的後面，例如「ㄋㄧ」後面可以接「ㄠ」，不能再接「ㄏ」
    func canAppend(_ symbol: Character) -> Bool {
        guard let slot = Zhuyin.slot(of: symbol) else { return false }
        guard let last = lastFilledSlot else { return true }
        return slot > last
    }

    mutating func append(_ symbol: Character) {
        switch Zhuyin.slot(of: symbol) {
        case .initial: initial = symbol
        case .medial: medial = symbol
        case .final: final = symbol
        case nil: break
        }
    }

    mutating func removeLast() {
        if final != nil {
            final = nil
        } else if medial != nil {
            medial = nil
        } else {
            initial = nil
        }
    }

    mutating func reset() {
        self = SyllableBuilder()
    }
}
