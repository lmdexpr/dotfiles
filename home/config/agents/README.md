# 個人用agent設定の配布

`package.nix`が配布物の唯一の組み立て元（`CLAUDE.md`、`skills/`、固定したrevから取るherdrのスキル、`bin/publish-guard`、`bin/`の状態待ちコマンド）で、`default.nix`がこれをCUI/GUIの両Home Managerプロファイルへ配る。NiriはGUIを継承する。他のリポジトリ（コンテナイメージなど）も`pkgs.callPackage "${dotfiles}/home/config/agents/package.nix" {}`で同じものを使える。共通方針は`user.md`、用途別の手順は`skills/`を配布元とする。

| 配布先 | 内容・読み込み |
|---|---|
| `~/.claude/CLAUDE.md` | Claude Codeのユーザー共通方針 |
| `~/.codex/AGENTS.md` | Codexのユーザー共通方針。標準のCODEX_HOMEを使う環境が対象 |
| `~/.agents/skills/analyze-workflow-harness/SKILL.md` | Codexが発見するユーザースキル |
| `~/.claude/skills/analyze-workflow-harness/SKILL.md` | Claude Codeが発見する同一内容のユーザースキル |
| `~/.{agents,claude}/skills/analyze-workflow-harness/record.sh` | 分析の記録。`~/.local/share/harness-notes-local` があればそこへ書くだけ。なければ `~/.local/share/harness-notes`（git clone。なければ`HARNESS_NOTES_REPO`から作る）へ書いて push する。`--prepare`は読むべき記録のディレクトリを出力する |
| `~/.{agents,claude}/skills/herdr/SKILL.md` | herdrの公式スキル。下の「herdrスキル」を参照 |
| `~/.local/bin/publish-guard` | リモートへの書き込み前に確認するPreToolUse hook。下の「publish-guard」を参照 |
| `forgejo-wait-status`、`argocd-wait-app`（PATH） | CIやデプロイの完了待ち。下の「状態待ちコマンド」を参照 |

各配布先は同じリポジトリ内の原本を参照し、ユーザー名やホームの絶対パスに依存しない。スキルは常時全文を読み込む共通方針ではなく、履歴分析・ハーネス改善を依頼されたときに使う。Codex用に`.codex/skills`への重複登録は追加しない。別途導入したシステム/プラグインのスキル、認証情報、権限設定、hooks、外部接続は管理・変更しない（例外はpublish-guardのhook 1件）。

## publish-guard

シェルコマンドがリモートのリポジトリへ書き込む前に、宛先が許可リストにない限り確認を求める（`git push`、ghの書き込み系、fjの作成系など）。

- 対象のコマンドは`publish-guard/rules.json`。ホスト固有の追加は`~/.config/publish-guard/rules.json`に書く。宛先の割り出し方（`git-remote`、`origin`、`gh-repo`、`gh-api`、`none`）はスクリプト側にあり、新しい割り出し方が要るときだけスクリプトを変える。
- 許可リストは`~/.config/publish-guard/allow`（1行1件の`HOST/OWNER/REPO`、`*`可）。dotfilesでは管理しない。
- 宛先が分からない、許可リストがない、ルールが読めない、内部エラーのときは確認に倒す。
- `~/.claude/settings.json`と`~/.codex/hooks.json`はagent自身も書き換えるため、activationでこのhookの1件だけを追記・更新する。Codexは確認（ask）を返せないので`--strict`（拒否）で登録する。Codexではhookのtrustを初回に承認する必要がある。

外部スキルの追加は、用途・適用環境・配布元・更新方法を個別に確認する。環境依存の手順を、すべての作業へ常時適用する共通方針にはしない。

対象はこのdotfilesのHome Manager設定を適用するローカルのClaude Code/Codex環境。クラウドセッション、コンテナ、独自のCODEX_HOME、dotfiles未適用の端末へは自動で届かず、`package.nix`を導入する側が配った環境にだけ届く。

## herdrスキル

herdr（CUI/GUIの両プロファイルでnixpkgsから入れる）のペイン・エージェント操作をagentに教える、herdr公式のスキル。

- 配布元は[herdrdev/herdr](https://github.com/herdrdev/herdr)の`skills/herdr/SKILL.md`で、`package.nix`が固定したrevから`fetchurl`で取る。内容は変更しない。
- スキルはherdrのCLIを説明するので、revはnixpkgsのherdrと同じリリースのタグに合わせる。nixpkgsの更新でherdrのバージョンが変わったら、そのタグのcommitへrevとhashを更新する。
- スキル自身が`HERDR_ENV=1`（herdrのペイン内）でなければ何もしないと定めているので、herdr外の作業には影響しない。
- `npx skills`などで手動導入したものが配布先にあれば、内容を確認してから削除し、Home Managerの配布に置き換える。

## 状態待ちコマンド

push後のCIやデプロイの完了を、agentが自前のポーリングを書かずに待つためのコマンド。Home ManagerではユーザーのPATH（`home.packages`）に入り、`package.nix`を使う側では`bin/`（または`passthru.waitCommands`）をPATHに入れる。

| コマンド | 待つ対象 |
|---|---|
| `forgejo-wait-status HOST/OWNER/REPO COMMIT` | Forgejoのcommit status（Actionsなど）がすべて終わるまで。全部成功なら成功。認証は`FORGEJO_TOKEN`、なければgitのcredential helper、なければ匿名 |
| `argocd-wait-app [NAMESPACE/]APP REVISION` | Argo CDのApplicationがREVISION（前方一致）でSyncedかつHealthyになるまで。REVISIONへのsync失敗やDegradedは失敗。`kubectl get`だけを使い、kubectlは呼び出し側のPATHと設定を使う |

- 終了コードは成功0・失敗1・タイムアウト2。出力は結果の1行だけ（`success:`／`failure:`／`timeout:`で始まる）。
- `--timeout`（秒、既定1800）と`--interval`（秒、既定10）を指定できる。
- 判定はスタブを使ったテスト（`wait/test.sh`、`nix build`では`passthru.tests.wait`）で確認する。

## 全環境へ配る内容の基準

- 共通方針には、会話・スコープ・完了・根拠・個人の実装上の好みを短く置く。
- プロジェクトの環境構築、検証コマンド、配布手順、業務制約はプロジェクト側に置く。READMEを指示階層の絶対的権威にはしない。
- 特定作業の詳しい手順は、適用範囲が分かるスキルに置く。個別の会話や作業ログを配布ファイルへ埋め込まない。
- 訂正のたびに共通規則を増やさない。繰り返す必要性、既存規則との重複・矛盾、実際の読み込み先を確認する。

## 確認と適用

リポジトリの変更だけでは現在のセッションの共通方針は変わらない。Home Managerを含む通常のレビュー・配布経路で適用する。システムのswitchやサービス操作は、この設定を編集しただけでは実行しない。

初回適用前に配布先を確認する。未管理ファイルがある場合は内容を比較し、必要な変更を配布元へ取り込んでから、既存のHome Managerバックアップ手順で移行する。`force = true`で未管理ファイルを上書きしない。

適用後は新しいセッションで確認する。

1. Claude Codeの`/memory`とCodexの指示元表示で、ユーザー共通ファイルを読み込むことを確認する。
2. 両CLIで`analyze-workflow-harness`が発見できることを確認する。重複する手動登録があれば、配布済みの内容を確認してから整理する。
3. 通常の実装依頼では履歴分析を開始せず、合意した成果物の検証まで進むことを確認する。分析依頼では代表事例と実成果を照合し、未確認の効果を成功扱いしないことを確認する。

Nixの評価とスキルの形式検証は、配布先とファイル形式を確認するためのもの。agentの行動改善は、実際の新規案件での成果と人間の負担を見て判断する。

配置仕様は[OpenAIのAGENTS.md](https://learn.chatgpt.com/docs/agent-configuration/agents-md)、[OpenAIのスキル](https://learn.chatgpt.com/docs/build-skills)、[Claude Codeのメモリ](https://code.claude.com/docs/en/memory)、[Claude Codeのスキル](https://code.claude.com/docs/en/skills)を参照。
