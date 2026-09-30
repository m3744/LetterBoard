import SwiftUI

/// 依可用空間計算按鍵大小，讓鍵盤填滿畫面下方。直式、橫式都適用。
struct KeyboardView: View {
    let rows: [[KeyItem]]
    let onPress: (KeyItem) -> Void

    var body: some View {
        GeometryReader { geometry in
            let spacing = Constants.Keyboard.spacing
            let maxUnits = rows.map { $0.reduce(0) { $0 + $1.widthUnits } }.max() ?? 1
            let unitWidth = (geometry.size.width - spacing * (maxUnits - 1)) / maxUnits
            let rowCount = CGFloat(rows.count)
            let rowHeight = min(
                (geometry.size.height - spacing * (rowCount - 1)) / rowCount,
                Constants.Keyboard.maxKeyHeight
            )

            VStack(spacing: spacing) {
                ForEach(rows.indices, id: \.self) { index in
                    HStack(spacing: spacing) {
                        ForEach(rows[index]) { key in
                            KeyButton(key: key) { onPress(key) }
                                .frame(
                                    width: unitWidth * key.widthUnits + spacing * (key.widthUnits - 1),
                                    height: rowHeight
                                )
                        }
                    }
                }
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
    }
}
