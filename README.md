# whetstone

[English](README.en.md)

給 Claude Code 用的個人 skill 組，只支援 GitHub。從 [mattpocock/skills](https://github.com/mattpocock/skills) fork 出來後改寫，出處與差異見 [UPSTREAM.md](UPSTREAM.md)。

設計重點：

- 不在專案裡寫設定檔。repo 資訊由腳本偵測，偵測不到的才問一次，存進 Claude Code 的 auto memory。
- issue 狀態不用 label，改用 GitHub 原生的 sub-issue、blocked by、assignee 與 PR 連結判斷。
- 每個 skill 都能在新的 session 單獨執行，狀態都在 GitHub 和 git 上。

## 安裝

每台電腦做一次：

```bash
gh auth login
git clone git@github.com:tedliou/whetstone.git
```

接著把 skill 連到 `~/.claude/skills`。macOS 與 Linux 用 symlink，Windows 用 junction（不需要系統管理員權限）：

```bash
bash whetstone/scripts/link.sh
```

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File whetstone/scripts/link.ps1
```

最後在 Claude Code 執行 `/setup-whetstone`，寫入輸出風格與危險指令的 deny 規則。之後在 repo 裡 `git pull` 就會更新所有 skill。

## 主流程

```
/grill -> /to-spec -> /to-tickets -> /implement -> /pr -> 你在 GitHub merge
```

每一步結束時會問要不要接著做下一步，回「好」就繼續。也可以隨時單獨呼叫任何一步。

| 步驟 | 結果 |
|---|---|
| grill | 問清楚需求；需要時更新 GLOSSARY.md 與 docs/adr/（先不 commit） |
| to-spec | 建立 spec issue |
| to-tickets | 建立 sub-issue（ticket）與 blocked by 關係，標出 checkpoint |
| implement | 認領 ticket、開分支、實作、逐張 commit |
| pr | 跑 review，問過你之後 push 並開 PR，本文寫 `Closes #n` |

PR merge 進預設分支時，GitHub 會自動關閉 spec 與所有 ticket。

## Skill 清單

Claude 也能自動呼叫的：

| Skill | 用途 |
|---|---|
| [grill](skills/grill/SKILL.md) | 逐題追問計畫或想法，直到雙方理解一致 |
| [to-spec](skills/to-spec/SKILL.md) | 把討論結果寫成 spec issue |
| [to-tickets](skills/to-tickets/SKILL.md) | 把 spec 拆成可以獨立交付的 ticket |
| [implement](skills/implement/SKILL.md) | 實作一張 ticket 或整份 spec |
| [pr](skills/pr/SKILL.md) | review 後開 PR |
| [review](skills/review/SKILL.md) | 依規範與 spec 檢查一段變更 |
| [commit](skills/commit/SKILL.md) | 只 stage 本次變更，寫 Conventional Commits 訊息 |
| [tdd](skills/tdd/SKILL.md) | 先寫測試再實作，綠燈後重構 |
| [diagnosing-bugs](skills/diagnosing-bugs/SKILL.md) | 難解 bug 與效能退化的診斷流程 |
| [domain-modeling](skills/domain-modeling/SKILL.md) | 整理術語，維護 GLOSSARY.md 與 ADR |
| [codebase-design](skills/codebase-design/SKILL.md) | 設計深模組與 seam 的共用詞彙 |
| [writing-for-agents](skills/writing-for-agents/SKILL.md) | 撰寫 skill、CLAUDE.md 這類給 agent 讀的文件 |

只有你能呼叫的：

| Skill | 用途 |
|---|---|
| [improve-codebase-architecture](skills/improve-codebase-architecture/SKILL.md) | 找出可以加深的模組，提出架構改善 |
| [handoff](skills/handoff/SKILL.md) | 把目前進度整理成交接文件，給下一個 session |
| [retro](skills/retro/SKILL.md) | 回顧這次 session，找出 skill 或流程可以改的地方 |
| [setup-whetstone](skills/setup-whetstone/SKILL.md) | 新電腦設定一次 |

## 授權

MIT。保留 Matt Pocock 的原始版權，見 [LICENSE](LICENSE)。
