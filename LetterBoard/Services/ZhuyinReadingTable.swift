import Foundation

/// 做法 A：注音音節 → 讀音唯一的代表字。
/// 朗讀時把還是注音的部分換成代表字再交給 TTS，例如「ㄨㄛˇ ㄕㄨㄟˇ」→「我水」。
/// 資料檔由 tools/gen_zhuyin_data.py 產生。
struct ZhuyinReadingTable {
    private let table: [String: String]

    init(table: [String: String]) {
        self.table = table
    }

    static func load(bundle: Bundle = .main) throws -> ZhuyinReadingTable {
        let url = try TSVResource.url(named: "zhuyin_readings", bundle: bundle)
        var table: [String: String] = [:]
        for row in try TSVResource.rows(at: url) where row.count >= 2 {
            table[String(row[0])] = String(row[1])
        }
        return ZhuyinReadingTable(table: table)
    }

    /// 找不到完全相同的音節時（例如打錯聲調），退而求其次改用一聲
    func character(for syllable: String) -> String? {
        if let exact = table[syllable] { return exact }
        let withoutTone = String(syllable.filter { !Zhuyin.isToneMark($0) })
        return table[withoutTone]
    }

    /// 把一串注音轉成代表字；無法辨識的音節略過
    func convert(_ zhuyin: String) -> String {
        Zhuyin.splitSyllables(zhuyin).compactMap(character(for:)).joined()
    }
}
