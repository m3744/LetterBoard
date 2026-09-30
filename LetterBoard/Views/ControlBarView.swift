import SwiftUI

/// 功能控制列：朗讀（最明顯）與布局切換
struct ControlBarView: View {
    let layout: LayoutType
    let onSpeak: () -> Void
    let onSwitchLayout: (LayoutType) -> Void

    var body: some View {
        HStack(spacing: 12) {
            ControlButton(
                title: "朗讀",
                systemImage: "speaker.wave.2.fill",
                foreground: .white,
                background: Constants.Colors.speakButton,
                action: onSpeak
            )
            .frame(maxWidth: .infinity)

            ForEach(LayoutType.allCases) { option in
                let isSelected = option == layout
                ControlButton(
                    title: option.title,
                    foreground: isSelected ? .white : Constants.Colors.keyText,
                    background: isSelected ? Constants.Colors.selectedLayout : Constants.Colors.functionKeyBackground
                ) {
                    onSwitchLayout(option)
                }
                .frame(width: 180)
                .accessibilityAddTraits(isSelected ? .isSelected : [])
            }
        }
        .frame(height: Constants.ControlBar.height)
    }
}

/// 有文字標示的功能按鈕（規格要求不可只有圖示）
struct ControlButton: View {
    let title: String
    var systemImage: String?
    var foreground: Color = Constants.Colors.keyText
    var background: Color = Constants.Colors.functionKeyBackground
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if let systemImage {
                    Image(systemName: systemImage)
                }
                Text(title)
            }
            .font(.system(size: Constants.ControlBar.fontSize, weight: .bold))
            .foregroundStyle(foreground)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(RoundedRectangle(cornerRadius: 12).fill(background))
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}
