import SwiftUI

@MainActor
struct ExplanationView: View {
    var body: some View {
        Page(title: "解説", subtitle: "なぜステージマネージャが使いにくくなったのか") {
            ConfidenceLegend()

            Card(title: "前提となる仕組み", systemImage: "square.stack.3d.up") {
                items(GuideContent.background)
            }
            Card(title: "アップデート後によく報告されている問題", systemImage: "exclamationmark.bubble") {
                items(GuideContent.commonIssues)
                Text("報告内容はOSのバージョンや環境（外部ディスプレイ、ウインドウ数）で差があります。")
                    .font(.caption).foregroundStyle(.secondary)
            }
            Card(title: "考えられる原因", systemImage: "questionmark.circle") {
                items(GuideContent.causes)
            }
        }
    }

    private func items(_ list: [InfoItem]) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            ForEach(list) { InfoItemRow(item: $0) }
        }
    }
}
