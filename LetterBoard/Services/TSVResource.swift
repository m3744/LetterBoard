import Foundation

/// 讀取 Resources 裡的 .tsv 資料檔（# 開頭為註解）
enum TSVResource {
    enum LoadError: Error {
        case missing(String)
    }

    static func url(named name: String, bundle: Bundle = .main) throws -> URL {
        guard let url = bundle.url(forResource: name, withExtension: "tsv") else {
            throw LoadError.missing("\(name).tsv")
        }
        return url
    }

    /// 逐行回傳以 tab 分隔的欄位
    static func rows(at url: URL) throws -> [[Substring]] {
        let content = try String(contentsOf: url, encoding: .utf8)
        return content.split(whereSeparator: \.isNewline).compactMap { line in
            guard !line.hasPrefix("#") else { return nil }
            return line.split(separator: "\t", omittingEmptySubsequences: false)
        }
    }
}
