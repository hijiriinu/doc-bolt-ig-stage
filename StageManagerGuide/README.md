# StageManager診断ガイド（仮）

ステージマネージャ・画面分割・操作スペース（Spaces）を **自分の作業効率が上がる形で使い分ける** ための macOS ネイティブアプリ（SwiftUI）。
状態確認とワンクリック切替を中心に、解説・対処法・代替ツール・簡易診断をまとめています。

## 動作環境

- macOS 13 Ventura 以降（標準タイル表示の設定は macOS 15 Sequoia 以降で表示）
- ビルド: Xcode 15 以降（Swift 5.9 以降）

## 起動方法

### いちばん簡単（Xcode）
1. `Package.swift` をダブルクリックして Xcode で開く
2. 上部のスキームで `StageManagerGuide` / `My Mac` を選び、▶︎（⌘R）

### ターミナル
```bash
cd StageManagerGuide
swift run                      # すぐ試す
./scripts/build-app.sh         # build/StageManagerGuide.app を作成
cp -R build/StageManagerGuide.app /Applications/
```

## 機能

| 画面 | 内容 |
|---|---|
| ホーム | ステージマネージャのオン/オフ検出、macOSバージョン、画面上のウインドウ数。ステージマネージャ・左のアプリ一覧・標準タイル表示（15+）をその場で切替。分割ショートカット早見表 |
| 解説 | 仕組み／報告されている問題／考えられる原因を「確立・有力・推測」のラベル付きで表示 |
| 対処法 | ステージマネージャのオフ手順、標準タイル表示、操作スペースの活用 |
| 代替ツール | Rectangle・Magnet・BetterTouchTool・Raycast・Amethyst の比較、公式サイト、Homebrewコマンドのコピー |
| 診断 | はい/いいえ（Y/Nキー対応）7問 → 推奨アクションを優先順に表示し、その場で実行 |
| メニューバー | ステージマネージャ切替、Mission Control、設定を開く |

## 仕組みと注意

- 状態は `com.apple.WindowManager` の設定値（`GloballyEnabled` など）を読んで判定しています。切替は `defaults write` と同じ方法で行います。**いずれもAppleの非公開仕様**のため、OSアップデートで効かなくなる可能性があります。その場合は「デスクトップとDock」から変更してください。
- ウインドウ数は `CGWindowListCopyWindowInfo` で数えるだけで、ウインドウ名・内容は読み取りません（画面収録権限は不要）。
- アクセシビリティ権限は使いません。ネットワーク通信・個人情報の収集はありません。
- App Sandbox は無効です（他アプリの設定ドメインを読むため）。Mac App Store 配布を目指す場合は設計の見直しが必要です。
