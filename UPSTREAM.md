# 上游出處

[English](UPSTREAM.en.md)

whetstone 是 [mattpocock/skills](https://github.com/mattpocock/skills) 的 fork，起點是 commit `5beb35b`（v1.3.1，2026-10-19），在這個 repo 裡標為 tag `upstream-base`。保留了完整的 git 歷史，但不在 GitHub 的 fork network 裡，也不設 upstream remote。

## 各 skill 的來源

| whetstone | 上游 | 處理方式 |
|---|---|---|
| grill | grill-me、grill-with-docs、grilling | 三個合併成一個 |
| to-spec | to-spec | 改寫 |
| to-tickets | to-tickets | 改寫，改用 sub-issue 與 blocked by |
| implement | implement、implement-spec | 兩個合併成一個 |
| pr | pr | 改寫 |
| review | code-review | 改名並改寫 |
| commit | 無 | 新寫 |
| tdd | tdd | 改寫，加上綠燈後重構 |
| diagnosing-bugs | diagnosing-bugs | 改寫 |
| domain-modeling | domain-modeling | 改寫 |
| codebase-design | codebase-design | 改寫 |
| writing-for-agents | writing-for-agents | 改寫 |
| improve-codebase-architecture | improve-codebase-architecture | 改寫 |
| handoff | handoff | 改寫 |
| retro | retro | 改寫 |
| setup-whetstone | setup-matt-pocock-skills | 重寫，不再寫入專案檔案 |

## 沒有帶過來的

- skill：ask-matt、wayfinder、teach、to-questionnaire、wizard、triage、prototype、research、wait-what，以及 misc、in-progress、deprecated 底下的全部。
- GitLab 與本機文件的 issue tracker 支援。
- triage 用的 label 與 `docs/agents/` 底下的設定檔。
- 其他 agent 的設定（`agents/openai.yaml`）、文件網站、changesets 與發版流程。

## 追蹤上游

在 mattpocock/skills 設了 Watch → Releases。上游有新版時：

```bash
git fetch https://github.com/mattpocock/skills main
git log --oneline upstream-base..FETCH_HEAD
```

有值得採用的改動就重新改寫，並在下方記錄。

## 已採用的上游改動

（目前沒有）
