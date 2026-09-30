import Foundation
import Observation

/// 畫面狀態與輸入流程。
///
/// 顯示的文字由三段組成：
/// - committedText：已確定的文字（漢字、英文、標點）
/// - compositionText：選字引擎目前組出的漢字，還可以換候選字
/// - pendingText：正在拼、還沒按聲調的注音
@MainActor
@Observable
final class BoardViewModel {
    private static let layoutDefaultsKey = "currentLayout"

    private(set) var layout: LayoutType
    private(set) var committedText = ""
    private(set) var compositionText = ""
    private(set) var pendingText = ""
    private(set) var candidates: [Candidate] = []

    var displayText: String { committedText + compositionText + pendingText }

    @ObservationIgnored private var syllable = SyllableBuilder()
    /// 詞庫在背景載入；載入完成前（或載入失敗時）注音直接以符號顯示，朗讀仍可用代表字表
    @ObservationIgnored private var composer: ZhuyinComposer?
    private let speech: SpeechService
    @ObservationIgnored private var lastPress: (id: String, time: Date)?

    init() {
        let saved = UserDefaults.standard.string(forKey: Self.layoutDefaultsKey)
        layout = saved.flatMap(LayoutType.init(rawValue:)) ?? .zhuyin
        // 代表字表載入失敗時仍可朗讀漢字與英文，只是注音會被略過
        let readings = (try? ZhuyinReadingTable.load()) ?? ZhuyinReadingTable(table: [:])
        speech = SpeechService(readings: readings)
    }

    func loadEngine() async {
        guard composer == nil else { return }
        let model = await Task.detached(priority: .userInitiated) {
            try? LexiconLanguageModel.load()
        }.value
        guard let model else { return }
        composer = ZhuyinComposer(model: model)
    }

    // MARK: - 按鍵

    func press(_ key: KeyItem) {
        guard !isAccidentalRepeat(key) else { return }

        switch key.action {
        case .zhuyin(let symbol):
            if !syllable.canAppend(symbol) {
                // 例如「ㄋㄧ」後面按了「ㄏ」：前一個音節當作一聲送出
                finishSyllable(tone: nil)
            }
            syllable.append(symbol)
        case .tone(let mark):
            guard !syllable.isEmpty else { return }
            finishSyllable(tone: mark)
        case .space:
            if !syllable.isEmpty {
                finishSyllable(tone: nil)
            } else if composer?.isEmpty == false {
                commitComposition()
            } else {
                committedText += " "
            }
        case .insert(let text):
            commitAll()
            committedText += text
        }
        refresh()
    }

    func select(_ candidate: Candidate) {
        composer?.select(candidate)
        refresh()
    }

    func deleteBackward() {
        if !syllable.isEmpty {
            syllable.removeLast()
        } else if let composer, !composer.isEmpty {
            composer.deleteLastSyllable()
        } else if !committedText.isEmpty {
            committedText.removeLast()
        }
        refresh()
    }

    func clearAll() {
        syllable.reset()
        composer?.clear()
        committedText = ""
        speech.stop()
        refresh()
    }

    func speak() {
        speech.speak(displayText)
    }

    func switchLayout(to newLayout: LayoutType) {
        guard newLayout != layout else { return }
        commitAll()
        layout = newLayout
        UserDefaults.standard.set(newLayout.rawValue, forKey: Self.layoutDefaultsKey)
        refresh()
    }

    // MARK: - 內部流程

    private func finishSyllable(tone: Character?) {
        guard !syllable.isEmpty else { return }
        let text = syllable.text + (tone.map { String($0) } ?? "")
        syllable.reset()

        if let composer, composer.insert(syllable: text) {
            committedText += composer.popLeadingWords(keeping: Constants.Input.maxCompositionLength)
        } else {
            // 引擎還沒載入，或詞庫沒有這個音節：保留注音原樣，朗讀時用代表字表處理
            commitComposition()
            committedText += text
        }
    }

    private func commitComposition() {
        guard let composer, !composer.isEmpty else { return }
        committedText += composer.text
        composer.clear()
    }

    private func commitAll() {
        finishSyllable(tone: nil)
        commitComposition()
    }

    private func refresh() {
        compositionText = composer?.text ?? ""
        pendingText = syllable.text
        candidates = composer?.candidates(limit: Constants.CandidateBar.limit) ?? []
    }

    private func isAccidentalRepeat(_ key: KeyItem) -> Bool {
        let now = Date()
        defer { self.lastPress = (key.id, now) }
        guard let lastPress, lastPress.id == key.id else { return false }
        return now.timeIntervalSince(lastPress.time) < Constants.Input.repeatGuardInterval
    }
}
