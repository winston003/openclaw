#!/usr/bin/env python3
"""GitHub Watch - Monitor OpenClaw repository"""
import os
import json
import requests
from datetime import datetime, timedelta
from pathlib import Path

REPO = "openclaw/openclaw"
CACHE_DIR = Path.home() / ".openclaw-dev/github-cache"
FEISHU_WEBHOOK = os.getenv("FEISHU_WEBHOOK_URL")
SILICONFLOW_KEY = "sk-etdxbplklpnodggbjjhivuxgnoltvduqlzhcjhrdhucqgulq"

CACHE_DIR.mkdir(parents=True, exist_ok=True)

def get_last_check():
    """Get last check time"""
    last_file = CACHE_DIR / "last-check.txt"
    if last_file.exists():
        return last_file.read_text().strip()
    return (datetime.utcnow() - timedelta(hours=2)).strftime("%Y-%m-%dT%H:%M:%SZ")

def save_last_check():
    """Save current time"""
    (CACHE_DIR / "last-check.txt").write_text(datetime.utcnow().strftime("%Y-%m-%dT%H:%M:%SZ"))

def fetch_commits(since=None):
    """Fetch commits since last check"""
    url = f"https://api.github.com/repos/{REPO}/commits"
    params = {"per_page": 10}
    if since:
        params["since"] = since
    return requests.get(url, params=params).json()

def summarize_commits(commits):
    """Summarize commits with LLM"""
    messages = "\n".join([c["commit"]["message"].split("\n")[0] for c in commits[:5]])

    response = requests.post(
        "https://api.siliconflow.cn/v1/chat/completions",
        headers={"Authorization": f"Bearer {SILICONFLOW_KEY}"},
        json={
            "model": "Qwen/Qwen2.5-7B-Instruct",
            "messages": [{"role": "user", "content": f"总结以下 Git 提交，用中文，3句话以内：\n{messages}"}],
            "max_tokens": 200
        }
    )
    return response.json()["choices"][0]["message"]["content"]

def send_feishu(title, content):
    """Send to Feishu"""
    if not FEISHU_WEBHOOK:
        return
    requests.post(FEISHU_WEBHOOK, json={
        "msg_type": "text",
        "content": {"text": f"{title}\n\n{content}"}
    })

def check_updates():
    """Check for updates"""
    since = get_last_check()
    commits = fetch_commits(since)

    if commits and len(commits) > 0:
        summary = summarize_commits(commits)
        send_feishu(f"🔔 OpenClaw 更新 ({len(commits)} commits)", summary)
        save_last_check()
        print(f"✅ Found {len(commits)} updates")
    else:
        print("No updates")

def daily_summary():
    """Daily summary"""
    today = datetime.utcnow().strftime("%Y-%m-%d")
    commits = fetch_commits(f"{today}T00:00:00Z")

    if commits and len(commits) > 0:
        summary = summarize_commits(commits)
        send_feishu(f"📊 OpenClaw 今日汇总 ({len(commits)} commits)", summary)
        print(f"✅ Daily summary sent ({len(commits)} commits)")

if __name__ == "__main__":
    import sys
    cmd = sys.argv[1] if len(sys.argv) > 1 else "check"

    if cmd == "check":
        check_updates()
    elif cmd == "daily-summary":
        daily_summary()
