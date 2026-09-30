import SwiftUI

struct QWERTYKeyboardView: View {
    let onPress: (KeyItem) -> Void

    static let rows: [[KeyItem]] = [
        "qwertyuiop",
        "asdfghjkl",
        "zxcvbnm",
    ].map { $0.map(KeyItem.letter) } + [
        [
            .space(label: "空白", widthUnits: 4),
            .punctuation("，"),
            .punctuation("。"),
            .punctuation("？"),
            .punctuation("！"),
        ],
    ]

    var body: some View {
        KeyboardView(rows: Self.rows, onPress: onPress)
    }
}
