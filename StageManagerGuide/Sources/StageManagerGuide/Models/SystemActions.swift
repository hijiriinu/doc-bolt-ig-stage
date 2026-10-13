import AppKit
import Foundation

/// システム設定やApple純正アプリを開く操作。
enum SystemActions {
    static func openDesktopAndDockSettings() {
        open("x-apple.systempreferences:com.apple.Desktop-Settings.extension")
    }

    static func openKeyboardSettings() {
        open("x-apple.systempreferences:com.apple.Keyboard-Settings.extension")
    }

    static func openMissionControl() {
        let url = URL(fileURLWithPath: "/System/Applications/Mission Control.app")
        NSWorkspace.shared.openApplication(at: url, configuration: NSWorkspace.OpenConfiguration())
    }

    static func open(_ string: String) {
        guard let url = URL(string: string) else { return }
        NSWorkspace.shared.open(url)
    }

    static func copyToPasteboard(_ text: String) {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(text, forType: .string)
    }
}

/// 診断結果などから直接実行できるクイック操作。
enum QuickAction: Hashable {
    case disableStageManager
    case enableStageManager
    case hideStrip
    case openDesktopSettings
    case openMissionControl
    case openURL(String)

    var label: String {
        switch self {
        case .disableStageManager: return "ステージマネージャをオフにする"
        case .enableStageManager: return "ステージマネージャをオンにする"
        case .hideStrip: return "左のアプリ一覧を隠す"
        case .openDesktopSettings: return "「デスクトップとDock」を開く"
        case .openMissionControl: return "Mission Controlを開く"
        case .openURL: return "公式サイトを開く"
        }
    }

    @MainActor
    func perform(with status: StatusModel) {
        switch self {
        case .disableStageManager: status.setStageManager(false)
        case .enableStageManager: status.setStageManager(true)
        case .hideStrip: status.setStripHidden(true)
        case .openDesktopSettings: SystemActions.openDesktopAndDockSettings()
        case .openMissionControl: SystemActions.openMissionControl()
        case .openURL(let s): SystemActions.open(s)
        }
    }
}
