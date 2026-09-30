import SwiftUI

/// 選字列：引擎已經自動選好最可能的字，這裡只是「想換字時」才用，不選也能直接朗讀。
struct CandidateBarView: View {
    let candidates: [Candidate]
    let onSelect: (Candidate) -> Void

    var body: some View {
        HStack(spacing: 12) {
            Text("選字")
                .font(.system(size: Constants.ControlBar.fontSize, weight: .bold))
                .foregroundStyle(.secondary)
                .padding(.leading, 12)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(candidates) { candidate in
                        Button {
                            onSelect(candidate)
                        } label: {
                            Text(candidate.value)
                                .font(.system(size: Constants.CandidateBar.fontSize))
                                .foregroundStyle(Constants.Colors.keyText)
                                .padding(.horizontal, 20)
                                .frame(minWidth: Constants.Keyboard.minKeySize, maxHeight: .infinity)
                                .background(RoundedRectangle(cornerRadius: 10).fill(Constants.Colors.keyBackground))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10).stroke(Constants.Colors.keyBorder, lineWidth: 1)
                                )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.vertical, 6)
            }
        }
        .frame(height: Constants.CandidateBar.height)
        .background(RoundedRectangle(cornerRadius: 12).fill(Constants.Colors.panel))
    }
}
