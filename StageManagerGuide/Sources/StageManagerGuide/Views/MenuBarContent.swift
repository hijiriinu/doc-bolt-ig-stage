import AppKit
import SwiftUI

/// メニューバーから素早く切り替えるためのメニュー。
@MainActor
struct MenuBarContent: View {
    @EnvironmentObject private var status: StatusModel
    @Environment(\.openWindow) private var openWindow

    var body: some View {
        Text("ステージマネージャ: \(status.stageManagerEnabled ? "オン" : "オフ")")
        Button(status.stageManagerEnabled ? "ステージマネージャをオフ" : "ステージマネージャをオン") {
            status.setStageManager(!status.stageManagerEnabled)
        }
        .keyboardShortcut("s")
        if status.stageManagerEnabled {
            Button(status.stripHidden ? "左のアプリ一覧を表示" : "左のアプリ一覧を隠す") {
                status.setStripHidden(!status.stripHidden)
            }
        }
        Divider()
        Button("Mission Control") { SystemActions.openMissionControl() }
        Button("「デスクトップとDock」設定…") { SystemActions.openDesktopAndDockSettings() }
        Divider()
        Button("ガイドを開く") {
            openWindow(id: "main")
            NSApp.activate(ignoringOtherApps: true)
        }
        Button("状態を再読み込み") { status.refresh() }
        Divider()
        Button("終了") { NSApp.terminate(nil) }
            .keyboardShortcut("q")
    }
}
