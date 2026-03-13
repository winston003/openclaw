#!/usr/bin/env python3
"""OpenClaw News Digest with LLM Summary"""
import os
import json
import requests
from datetime import datetime

FEISHU_WEBHOOK = os.getenv("FEISHU_WEBHOOK_URL")
SILICONFLOW_KEY = "sk-etdxbplklpnodggbjjhivuxgnoltvduqlzhcjhrdhucqgulq"

def fetch_github_data():
    """Fetch OpenClaw updates from GitHub"""
    issues = requests.get("https://api.github.com/repos/openclaw/openclaw/issues?state=open&per_page=5").json()
    commits = requests.get("https://api.github.com/repos/openclaw/openclaw/commits?per_page=5").json()

    content = "Recent Issues:\n"
    for issue in issues[:3]:
        content += f"- {issue['title']}\n"

    content += "\nRecent Commits:\n"
    for commit in commits[:3]:
        content += f"- {commit['commit']['message'].split(chr(10))[0]}\n"

    return content

def summarize_with_llm(content):
    """Summarize with Silicon Flow LLM"""
    response = requests.post(
        "https://api.siliconflow.cn/v1/chat/completions",
        headers={"Authorization": f"Bearer {SILICONFLOW_KEY}"},
        json={
            "model": "Qwen/Qwen2.5-7B-Instruct",
            "messages": [{"role": "user", "content": f"总结以下 OpenClaw 社区动态，用中文，5句话以内：\n\n{content}"}],
            "max_tokens": 300
        }
    )
    return response.json()["choices"][0]["message"]["content"]

def send_to_feishu(summary):
    """Send to Feishu"""
    if not FEISHU_WEBHOOK:
        return

    requests.post(FEISHU_WEBHOOK, json={
        "msg_type": "text",
        "content": {"text": f"📰 OpenClaw 新闻播报\n\n{summary}"}
    })

if __name__ == "__main__":
    news = fetch_github_data()
    summary = summarize_with_llm(news)
    send_to_feishu(summary)
    print("✅ News digest sent")
