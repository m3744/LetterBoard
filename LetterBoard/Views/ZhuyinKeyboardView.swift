import SwiftUI

/// 注音鍵盤，符號依課本「ㄅㄆㄇ」順序排列。
/// 如果他比較熟悉電腦鍵盤的大千排列，只要改 `rows` 即可。
struct ZhuyinKeyboardView: View {
    let onPress: (KeyItem) -> Void

    static let rows: [[KeyItem]] = [
        "ㄅㄆㄇㄈㄉㄊㄋㄌㄍㄎㄏ",
        "ㄐㄑㄒㄓㄔㄕㄖㄗㄘㄙ",
        "ㄧㄨㄩㄚㄛㄜㄝㄞㄟㄠㄡ",
        "ㄢㄣㄤㄥㄦ",
    ].map { $0.map(KeyItem.zhuyin) } + [
        [
            .space(label: "一聲／空白", widthUnits: 3),
            .tone("ˊ", caption: "二聲"),
            .tone("ˇ", caption: "三聲"),
            .tone("ˋ", caption: "四聲"),
            .tone("˙", caption: "輕聲"),
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
