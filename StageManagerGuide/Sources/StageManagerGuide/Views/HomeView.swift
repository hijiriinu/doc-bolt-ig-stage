import SwiftUI

@MainActor
struct HomeView: View {
    @EnvironmentObject private var status: StatusModel
    @Binding var selection: AppSection?

    var body: some View {
        Page(title: "ホーム", subtitle: "今の状態を確認し、よく使う切り替えをここで済ませる") {
            statusCard
            quickControlsCard
            if status.os.hasNativeTiling {
                tilingCard
            }
            shortcutsCard
            nextStepCard
        }
    }

    // MARK: 現在の状態

    private var statusCard: some View {
        Card(title: "現在の状態", systemImage: "info.circle") {
            Grid(alignment: .leading, horizontalSpacing: 24, verticalSpacing: 10) {
                GridRow {
                    Text("ステージマネージャ").foregroundStyle(.secondary)
                    HStack(spacing: 6) {
                        Circle()
                            .fill(status.stageManagerEnabled ? Color.green : Color.secondary)
                            .frame(width: 10, height: 10)
                        Text(status.stageManagerEnabled ? "オン" : "オフ").bold()
                        if !status.stageManagerKeyFound {
                            Text("（設定値なし＝既定のオフと判定）")
                                .font(.caption).foregroundStyle(.secondary)
                        }
                    }
                }
                GridRow {
                    Text("左のアプリ一覧").foregroundStyle(.secondary)
                    Text(status.stripHidden ? "隠す" : "表示")
                }
                GridRow {
                    Text("macOS").foregroundStyle(.secondary)
                    Text(status.os.displayName)
                }
                GridRow {
                    Text("標準タイル表示").foregroundStyle(.secondary)
                    Text(status.os.hasNativeTiling ? "利用可能（macOS 15以降）" : "非対応（Rectangle等の利用を推奨）")
                }
                GridRow {
                    Text("画面上のウインドウ").foregroundStyle(.secondary)
                    Text("\(status.visibleWindowCount) 個（\(status.visibleAppCount) アプリ）")
                }
            }
            HStack {
                Text("更新: \(status.lastUpdated.formatted(date: .omitted, time: .standard))")
                    .font(.caption).foregroundStyle(.secondary)
                Spacer()
                Button {
                    status.refresh()
                } label: {
                    Label("再読み込み", systemImage: "arrow.clockwise")
                }
            }
            Text("状態は com.apple.WindowManager の設定値と画面上のウインドウ一覧から推定しています（ウインドウ名や内容は読み取りません）。")
                .font(.caption).foregroundStyle(.secondary)
        }
    }

    // MARK: クイック操作

    private var quickControlsCard: some View {
        Card(title: "クイック操作", systemImage: "bolt") {
            Toggle(isOn: Binding(
                get: { status.stageManagerEnabled },
                set: { status.setStageManager($0) }
            )) {
                VStack(alignment: .leading) {
                    Text("ステージマネージャ")
                    Text("必要な時だけオンにする運用がおすすめ").font(.caption).foregroundStyle(.secondary)
                }
            }
            .toggleStyle(.switch)

            Toggle(isOn: Binding(
                get: { status.stripHidden },
                set: { status.setStripHidden($0) }
            )) {
                VStack(alignment: .leading) {
                    Text("左のアプリ一覧を隠す")
                    Text("画面を広く使う。左端にポインタを寄せると表示").font(.caption).foregroundStyle(.secondary)
                }
            }
            .toggleStyle(.switch)
            .disabled(!status.stageManagerEnabled)

            Divider()

            HStack {
                Button {
                    SystemActions.openMissionControl()
                } label: {
                    Label("Mission Control", systemImage: "rectangle.3.group")
                }
                Button {
                    SystemActions.openDesktopAndDockSettings()
                } label: {
                    Label("「デスクトップとDock」設定", systemImage: "gearshape")
                }
            }

            if let message = status.message {
                Text(message).font(.caption).foregroundStyle(.secondary)
            }
        }
    }

    // MARK: タイル表示（macOS 15+）

    private var tilingCard: some View {
        Card(title: "標準タイル表示の設定", systemImage: "rectangle.split.2x1") {
            tilingToggle(.tilingByEdgeDrag, "画面端へのドラッグでタイル表示")
            tilingToggle(.topTilingByEdgeDrag, "メニューバーへのドラッグで画面いっぱいに")
            tilingToggle(.tilingOptionAccelerator, "Optionを押しながらドラッグでタイル表示")
            tilingToggle(.tiledWindowMargins, "タイル表示したウインドウの間に余白をつける")
        }
    }

    private func tilingToggle(_ key: WindowManagerPrefs.Key, _ label: String) -> some View {
        Toggle(label, isOn: Binding(
            get: { status.tiling[key] ?? true },
            set: { status.setTiling(key, $0) }
        ))
        .toggleStyle(.switch)
    }

    // MARK: ショートカット

    private var shortcutsCard: some View {
        Card(title: status.os.hasNativeTiling ? "画面分割のショートカット" : "ウインドウ操作のショートカット",
             systemImage: "keyboard") {
            ShortcutTable(shortcuts: status.os.hasNativeTiling
                ? GuideContent.tilingShortcuts
                : GuideContent.spacesShortcuts)
        }
    }

    private var nextStepCard: some View {
        Card(title: "次の一手", systemImage: "arrow.right.circle") {
            Text("使いにくさの原因が分からない場合は、質問に答えるだけの診断から始めてください。")
            HStack {
                Button("診断をはじめる") { selection = .diagnosis }
                    .buttonStyle(.borderedProminent)
                Button("代替ツールを見る") { selection = .alternatives }
            }
        }
    }
}
