# 個人用agent設定の配布

`default.nix`をCUI/GUIの両Home Managerプロファイルから読み込む。NiriはGUIを継承する。共通方針は`user.md`、用途別の手順は`skills/`を配布元とする。

| 配布先 | 内容・読み込み |
|---|---|
| `~/.claude/CLAUDE.md` | Claude Codeのユーザー共通方針 |
| `~/.codex/AGENTS.md` | Codexのユーザー共通方針。標準のCODEX_HOMEを使う環境が対象 |
| `~/.agents/skills/analyze-workflow-harness/SKILL.md` | Codexが発見するユーザースキル |
| `~/.claude/skills/analyze-workflow-harness/SKILL.md` | Claude Codeが発見する同一内容のユーザースキル |

各配布先は同じリポジトリ内の原本を参照し、ユーザー名やホームの絶対パスに依存しない。スキルは常時全文を読み込む共通方針ではなく、履歴分析・ハーネス改善を依頼されたときに使う。Codex用に`.codex/skills`への重複登録は追加しない。別途導入したシステム/プラグインのスキル、認証情報、権限設定、hooks、外部接続は管理・変更しない。

手動導入済みの`find-skills`、`herdr`、同期/プラグインのスキルは今回の標準配布へコピーしない。外部スキルの追加は、用途・適用環境・配布元・更新方法を個別に確認する。Herdrのような環境依存の手順を、すべての作業へ常時適用する共通方針にはしない。

対象はこのdotfilesのHome Manager設定を適用するローカルのClaude Code/Codex環境。クラウドセッション、コンテナ、独自のCODEX_HOME、dotfiles未適用の端末へ自動で届くわけではない。

## 全環境へ配る内容の基準

- 共通方針には、会話・スコープ・完了・根拠・個人の実装上の好みを短く置く。
- プロジェクトの環境構築、検証コマンド、配布手順、業務制約はプロジェクト側に置く。READMEを指示階層の絶対的権威にはしない。
- 特定作業の詳しい手順は、適用範囲が分かるスキルに置く。今回の会話や競技ログを配布ファイルへ埋め込まない。
- 訂正のたびに共通規則を増やさない。繰り返す必要性、既存規則との重複・矛盾、実際の読み込み先を確認する。

旧`home/config/claude/user.md`から、毎回の改善提案・効果時間の見積もり、固定のExplore/Plan/Code/Commit、READMEの絶対視、一律の設計方式/検証手法、次工程への一律停止、修正のたびの指示ファイル自動追記を除いた。FP・型による制約・日本語・Git公開の承認・人間によるマージ判断などの好みは維持し、作業の目的と完了条件へ結び付けた。

## 確認と適用

リポジトリの変更だけでは現在のセッションの共通方針は変わらない。Home Managerを含む通常のレビュー・配布経路で適用する。システムのswitchやサービス操作は、この設定を編集しただけでは実行しない。

初回適用前に、上記の配布先と`~/.codex/skills/analyze-workflow-harness`を確認する。今回ローカルに作成したスキルや手動symlinkが残っている端末では、Home Managerの既存ファイル衝突が起こり得る。内容を比較して必要な変更を配布元へ取り込んでから、既存のHome Managerバックアップ手順で移行する。`force = true`で未管理ファイルを上書きしない。既存の`.codex/skills`側の登録はこのモジュールでは削除しない。

適用後は新しいセッションで確認する。

1. Claude Codeの`/memory`とCodexの指示元表示で、ユーザー共通ファイルを読み込むことを確認する。
2. 両CLIで`analyze-workflow-harness`が発見できることを確認する。重複する手動登録があれば、配布済みの内容を確認してから整理する。
3. 通常の実装依頼では履歴分析を開始せず、合意した成果物の検証まで進むことを確認する。分析依頼では代表事例と実成果を照合し、未確認の効果を成功扱いしないことを確認する。

Nixの評価とスキルの形式検証は、配布先とファイル形式を確認するためのもの。agentの行動改善は、実際の新規案件での成果と人間の負担を見て判断する。

配置仕様は[OpenAIのAGENTS.md](https://learn.chatgpt.com/docs/agent-configuration/agents-md)、[OpenAIのスキル](https://learn.chatgpt.com/docs/build-skills)、[Claude Codeのメモリ](https://code.claude.com/docs/en/memory)、[Claude Codeのスキル](https://code.claude.com/docs/en/skills)を参照。
