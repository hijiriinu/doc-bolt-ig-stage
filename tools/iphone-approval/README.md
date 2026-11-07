# iPhone承認ブリッジ（Claude Code / Codex）

AIエージェントが「このコマンドを実行していい？」と承認を求めたとき、iPhoneに **✅承認 / ⛔拒否** ボタン付きの通知が届き、タップするとMac側の処理がそのまま進む仕組みです。

## しくみ

```
Claude Code / Codex ──(PermissionRequestフック)──▶ approve.py ──▶ ntfy.sh ──▶ iPhone通知
        ▲                                              │                         │
        └───────── allow / deny を返す ◀── 返信を待つ ◀── ntfy.sh ◀── ボタンをタップ
```

- サーバー構築・ポート開放・Tailscaleは不要です。Mac と iPhone はどちらも ntfy.sh に外向きで通信するだけです。
- 使うのは Python 標準ライブラリだけです（Mac の `python3` で動きます）。
- 応答がない、ネットにつながらないといった異常時は何も返さず、Mac 側の通常の承認画面に戻ります。**勝手に承認することはありません。**

## セットアップ（5分）

1. Mac のターミナルで実行します。
   ```bash
   bash tools/iphone-approval/setup.sh
   ```
   最後に表示される `appr-req-…` のトピック名を控えてください。
2. iPhone に App Store から **ntfy** をインストールします。「＋」→「Subscribe to topic」で、そのトピック名を登録します（サーバーは ntfy.sh のまま）。
3. テストします。
   ```bash
   python3 ~/.local/share/iphone-approval/approve.py --test
   ```
   iPhone でボタンを押し、結果がターミナルに表示されれば成功です。
4. Claude Code と Codex を起動し直すと有効になります。

解除するときは `bash tools/iphone-approval/setup.sh --uninstall` を実行します（既存の設定はバックアップを作ってから書き換えます）。

## 設定（`~/.config/iphone-approval/config.json`）

| 項目 | 既定値 | 意味 |
|---|---|---|
| `timeout_seconds` | 300 | iPhone の応答を待つ秒数 |
| `on_timeout` | `"ask"` | 時間切れのとき。`"ask"` は Mac の承認画面に戻す、`"deny"` は拒否する |
| `only_when_idle_seconds` | 0 | 例えば 120 にすると、Mac を直近2分以内に操作していればiPhoneに送らず Mac で承認する（席にいるときの二度手間防止） |
| `token` | 空 | ntfy の有料プランで予約トピックを使う場合のアクセストークン |

## 注意点

- **トピック名がパスワードの代わりです。** 知られると第三者が承認ボタンを押せてしまうため、公開しないでください。setup.sh はランダムな長い名前を自動で作ります。
- 通知本文には実行予定のコマンドが入り、ntfy.sh（第三者のサーバー）を経由します。**院内データ・患者情報を扱う作業では使わないでください**（副業用途を想定しています）。
- iPhone で待っているあいだ、Mac 側の承認画面は表示されません。席にいるときは `only_when_idle_seconds` の設定をおすすめします。
- Antigravity は外部から承認を返す仕組み（フック）が現時点で確認できていないため、対象外です。
