import AVFoundation

/// 語音朗讀。中文用 zh-TW 語音、英文用 en-US 語音，注音先換成代表字再唸。
final class SpeechService {
    private let synthesizer = AVSpeechSynthesizer()
    private let readings: ZhuyinReadingTable

    init(readings: ZhuyinReadingTable) {
        self.readings = readings
    }

    func speak(_ text: String) {
        synthesizer.stopSpeaking(at: .immediate)
        let segments = SpeechPlanner.segments(for: text, readings: readings)
        guard !segments.isEmpty else { return }

        activateAudioSession()
        for segment in segments {
            let utterance = AVSpeechUtterance(string: segment.text)
            utterance.voice = AVSpeechSynthesisVoice(language: segment.language.voiceCode)
            utterance.rate = Constants.Speech.rate
            synthesizer.speak(utterance)
        }
    }

    func stop() {
        synthesizer.stopSpeaking(at: .immediate)
    }

    /// 用 .playback：iPad 側邊靜音開關打開時仍然要能發出聲音
    private func activateAudioSession() {
        let session = AVAudioSession.sharedInstance()
        try? session.setCategory(.playback, mode: .spokenAudio, options: [.duckOthers])
        try? session.setActive(true)
    }
}
