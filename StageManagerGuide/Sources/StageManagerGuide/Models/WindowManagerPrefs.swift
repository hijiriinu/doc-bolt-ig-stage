import Foundation

/// com.apple.WindowManager ドメインの読み書き。
/// キー名はAppleの非公開仕様のため、OSアップデートで変わる可能性がある（ヒューリスティック扱い）。
enum WindowManagerPrefs {
    static let domainName = "com.apple.WindowManager"
    private static var domain: CFString { domainName as CFString }

    enum Key: String {
        /// ステージマネージャのオン／オフ
        case globallyEnabled = "GloballyEnabled"
        /// 左側のアプリ一覧（ストリップ）を隠す
        case autoHide = "AutoHide"
        /// macOS 15以降：画面端へのドラッグでタイル表示
        case tilingByEdgeDrag = "EnableTilingByEdgeDrag"
        /// macOS 15以降：メニューバーへのドラッグで全画面化
        case topTilingByEdgeDrag = "EnableTopTilingByEdgeDrag"
        /// macOS 15以降：Optionキーを押しながらドラッグでタイル表示
        case tilingOptionAccelerator = "EnableTilingOptionAccelerator"
        /// macOS 15以降：タイル表示したウインドウ間の余白
        case tiledWindowMargins = "EnableTiledWindowMargins"
    }

    static func bool(_ key: Key) -> Bool? {
        CFPreferencesAppSynchronize(domain)
        guard let value = CFPreferencesCopyAppValue(key.rawValue as CFString, domain) else {
            return nil
        }
        return (value as? NSNumber)?.boolValue
    }

    /// `defaults write` 経由で書き込む（ターミナルで実行するのと同じ挙動）。
    @discardableResult
    static func set(_ key: Key, _ value: Bool) -> Bool {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/defaults")
        process.arguments = ["write", domainName, key.rawValue, "-bool", value ? "true" : "false"]
        do {
            try process.run()
            process.waitUntilExit()
            return process.terminationStatus == 0
        } catch {
            return false
        }
    }
}
