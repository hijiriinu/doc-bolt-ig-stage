# ローカルでのビルド手順（StageManager診断ガイド）

Macで初めてビルドし、動くことを確認するまでの手順です。
所要時間の目安は、Xcodeがすでに入っていれば10分、入っていなければ1時間ほどです（ほとんどがダウンロード待ち）。

## 1. 準備（初回のみ）

1. App Storeで **Xcode** をインストールし、一度起動して利用許諾に同意します。追加コンポーネントの導入を求められたら許可してください。
2. ターミナルで次を実行し、Swiftが使えることを確認します。

```bash
xcode-select -p      # /Applications/Xcode.app/Contents/Developer と出ればOK
swift --version      # 5.9 以上ならOK
```

`xcode-select -p` の結果が `CommandLineTools` になっている場合は、次を実行してください。

```bash
sudo xcode-select -s /Applications/Xcode.app/Contents/Developer
```

## 2. コードを取得する

```bash
cd ~/Developer        # 置き場所は任意（無ければ mkdir ~/Developer）
git clone -b claude/stage-manager-guide https://github.com/hijiriinu/doc-bolt-ig-stage.git
cd doc-bolt-ig-stage/StageManagerGuide
```

## 3. ビルドして起動する

方法は2つあり、どちらでも構いません。

### A. ターミナル（おすすめ）

```bash
./scripts/build-app.sh
open build/StageManagerGuide.app
```

`build/StageManagerGuide.app` ができれば成功です。常用する場合は次でアプリケーションフォルダに入れます。

```bash
cp -R build/StageManagerGuide.app /Applications/
```

### B. Xcode

1. `Package.swift` をダブルクリックしてXcodeで開きます。
2. 画面上部の実行先が `StageManagerGuide` ＞ `My Mac` になっていることを確認します。
3. ⌘R で実行します。

## 4. 動作確認チェックリスト

起動したら、上から順に確認してください。

- [ ] ウインドウが開き、左のサイドバーに5項目（ホーム・解説・対処法・代替ツール・診断）が出る
- [ ] ホームの「現在の状態」で、ステージマネージャのオン／オフが実際の状態と一致している
- [ ] macOSのバージョンが正しく表示される
- [ ] ホームのスイッチでステージマネージャを切り替えると、実際の画面が切り替わる
- [ ] コントロールセンターから切り替えた後、このアプリに戻ると表示が追従している
- [ ] （macOS 15以降）「標準タイル表示の設定」が表示される
- [ ] 代替ツールの「公式サイト」でブラウザが開き、「コピー」でコマンドがコピーされる
- [ ] 診断でY／Nキーを押すと回答が進み、最後に推奨アクションが表示される
- [ ] メニューバーのアイコンから、ステージマネージャの切替と「ガイドを開く」ができる

**ステージマネージャの切替が反映されない場合**：ターミナルで次を実行し、画面が切り替わるか確認してください。切り替わらなければ、お使いのmacOSでこの方法が使えないということなので、アプリ側の切替方法を見直す必要があります。

```bash
defaults write com.apple.WindowManager GloballyEnabled -bool true    # オン
defaults write com.apple.WindowManager GloballyEnabled -bool false   # オフ
```

## 5. エラーが出たとき

ビルドエラーが出る可能性はあります（Linux環境で書いたため、一度もコンパイルしていません）。対処は次のどちらかです。

- **このチャットに貼る**：ターミナルに出たエラーを全文コピーして送ってください。修正してブランチに反映します。反映後は `git pull` してから再度 `./scripts/build-app.sh` を実行します。
- **Mac上のClaude Codeに直させる**：`StageManagerGuide` フォルダで `claude` を起動し、下のプロンプトを貼り付けます。

### Claude Code用プロンプト（そのまま貼り付け可）

```
このフォルダは SwiftUI 製の macOS アプリ「StageManager診断ガイド」(Swift Package, macOS 13+) です。
Linux 環境で書かれ、まだ一度もビルドされていません。次を順に行ってください。

1. `swift build` を実行し、コンパイルエラーと警告をすべて解消する。
   - 修正は最小限にし、機能・画面構成・日本語の文言は変えない。
   - @MainActor まわりのエラーは、StatusModel を MainActor のまま維持する方向で直す。
2. `./scripts/build-app.sh` で build/StageManagerGuide.app が作れることを確認する。
3. `open build/StageManagerGuide.app` で起動し、起動直後にクラッシュしないことを確認する。
4. 何を直したかを日本語で短くまとめ、git にコミットする（push は私が確認してから）。

注意:
- アクセシビリティ権限を必要とする実装（ウインドウの強制移動など）は追加しない。
- App Sandbox は有効にしない（com.apple.WindowManager の設定を読むため）。
```

## 6. 次に考えること（動いた後で）

- このリポジトリは画像・動画の置き場なので、アプリは専用のリポジトリ（例：`stage-manager-guide`）に移すと管理しやすくなります。
- ログイン時に自動で起動させたい場合は、「システム設定」＞「一般」＞「ログイン項目」に `/Applications/StageManagerGuide.app` を追加します。
