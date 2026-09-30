import Foundation

enum LayoutType: String, CaseIterable, Identifiable {
    case zhuyin
    case qwerty

    var id: String { rawValue }

    /// 布局切換按鈕上的文字
    var title: String {
        switch self {
        case .zhuyin: "注音"
        case .qwerty: "QWERTY"
        }
    }
}
