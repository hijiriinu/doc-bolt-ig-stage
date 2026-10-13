import SwiftUI

@MainActor
struct RemediesView: View {
    @EnvironmentObject private var status: StatusModel

    var body: some View {
        Page(title: "対処法", subtitle: "標準機能だけでできる3つの方法") {
            Card(title: "1. ステージマネージャを一時的にオフにする", systemImage: "power") {
                StepList(steps: GuideContent.disableSteps)
                HStack {
                    Button(status.stageManagerEnabled ? "今すぐオフにする" : "現在オフです") {
                        status.setStageManager(false)
                    }
                    .disabled(!status.stageManagerEnabled)
                    Button("「デスクトップとDock」を開く") {
                        SystemActions.openDesktopAndDockSettings()
                    }
                }
            }

            Card(title: "2. 標準のタイル表示を使う", systemImage: "rectangle.split.2x1") {
                if !status.os.hasNativeTiling {
                    Label("お使いの\(status.os.displayName)には標準のタイル表示がありません。macOS 15以降にするか、代替ツールを使ってください。",
                          systemImage: "exclamationmark.triangle")
                        .foregroundStyle(.orange)
                }
                StepList(steps: GuideContent.tilingSteps)
                Divider()
                Text("ショートカット（macOS 15以降）").font(.subheadline.bold())
                ShortcutTable(shortcuts: GuideContent.tilingShortcuts)
                Text("ショートカットはOSのバージョンやキーボード設定により異なる場合があります。メニューの「ウインドウ」>「移動とサイズ変更」で表示されるキーが正です。")
                    .font(.caption).foregroundStyle(.secondary)
            }

            Card(title: "3. 操作スペース（Spaces）で作業を分ける", systemImage: "square.on.square") {
                StepList(steps: GuideContent.spacesSteps)
                Divider()
                ShortcutTable(shortcuts: GuideContent.spacesShortcuts)
                HStack {
                    Button("Mission Controlを開く") { SystemActions.openMissionControl() }
                    Button("キーボード設定を開く") { SystemActions.openKeyboardSettings() }
                }
            }
        }
    }
}
