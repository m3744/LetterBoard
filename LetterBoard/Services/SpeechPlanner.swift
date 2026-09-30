import Foundation

enum SpeechLanguage: Equatable {
    case chinese
    case english

    var voiceCode: String {
        switch self {
        case .chinese: Constants.Speech.chineseVoice
        case .english: Constants.Speech.englishVoice
        }
    }
}

struct SpeechSegment: Equatable {
    let text: String
    let language: SpeechLanguage
}

/// 把顯示區的文字切成要交給 TTS 的片段：
/// - 注音 → 用代表字表換成漢字，以中文語音唸
/// - 英文字母、數字 → 英文語音
/// - 其他（漢字、全形標點）→ 中文語音
/// 空白與半形標點跟著前一段走。
enum SpeechPlanner {
    static func segments(for text: String, readings: ZhuyinReadingTable) -> [SpeechSegment] {
        var segments: [SpeechSegment] = []
        var current = ""
        var currentLanguage: SpeechLanguage?
        var zhuyinBuffer = ""

        func flushCurrent() {
            if let language = currentLanguage,
               !current.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                segments.append(SpeechSegment(text: current, language: language))
            }
            current = ""
            currentLanguage = nil
        }

        func append(_ piece: String, as language: SpeechLanguage?) {
            guard !piece.isEmpty else { return }
            if let language, let active = currentLanguage, active != language {
                flushCurrent()
            }
            if let language, currentLanguage == nil {
                currentLanguage = language
            }
            current += piece
        }

        func flushZhuyin() {
            guard !zhuyinBuffer.isEmpty else { return }
            append(readings.convert(zhuyinBuffer), as: .chinese)
            zhuyinBuffer = ""
        }

        for character in text {
            if Zhuyin.isZhuyin(character) {
                zhuyinBuffer.append(character)
                continue
            }
            flushZhuyin()
            append(String(character), as: language(of: character))
        }
        flushZhuyin()
        flushCurrent()
        return segments
    }

    /// nil 代表中性字元（空白、半形標點），不決定語言
    private static func language(of character: Character) -> SpeechLanguage? {
        if character.isASCII {
            return character.isLetter || character.isNumber ? .english : nil
        }
        return .chinese
    }
}
