import AppKit
import CoreGraphics
import Foundation

/// 現在のウインドウ管理まわりの状態。個人情報は扱わず、端末外へも送信しない。
@MainActor
final class StatusModel: ObservableObject {
    @Published private(set) var stageManagerEnabled: Bool = false
    @Published private(set) var stageManagerKeyFound: Bool = false
    @Published private(set) var stripHidden: Bool = false
    @Published private(set) var tiling: [WindowManagerPrefs.Key: Bool] = [:]
    @Published private(set) var visibleWindowCount: Int = 0
    @Published private(set) var visibleAppCount: Int = 0
    @Published private(set) var lastUpdated: Date = .now
    @Published var message: String?

    let os = OSInfo.current

    static let tilingKeys: [WindowManagerPrefs.Key] = [
        .tilingByEdgeDrag, .topTilingByEdgeDrag, .tilingOptionAccelerator, .tiledWindowMargins,
    ]

    private var activeObserver: NSObjectProtocol?

    init() {
        refresh()
        activeObserver = NotificationCenter.default.addObserver(
            forName: NSApplication.didBecomeActiveNotification, object: nil, queue: .main
        ) { [weak self] _ in
            Task { @MainActor in self?.refresh() }
        }
    }

    func refresh() {
        let enabled = WindowManagerPrefs.bool(.globallyEnabled)
        stageManagerKeyFound = enabled != nil
        stageManagerEnabled = enabled ?? false
        stripHidden = WindowManagerPrefs.bool(.autoHide) ?? false

        var t: [WindowManagerPrefs.Key: Bool] = [:]
        for key in Self.tilingKeys {
            // 未設定のときはmacOS 15の既定値（オン）とみなす
            t[key] = WindowManagerPrefs.bool(key) ?? true
        }
        tiling = t

        let counts = Self.countWindows()
        visibleWindowCount = counts.windows
        visibleAppCount = counts.apps
        lastUpdated = .now
    }

    func setStageManager(_ on: Bool) {
        apply(.globallyEnabled, on, done: on ? "ステージマネージャをオンにしました" : "ステージマネージャをオフにしました")
    }

    func setStripHidden(_ hidden: Bool) {
        apply(.autoHide, hidden, done: hidden ? "左のアプリ一覧を隠しました" : "左のアプリ一覧を表示にしました")
    }

    func setTiling(_ key: WindowManagerPrefs.Key, _ on: Bool) {
        apply(key, on, done: "タイル表示の設定を変更しました")
    }

    private func apply(_ key: WindowManagerPrefs.Key, _ value: Bool, done: String) {
        if WindowManagerPrefs.set(key, value) {
            message = done + "（反映されない場合は「デスクトップとDock」から変更してください）"
        } else {
            message = "設定を変更できませんでした。「デスクトップとDock」から変更してください。"
        }
        // WindowManagerが設定を拾うまで少し待ってから再読込
        Task { [weak self] in
            try? await Task.sleep(nanoseconds: 600_000_000)
            self?.refresh()
        }
    }

    /// 画面上の通常ウインドウ数（layer 0）とアプリ数。画面収録権限は不要（ウインドウ名は読まない）。
    private static func countWindows() -> (windows: Int, apps: Int) {
        let options: CGWindowListOption = [.optionOnScreenOnly, .excludeDesktopElements]
        guard let list = CGWindowListCopyWindowInfo(options, kCGNullWindowID) as? [[String: Any]] else {
            return (0, 0)
        }
        let normal = list.filter { ($0[kCGWindowLayer as String] as? Int) == 0 }
        let pids = Set(normal.compactMap { $0[kCGWindowOwnerPID as String] as? Int })
        return (normal.count, pids.count)
    }
}

struct OSInfo {
    let major: Int
    let minor: Int
    let patch: Int

    static var current: OSInfo {
        let v = ProcessInfo.processInfo.operatingSystemVersion
        return OSInfo(major: v.majorVersion, minor: v.minorVersion, patch: v.patchVersion)
    }

    var versionString: String {
        patch == 0 ? "\(major).\(minor)" : "\(major).\(minor).\(patch)"
    }

    var name: String {
        switch major {
        case 13: return "Ventura"
        case 14: return "Sonoma"
        case 15: return "Sequoia"
        case 26: return "Tahoe"
        default: return ""
        }
    }

    var displayName: String {
        name.isEmpty ? "macOS \(versionString)" : "macOS \(name) \(versionString)"
    }

    /// 標準のウインドウタイル表示（画面端ドラッグ等）は macOS 15 Sequoia 以降
    var hasNativeTiling: Bool { major >= 15 }
}
