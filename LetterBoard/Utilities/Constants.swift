import SwiftUI

/// 所有可調整的尺寸與行為參數集中在這裡，方便依實際使用狀況微調。
enum Constants {
    enum Keyboard {
        /// 按鍵之間的間距（pt）
        static let spacing: CGFloat = 12
        /// 按鍵高度上限，避免在大螢幕上按鍵被拉得太高
        static let maxKeyHeight: CGFloat = 140
        /// 按鍵最小觸控尺寸（規格要求至少 70×70 pt）
        static let minKeySize: CGFloat = 70
        static let cornerRadius: CGFloat = 14
        static let symbolFontSize: CGFloat = 40
        static let captionFontSize: CGFloat = 16
    }

    enum Display {
        /// 頂部文字顯示區高度（單行）
        static let height: CGFloat = 72
        static let fontSize: CGFloat = 36
    }

    enum ControlBar {
        static let height: CGFloat = 72
        static let fontSize: CGFloat = 26
    }

    enum CandidateBar {
        /// 固定高度：沒有候選字時也保留空間，避免鍵盤上下跳動
        static let height: CGFloat = 64
        static let fontSize: CGFloat = 30
        /// 最多顯示幾個候選字
        static let limit = 10
    }

    enum Input {
        /// 同一顆鍵在這段時間內重複觸發會被忽略（秒），減少誤觸連點
        static let repeatGuardInterval: TimeInterval = 0.3
        /// 組字區最多保留幾個音節，超過時把最前面的字詞自動送出
        static let maxCompositionLength = 12
    }

    enum Speech {
        static let chineseVoice = "zh-TW"
        static let englishVoice = "en-US"
        /// 0.0～1.0，系統預設約 0.5；稍慢一點比較清楚
        static let rate: Float = 0.45
    }

    enum Colors {
        static let background = Color(.systemBackground)
        static let panel = Color(.secondarySystemBackground)
        static let keyBackground = Color(.secondarySystemBackground)
        static let keyPressedBackground = Color(.systemGray3)
        static let toneKeyBackground = Color(.systemGray5)
        static let functionKeyBackground = Color(.systemGray4)
        static let keyBorder = Color(.separator)
        static let keyText = Color.primary
        static let speakButton = Color.blue
        static let selectedLayout = Color.blue
        static let pendingText = Color.blue
    }
}
