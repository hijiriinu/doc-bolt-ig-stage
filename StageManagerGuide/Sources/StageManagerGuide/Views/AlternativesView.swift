import SwiftUI

@MainActor
struct AlternativesView: View {
    @State private var copied: String?

    var body: some View {
        Page(title: "代替ツール", subtitle: "画面分割をもっと速くするアプリ") {
            Card(title: "迷ったら", systemImage: "hand.thumbsup") {
                Text("まずは **Rectangle**（無料）。左右分割・4分割がショートカット一発でできれば、ステージマネージャなしでも多くの作業は回ります。macOS 15以降なら、標準のタイル表示を試してからでも遅くありません。")
                    .fixedSize(horizontal: false, vertical: true)
            }

            comparisonTable

            ForEach(GuideContent.tools) { tool in
                toolCard(tool)
            }

            Card(title: "インストール方法", systemImage: "arrow.down.circle") {
                StepList(steps: [
                    "公式サイトからダウンロード（各カードの「公式サイト」ボタン）",
                    "Homebrewを使っている場合は、カードのコマンドをコピーしてターミナルに貼り付け",
                    "初回起動時に「システム設定」>「プライバシーとセキュリティ」>「アクセシビリティ」で許可する",
                    "同じショートカットを複数のツールに割り当てないよう、使うツールは1つに絞る",
                ])
                Text("※ 価格・機能は変わることがあります。導入前に公式サイトで確認してください。")
                    .font(.caption).foregroundStyle(.secondary)
            }
        }
    }

    private var comparisonTable: some View {
        Card(title: "比較", systemImage: "tablecells") {
            Grid(alignment: .leading, horizontalSpacing: 20, verticalSpacing: 8) {
                GridRow {
                    Text("ツール").bold()
                    Text("価格").bold()
                    Text("向いている人").bold()
                }
                Divider().gridCellUnsizedAxes(.horizontal)
                row("標準タイル表示", "無料（macOS 15+）", "追加アプリを入れたくない")
                row("Rectangle", "無料", "まず試したい・軽さ重視")
                row("Magnet", "有料", "App Storeで手軽に済ませたい")
                row("BetterTouchTool", "有料", "ジェスチャまで作り込みたい")
                row("Raycast", "無料〜", "ランチャーと一緒に使いたい")
                row("Amethyst", "無料", "自動整列が好みの上級者")
            }
        }
    }

    private func row(_ a: String, _ b: String, _ c: String) -> some View {
        GridRow {
            Text(a)
            Text(b).foregroundStyle(.secondary)
            Text(c)
        }
    }

    private func toolCard(_ tool: AlternativeTool) -> some View {
        Card {
            HStack(alignment: .firstTextBaseline) {
                Text(tool.name).font(.title3.bold())
                Text(tool.price).font(.callout).foregroundStyle(.secondary)
                Spacer()
                if let url = URL(string: tool.url) {
                    Link("公式サイト", destination: url)
                }
            }
            Text(tool.summary).fixedSize(horizontal: false, vertical: true)
            VStack(alignment: .leading, spacing: 4) {
                ForEach(tool.strengths, id: \.self) { s in
                    Label(s, systemImage: "checkmark").foregroundStyle(.primary)
                }
            }
            Text("注意: \(tool.caveats)").font(.callout).foregroundStyle(.secondary)
            if let brew = tool.brew {
                HStack {
                    Text(brew)
                        .font(.system(.callout, design: .monospaced))
                        .textSelection(.enabled)
                    Spacer()
                    Button(copied == brew ? "コピーしました" : "コピー") {
                        SystemActions.copyToPasteboard(brew)
                        copied = brew
                    }
                }
                .padding(8)
                .background(Color.secondary.opacity(0.1), in: RoundedRectangle(cornerRadius: 6))
            }
        }
    }
}
