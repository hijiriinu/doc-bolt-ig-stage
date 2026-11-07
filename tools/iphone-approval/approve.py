#!/usr/bin/env python3
"""iPhone approval bridge for AI coding agents (Claude Code / Codex).

Registered as a `PermissionRequest` hook. When the agent is about to ask for
permission, this script:

  1. publishes an ntfy notification with "承認" / "拒否" buttons,
  2. waits for the button tap (the iPhone posts the answer to a reply topic),
  3. prints the allow/deny decision in the hook JSON format both tools accept.

If anything goes wrong (no answer in time, network error, config missing) it
prints nothing and exits 0, so the agent falls back to its normal approval
prompt on the Mac. It never approves on its own.

Standard library only; works with the python3 that ships with Xcode CLT.
"""

import json
import os
import secrets
import subprocess
import sys
import time
import urllib.error
import urllib.parse
import urllib.request

CONFIG_PATH = os.path.expanduser(
    os.environ.get("IPHONE_APPROVAL_CONFIG", "~/.config/iphone-approval/config.json")
)
LOG_PATH = os.path.expanduser("~/.config/iphone-approval/approve.log")

DEFAULTS = {
    "server": "https://ntfy.sh",
    "request_topic": "",
    "response_topic": "",
    "token": "",  # ntfy access token (optional, for reserved topics)
    "timeout_seconds": 300,  # how long to wait for the iPhone
    "on_timeout": "ask",  # "ask" = fall back to Mac prompt, "deny" = reject
    "only_when_idle_seconds": 0,  # >0: skip iPhone if the Mac was used recently
}


def log(msg):
    try:
        os.makedirs(os.path.dirname(LOG_PATH), exist_ok=True)
        with open(LOG_PATH, "a", encoding="utf-8") as f:
            f.write(time.strftime("%Y-%m-%d %H:%M:%S ") + msg + "\n")
    except OSError:
        pass


def load_config():
    with open(CONFIG_PATH, encoding="utf-8") as f:
        cfg = dict(DEFAULTS)
        cfg.update(json.load(f))
    if not cfg["request_topic"] or not cfg["response_topic"]:
        raise ValueError("request_topic / response_topic が未設定です")
    cfg["server"] = cfg["server"].rstrip("/")
    return cfg


def mac_idle_seconds():
    """Seconds since last keyboard/mouse input on macOS, or None if unknown."""
    try:
        out = subprocess.run(
            ["ioreg", "-c", "IOHIDSystem"], capture_output=True, text=True, timeout=3
        ).stdout
    except (OSError, subprocess.SubprocessError):
        return None
    for line in out.splitlines():
        if '"HIDIdleTime"' in line:
            try:
                return int(line.rsplit("=", 1)[1].strip()) / 1e9
            except ValueError:
                return None
    return None


def detect_agent(payload, argv_agent):
    if argv_agent:
        return argv_agent
    return "Codex" if "turn_id" in payload else "Claude Code"


def summarize(payload):
    tool = payload.get("tool_name", "?")
    ti = payload.get("tool_input") or {}
    if isinstance(ti, dict):
        if "command" in ti:
            cmd = ti["command"]
            detail = " ".join(cmd) if isinstance(cmd, list) else str(cmd)
        elif "file_path" in ti:
            detail = str(ti["file_path"])
        elif "url" in ti:
            detail = str(ti["url"])
        else:
            detail = json.dumps(ti, ensure_ascii=False)
    else:
        detail = str(ti)
    if len(detail) > 400:
        detail = detail[:400] + "…"
    project = os.path.basename(payload.get("cwd", "").rstrip("/")) or "-"
    return tool, project, detail


def http(method, url, cfg, body=None, timeout=15):
    headers = {"User-Agent": "iphone-approval/1.0"}
    if body is not None:
        headers["Content-Type"] = "application/json"
    if cfg.get("token"):
        headers["Authorization"] = "Bearer " + cfg["token"]
    data = json.dumps(body).encode() if body is not None else None
    req = urllib.request.Request(url, data=data, headers=headers, method=method)
    return urllib.request.urlopen(req, timeout=timeout)


def publish_request(cfg, rid, agent, tool, project, detail):
    reply_url = f"{cfg['server']}/{cfg['response_topic']}"
    headers = {}
    if cfg.get("token"):
        headers["Authorization"] = "Bearer " + cfg["token"]

    def action(label, decision):
        a = {
            "action": "http",
            "label": label,
            "url": reply_url,
            "method": "POST",
            "body": json.dumps({"id": rid, "decision": decision}),
            "clear": True,
        }
        if headers:
            a["headers"] = headers
        return a

    msg = {
        "topic": cfg["request_topic"],
        "title": f"[{agent}] 承認依頼: {tool}",
        "message": f"📁 {project}\n{detail}",
        "priority": 4,
        "tags": ["raised_hand"],
        "actions": [action("✅ 承認", "allow"), action("⛔ 拒否", "deny")],
    }
    with http("POST", cfg["server"] + "/", cfg, body=msg) as r:
        r.read()


def wait_for_answer(cfg, rid, since):
    """Stream the reply topic until our request id is answered or time runs out."""
    deadline = time.time() + float(cfg["timeout_seconds"])
    query = urllib.parse.urlencode({"since": str(since)})
    url = f"{cfg['server']}/{cfg['response_topic']}/json?{query}"
    while time.time() < deadline:
        remaining = max(5.0, deadline - time.time())
        try:
            # ntfy sends a keepalive roughly every 45s, so a 60s read timeout is safe.
            with http("GET", url, cfg, timeout=min(60.0, remaining + 1)) as resp:
                for raw in resp:
                    if time.time() >= deadline:
                        return None
                    try:
                        ev = json.loads(raw)
                    except ValueError:
                        continue
                    if ev.get("event") != "message":
                        continue
                    try:
                        ans = json.loads(ev.get("message", ""))
                    except ValueError:
                        continue
                    if ans.get("id") == rid and ans.get("decision") in ("allow", "deny"):
                        return ans["decision"]
        except (urllib.error.URLError, OSError, TimeoutError) as e:
            log(f"stream reconnect: {e}")
            time.sleep(2)
    return None


def emit(behavior, message=None):
    decision = {"behavior": behavior}
    if behavior == "deny" and message:
        decision["message"] = message
    print(json.dumps({"hookSpecificOutput": {
        "hookEventName": "PermissionRequest", "decision": decision}}, ensure_ascii=False))


def main():
    argv_agent = None
    test_mode = "--test" in sys.argv
    if "--agent" in sys.argv:
        i = sys.argv.index("--agent")
        if i + 1 < len(sys.argv):
            argv_agent = sys.argv[i + 1]

    try:
        cfg = load_config()
    except (OSError, ValueError) as e:
        log(f"config error: {e}")
        if test_mode:
            print(f"設定ファイルを読めません: {CONFIG_PATH} ({e})", file=sys.stderr)
            return 1
        return 0  # fall back to the normal prompt

    if test_mode:
        payload = {"tool_name": "Bash", "cwd": os.getcwd(),
                   "tool_input": {"command": "echo 'iPhone承認のテストです'"}}
        argv_agent = argv_agent or "テスト"
    else:
        try:
            payload = json.load(sys.stdin)
        except ValueError:
            return 0

    idle_limit = float(cfg.get("only_when_idle_seconds") or 0)
    if idle_limit > 0 and not test_mode:
        idle = mac_idle_seconds()
        if idle is not None and idle < idle_limit:
            log(f"skip: Mac in use (idle {idle:.0f}s)")
            return 0

    agent = detect_agent(payload, argv_agent)
    tool, project, detail = summarize(payload)
    rid = secrets.token_hex(8)
    since = int(time.time()) - 1

    try:
        publish_request(cfg, rid, agent, tool, project, detail)
    except (urllib.error.URLError, OSError) as e:
        log(f"publish failed: {e}")
        return 0
    log(f"sent {rid} [{agent}] {tool}: {detail[:120]}")

    decision = wait_for_answer(cfg, rid, since)
    log(f"answer {rid}: {decision}")

    if test_mode:
        print({"allow": "承認されました ✅", "deny": "拒否されました ⛔"}.get(
            decision, "時間内に応答がありませんでした"))
        return 0

    if decision == "allow":
        emit("allow")
    elif decision == "deny":
        emit("deny", "ユーザーがiPhoneで拒否しました。別の方法を検討するか、理由を確認してください。")
    elif cfg.get("on_timeout") == "deny":
        emit("deny", "iPhoneでの承認が時間内に得られなかったため拒否しました。")
    return 0


if __name__ == "__main__":
    sys.exit(main())
