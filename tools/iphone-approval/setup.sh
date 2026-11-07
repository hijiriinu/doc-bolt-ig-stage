#!/usr/bin/env bash
# iPhone承認ブリッジのセットアップ（Mac用）
#   bash setup.sh            … インストールしてClaude Code / Codexにフック登録
#   bash setup.sh --uninstall … フック登録を外す（設定ファイルは残す）
set -euo pipefail

SRC_DIR="$(cd "$(dirname "$0")" && pwd)"
INSTALL_DIR="$HOME/.local/share/iphone-approval"
CONFIG_DIR="$HOME/.config/iphone-approval"
CONFIG="$CONFIG_DIR/config.json"
SCRIPT="$INSTALL_DIR/approve.py"

command -v python3 >/dev/null || { echo "python3 が見つかりません。 xcode-select --install を実行してください"; exit 1; }

MODE="install"
[[ "${1:-}" == "--uninstall" ]] && MODE="uninstall"

if [[ "$MODE" == "install" ]]; then
  mkdir -p "$INSTALL_DIR" "$CONFIG_DIR"
  cp "$SRC_DIR/approve.py" "$SCRIPT"
  chmod +x "$SCRIPT"

  if [[ ! -f "$CONFIG" ]]; then
    python3 - "$CONFIG" <<'PY'
import json, secrets, sys
cfg = {
    "server": "https://ntfy.sh",
    "request_topic": "appr-req-" + secrets.token_urlsafe(18).replace("_", "x").replace("-", "y"),
    "response_topic": "appr-res-" + secrets.token_urlsafe(18).replace("_", "x").replace("-", "y"),
    "token": "",
    "timeout_seconds": 300,
    "on_timeout": "ask",
    "only_when_idle_seconds": 0,
}
with open(sys.argv[1], "w") as f:
    json.dump(cfg, f, indent=2)
PY
    chmod 600 "$CONFIG"
    echo "設定ファイルを作成しました: $CONFIG"
  else
    echo "既存の設定ファイルを使います: $CONFIG"
  fi
fi

# Claude Code: ~/.claude/settings.json / Codex: ~/.codex/hooks.json に同じ形式で登録
python3 - "$MODE" "$SCRIPT" <<'PY'
import json, os, shutil, sys, time
mode, script = sys.argv[1], sys.argv[2]
targets = [
    (os.path.expanduser("~/.claude/settings.json"), "claude"),
    (os.path.expanduser("~/.codex/hooks.json"), "codex"),
]
for path, agent in targets:
    if not os.path.isdir(os.path.dirname(path)):
        print(f"- {agent}: {os.path.dirname(path)} が無いためスキップ（未インストール？）")
        continue
    data = {}
    if os.path.exists(path):
        with open(path) as f:
            text = f.read().strip()
        data = json.loads(text) if text else {}
        shutil.copy(path, f"{path}.bak-{time.strftime('%Y%m%d%H%M%S')}")
    hooks = data.setdefault("hooks", {})
    groups = [g for g in hooks.get("PermissionRequest", [])
              if not any("iphone-approval" in h.get("command", "") for h in g.get("hooks", []))]
    if mode == "install":
        label = "Claude Code" if agent == "claude" else "Codex"
        groups.append({  # matcher省略 = すべてのツールが対象
            "hooks": [{
                "type": "command",
                "command": f"python3 '{script}' --agent '{label}'",
                "timeout": 600,
            }],
        })
    if groups:
        hooks["PermissionRequest"] = groups
    else:
        hooks.pop("PermissionRequest", None)
        if not hooks:
            data.pop("hooks")
    with open(path, "w") as f:
        json.dump(data, f, indent=2, ensure_ascii=False)
    print(f"- {agent}: {path} " + ("に登録しました" if mode == "install" else "から登録を外しました"))
PY

if [[ "$MODE" == "install" ]]; then
  REQ_TOPIC="$(python3 -c "import json;print(json.load(open('$CONFIG'))['request_topic'])")"
  cat <<EOF

=== 次にiPhoneでやること ===
1. App Storeで「ntfy」をインストール
2. ＋ボタン →「Subscribe to topic」→ 次のトピック名を入力（サーバーは ntfy.sh のまま）
     $REQ_TOPIC
3. 通知を許可する

=== 動作テスト ===
  python3 "$SCRIPT" --test
  → iPhoneに通知が届き、ボタンを押すと結果がここに表示されます

※ トピック名はパスワードと同じ扱いです。他人に見せないでください。
EOF
fi
