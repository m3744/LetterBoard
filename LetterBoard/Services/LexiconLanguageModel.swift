import Foundation
import Megrez

/// 給 Megrez 用的語言模型：注音鍵 → 字詞與分數。
/// 資料檔 lexicon.tsv 由 tools/gen_zhuyin_data.py 從新酷音詞庫產生。
final class LexiconLanguageModel: LangModelProtocol {
    private struct Entry {
        let value: String
        let score: Double
    }

    static let separator = "-"

    /// key 例如 "ㄋㄧˇ-ㄏㄠˇ"；每個 key 底下的字詞依分數由高到低排序
    private let table: [String: [Entry]]

    init(url: URL) throws {
        var table: [String: [Entry]] = [:]
        for row in try TSVResource.rows(at: url) where row.count >= 3 {
            guard let score = Double(row[2]) else { continue }
            table[String(row[0]), default: []].append(Entry(value: String(row[1]), score: score))
        }
        for key in table.keys {
            table[key]?.sort { $0.score > $1.score }
        }
        self.table = table
    }

    static func load(bundle: Bundle = .main) throws -> LexiconLanguageModel {
        try LexiconLanguageModel(url: TSVResource.url(named: "lexicon", bundle: bundle))
    }

    func unigramsFor(keyArray: [String]) -> [Megrez.Unigram] {
        let entries = table[keyArray.joined(separator: Self.separator)] ?? []
        return entries.map { Megrez.Unigram(keyArray: keyArray, value: $0.value, score: $0.score) }
    }

    func hasUnigramsFor(keyArray: [String]) -> Bool {
        table[keyArray.joined(separator: Self.separator)] != nil
    }
}
