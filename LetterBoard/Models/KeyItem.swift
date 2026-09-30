import CoreGraphics

/// 按下按鍵後要做的事
enum KeyAction: Hashable {
    /// 注音符號（聲母、介音、韻母）
    case zhuyin(Character)
    /// 聲調符號：ˊ ˇ ˋ ˙
    case tone(Character)
    /// 直接輸入文字（英文字母、標點）
    case insert(String)
    /// 空白鍵；在注音布局裡同時代表「一聲」
    case space
}

/// 按鍵外觀分類，用不同底色做視覺分組
enum KeyStyle: Hashable {
    case symbol
    case tone
    case function
}

struct KeyItem: Identifiable, Hashable {
    let id: String
    /// 按鍵上的主要文字
    let label: String
    /// 主要文字下方的小字說明（例如聲調鍵的「二聲」）
    var caption: String?
    let action: KeyAction
    /// 按鍵寬度，以一般按鍵寬度為 1 單位
    var widthUnits: CGFloat = 1
    var style: KeyStyle = .symbol

    static func zhuyin(_ symbol: Character) -> KeyItem {
        KeyItem(id: "zhuyin-\(symbol)", label: String(symbol), action: .zhuyin(symbol))
    }

    static func tone(_ mark: Character, caption: String) -> KeyItem {
        KeyItem(id: "tone-\(mark)", label: String(mark), caption: caption, action: .tone(mark), style: .tone)
    }

    /// 英文字母：按鍵顯示大寫，輸入小寫（全大寫的字會被語音當成縮寫逐字母唸）
    static func letter(_ letter: Character) -> KeyItem {
        KeyItem(id: "letter-\(letter)", label: String(letter).uppercased(), action: .insert(String(letter).lowercased()))
    }

    static func punctuation(_ mark: String) -> KeyItem {
        KeyItem(id: "punct-\(mark)", label: mark, action: .insert(mark), style: .function)
    }

    static func space(label: String, widthUnits: CGFloat) -> KeyItem {
        KeyItem(id: "space", label: label, action: .space, widthUnits: widthUnits, style: .function)
    }
}
