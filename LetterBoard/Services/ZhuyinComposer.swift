import Foundation
import Megrez

/// 候選字詞
struct Candidate: Identifiable, Hashable {
    let keys: [String]
    let value: String
    let score: Double

    var id: String { keys.joined(separator: LexiconLanguageModel.separator) + "|" + value }
}

/// 包裝 Megrez 組字器：輸入注音音節，自動組出最可能的漢字句子，並提供候選字。
/// 游標永遠停在最後面（這個 App 不做游標移動）。
final class ZhuyinComposer {
    private let compositor: Megrez.Compositor

    init(model: LangModelProtocol) {
        compositor = Megrez.Compositor(with: model, separator: LexiconLanguageModel.separator)
    }

    var isEmpty: Bool { compositor.isEmpty }

    var syllableCount: Int { compositor.length }

    /// 目前組出的漢字
    var text: String { compositor.assembledSentence.values.joined() }

    /// 插入一個完整音節（含聲調，一聲不寫）。詞庫裡沒有這個音節時回傳 false。
    @discardableResult
    func insert(syllable: String) -> Bool {
        compositor.cursor = compositor.length
        guard compositor.insertKey(syllable) else { return false }
        compositor.assemble()
        return true
    }

    func deleteLastSyllable() {
        compositor.cursor = compositor.length
        compositor.dropKey(direction: .rear)
        compositor.assemble()
    }

    func clear() {
        compositor.clear()
    }

    /// 以最後一個音節結尾的候選字詞，長詞優先、同長度依分數排序
    func candidates(limit: Int) -> [Candidate] {
        guard !compositor.isEmpty else { return [] }
        let pairs = compositor.fetchCandidates(at: compositor.length, filter: .endAt)
            .sorted { lhs, rhs in
                if lhs.keyArray.count != rhs.keyArray.count { return lhs.keyArray.count > rhs.keyArray.count }
                return lhs.score > rhs.score
            }
        var seen = Set<String>()
        var result: [Candidate] = []
        for pair in pairs {
            guard seen.insert(pair.value).inserted else { continue }
            result.append(Candidate(keys: pair.keyArray, value: pair.value, score: pair.score))
            if result.count == limit { break }
        }
        return result
    }

    /// 選定候選字詞，重新組句
    func select(_ candidate: Candidate) {
        let pair = Megrez.KeyValuePaired(keyArray: candidate.keys, value: candidate.value, score: candidate.score)
        compositor.overrideCandidate(pair, at: compositor.length - 1)
        compositor.assemble()
    }

    /// 組字區超過 maxLength 個音節時，把最前面的字詞移出並回傳，讓呼叫端送進已確定的文字
    func popLeadingWords(keeping maxLength: Int) -> String {
        var popped = ""
        while compositor.length > maxLength, let first = compositor.assembledSentence.first {
            popped += first.value
            compositor.cursor = 0
            for _ in 0 ..< first.segLength {
                compositor.dropKey(direction: .front)
            }
            compositor.cursor = compositor.length
            compositor.assemble()
        }
        return popped
    }
}
