import AppKit
import SwiftUI

@main
@MainActor
struct StageManagerGuideApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @StateObject private var status = StatusModel()

    var body: some Scene {
        Window("StageManager診断ガイド", id: "main") {
            ContentView()
                .environmentObject(status)
                .frame(minWidth: 880, minHeight: 580)
        }

        MenuBarExtra("ウインドウ管理", systemImage: "rectangle.3.group") {
            MenuBarContent()
                .environmentObject(status)
        }
    }
}

final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        // swift run で起動した場合もDockに表示し、前面に出す
        NSApp.setActivationPolicy(.regular)
        NSApp.activate(ignoringOtherApps: true)
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        // メニューバーから操作できるよう、ウインドウを閉じても終了しない
        false
    }
}
