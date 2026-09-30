import SwiftUI

/// 頂部精簡文字顯示區：單行、可左右捲動，右側有「刪除」「清除」。
struct TextDisplayView: View {
    let committed: String
    let composition: String
    let pending: String
    let onDelete: () -> Void
    let onClear: () -> Void

    private let endID = "end"

    var body: some View {
        HStack(spacing: 12) {
            ScrollViewReader { proxy in
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 0) {
                        Text(committed)
                        // 還可以換字的部分加底線
                        Text(composition).underline()
                        Text(pending).foregroundStyle(Constants.Colors.pendingText)
                        Color.clear.frame(width: 1).id(endID)
                    }
                    .font(.system(size: Constants.Display.fontSize))
                    .lineLimit(1)
                    .padding(.horizontal, 16)
                    .frame(maxHeight: .infinity)
                }
                .onChange(of: committed + composition + pending) {
                    proxy.scrollTo(endID, anchor: .trailing)
                }
            }
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 12).fill(Constants.Colors.panel)
            )

            ControlButton(title: "刪除", systemImage: "delete.left", action: onDelete)
                .frame(width: 120)
            ControlButton(title: "清除", systemImage: "trash", action: onClear)
                .frame(width: 120)
        }
        .frame(height: Constants.Display.height)
    }
}
