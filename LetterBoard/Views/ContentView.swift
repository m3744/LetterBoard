import SwiftUI

/// 由上到下：文字顯示區 → 功能控制列 → （注音時）選字列 → 超大鍵盤
struct ContentView: View {
    @State private var viewModel = BoardViewModel()

    var body: some View {
        VStack(spacing: 12) {
            TextDisplayView(
                committed: viewModel.committedText,
                composition: viewModel.compositionText,
                pending: viewModel.pendingText,
                onDelete: viewModel.deleteBackward,
                onClear: viewModel.clearAll
            )

            ControlBarView(
                layout: viewModel.layout,
                onSpeak: viewModel.speak,
                onSwitchLayout: viewModel.switchLayout(to:)
            )

            switch viewModel.layout {
            case .zhuyin:
                CandidateBarView(candidates: viewModel.candidates, onSelect: viewModel.select)
                ZhuyinKeyboardView(onPress: viewModel.press)
            case .qwerty:
                QWERTYKeyboardView(onPress: viewModel.press)
            }
        }
        .padding(16)
        .background(Constants.Colors.background)
        .task { await viewModel.loadEngine() }
    }
}

#Preview {
    ContentView()
}
