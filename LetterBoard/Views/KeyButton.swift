import SwiftUI

struct KeyButton: View {
    let key: KeyItem
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 2) {
                Text(key.label)
                    .font(.system(size: Constants.Keyboard.symbolFontSize, weight: .semibold))
                    .minimumScaleFactor(0.5)
                    .lineLimit(1)
                if let caption = key.caption {
                    Text(caption)
                        .font(.system(size: Constants.Keyboard.captionFontSize, weight: .medium))
                        .lineLimit(1)
                }
            }
            .foregroundStyle(Constants.Colors.keyText)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .contentShape(Rectangle())
        }
        .buttonStyle(KeyButtonStyle(style: key.style))
        .accessibilityLabel(key.caption.map { "\(key.label) \($0)" } ?? key.label)
    }
}

/// 按下時只換底色，不縮放、不動畫，保持低刺激
private struct KeyButtonStyle: ButtonStyle {
    let style: KeyStyle

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(
                RoundedRectangle(cornerRadius: Constants.Keyboard.cornerRadius)
                    .fill(configuration.isPressed ? Constants.Colors.keyPressedBackground : background)
            )
            .overlay(
                RoundedRectangle(cornerRadius: Constants.Keyboard.cornerRadius)
                    .stroke(Constants.Colors.keyBorder, lineWidth: 1)
            )
    }

    private var background: Color {
        switch style {
        case .symbol: Constants.Colors.keyBackground
        case .tone: Constants.Colors.toneKeyBackground
        case .function: Constants.Colors.functionKeyBackground
        }
    }
}
