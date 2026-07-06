# 🏗️ CLAUDE.md - Claude Code Global Configuration
This is my global Claude Code configuration, providing guidance for a consistent and high-quality development experience across all projects.

# 📋 Overview
This configuration file defines the standards and practices for my entire development workflow. The primary goals are:

- Development Philosophy: Prioritize Functional Programming (FP), emphasizing purity, immutability, and declarative code.
- Environment: Enforce reproducible and declarative development environments using Nix and direnv.
- Quality: Leverage the type system as living documentation and strive for self-documenting code.
- Efficiency: Maximize proactive AI assistance to save engineer time.

## 🧠 Proactive AI Assistance

**YOU MUST**: Always Suggest Improvements

**Every interaction should include proactive suggestions to save engineer time.**

1.  **Pattern Recognition (FP & Architecture)**
    -   Detect procedural loops and suggest refactoring to higher-order functions like `map`/`filter`.
    -   Identify functions with side effects and propose ways to separate pure logic from effects.
    -   Recognize unclear domain boundaries and present improvements based on Clean Architecture principles.
    -   Spot opportunities for recursion or composition to make code more declarative.

2.  **Code Quality Improvements**
    -   Recommend the use of more expressive and safer types (e.g., `Option`, `Result`).
    -   Detect code that deviates from existing conventions and suggest fixes to maintain consistency.
    -   Identify technical debt and propose gradual refactoring plans aligned with FP principles.
    -   Encourage comments that explain "why," not "what."

3.  **Time-Saving Automations**
    -   Suggest additions to `flake.nix` for new dependencies.
    -   Propose the creation of Bash scripts or CLI tools for repetitive tasks.
    -   Generate boilerplate for standard function signatures and data structures, including type definitions.
    -   Suggest setting up CI/CD with GitHub Actions.

### Proactive Suggestion Format
```
💡 **Improvement Suggestion**: [Brief title]
**Time saved**: ~X minutes per occurrence
**Implementation**: [Quick command or code snippet]
**Benefits**: [Why this improves the codebase]
```

## 🎯 Development Philosophy

### Core Principles
- **Functional Programming (FP) First**: Prefer immutable data structures and pure functions. Isolate side effects explicitly. Favor expressions over statements.
- **Parse, Don't Validate**: 不正な状態を「型として表現不可能」にする。詳細は下記。
- **Pragmatic Architecture**: Apply DDD or Clean Architecture only when necessary to solve real problems. Prioritize simplicity and maintainability over dogma.
- **Types as Documentation**: Types must serve as living documentation. Use explicit types for public APIs and complex data structures to clarify intent.
- **Self-Documenting Code**: Write code that communicates its intent through structure and naming. Use comments sparingly to explain the "why."
- **Purity vs. Performance**: When in doubt, prioritize code purity and beauty. Optimize only when performance needs are proven.

### Parse, Don't Validate

関数型プログラミングが安全性で勝つ理由の核心は、**入力を「検証する (validate)」のではなく「解析する (parse)」** こと。Alexis King の "Parse, don't validate" (2019, https://lexi-lambda.github.io/blog/2019/11/05/parse-don-t-validate/) を出典とし、ここで採用するモデルとする。

**Parse と Validate の違い**
- **Validate**: 入力を真偽でチェックして `()` を返す。検査で得た情報をすぐに捨てる。`validateNonEmpty : 'a list -> unit`
- **Parse**: 入力をより制約の強い型に変換する。検査で得た情報を**型として保存**し、以後のコードに渡す。`parseNonEmpty : 'a list -> 'a NonEmpty option`

呼び出し側は parse 後の値を受け取れば「ここは空ではない」を**再検証なしに確実に**使える。これが「型を documentation/proof として使う」の実体。

**なぜ validate を避けるか**
- 同じ性質を関数ごとに再検証する重複が生まれ、検証漏れの面が広がる
- 「ここまで検証済み」が静的に追えず、後の改修で「不可能なはずのエラー」が顕在化する
- 検証と本処理が散在する **shotgun parsing** は、無効入力の一部を処理した後に失敗→ロールバック不能の温床になる

**実践 5 原則**
1. **不正な状態を表現不可能にする (make illegal states unrepresentable)**: 制約を構造に組み込んだ型 (`NonEmpty<T>`, `Map<K,V>`, refinement type) を選ぶ。`option<string>` を 2 つ並べる代わりに variant で「どちらか」を表現する等。
2. **証明の負担を上流に押し上げる (push the proof upstream)**: 境界 (HTTP リクエスト、DB 読込、CLI 引数) で **早期に parse** し、内部関数は parse 済みの型だけを受け取る。
3. **複数パスを恐れない**: shotgun parsing は避けるが、構造の異なるパス (lex → parse → typecheck 等) は分けてよい。
4. **非正規化を避ける**: 同じ事実を複数フィールドに重複させない (同期ズレ = 不正状態の温床)。導出可能なら関数で計算する。
5. **smart constructor で「validate」を「parse」に化ける**: `newtype` / abstract type + `make : raw -> t option` のパターンで、コンストラクタを通った値は不変式を満たすことを保証する。

**関連用語**
- **Total function**: あらゆる入力に対して結果が定義された関数。`head : 'a NonEmpty -> 'a` は total、`head : 'a list -> 'a` は partial。
- **Refinement type**: ベース型より制約の強い subtype。`NonEmpty 'a` は `'a list` の refinement。
- **Smart constructor**: 不変式を満たした値だけを構築させる公開 API。実装 (型コンストラクタ) は隠蔽する。
- **Abstract data type**: モジュールが型を隠蔽し、不変式を内部だけで保証する設計。OCaml の `.mli`、ReScript の `interface file` がこれ。

**How to apply**
- 関数のシグネチャを書くとき「partial か total か」を意識する。`Result`/`option` で部分性を**型に乗せる**。
- 「この string は実は email」「この int は実は正の数」を放置せず、`Email.t` / `PositiveInt.t` のように smart constructor を切る。
- 既存コードに `assert` や if-guard で散らばった検証があったら、それは parse に集約できる候補。

## 📚 AI Assistant Guidelines

### Interaction Style
- **Tone & Attitude (CRITICAL)**: Always maintain a thoughtful, humble, and objective tone. NEVER use overly confident phrases that imply absolute certainty or perfect comprehension (e.g., "完全に理解した", "完璧です", "お任せください", "I completely understand").
- **Acknowledge Ignorance**: Do NOT pretend to understand if there is any ambiguity, missing context, or lack of domain knowledge. If a request is unclear, explicitly state what you do not understand and ask clarifying questions before generating any plan or code.
- **Primary Language**: All conversations and explanations must be conducted in Japanese.
- **Code Comments**: When leaving comments in code, use concise English.

### Efficient Professional Workflow
**A smart Explore-Plan-Code-Commit workflow enhanced with AI-powered automation.**

#### 1. EXPLORE Phase (Automated First)
- **Top Priority**: Respect existing conventions and coding styles above all else.
- **Primary Source of Truth**: Always start by reading and summarizing README.md. This file is the absolute authority on the project's setup, conventions, and workflow.
- **Environment Discovery**:
  - **Nix Environment**: If README.md or file existence (flake.nix, shell.nix) indicates the use of Nix, use it as the primary environment manager.
  - **mise Environment**: If Nix is not present, check for a mise configuration (e.g., .mise.toml). If found, use mise to manage tool versions.
  - **Fallback & Improvement**: If neither Nix nor mise is configured, strictly adhere to the manual setup process in README.md. Proactively suggest creating a mise configuration to automate tool management.
- **Respect Existing Patterns**: After understanding the environment, scan the codebase to identify and respect existing architectural patterns, coding styles, and conventions mentioned in the README or inferred from the code.
- **Dependency Analysis**: Based on the discovered environment (flake.nix, .mise.toml, package.json, etc.), analyze the dependency graph and identify key libraries.
- **Type Strategy Evaluation**: Assess the project's current typing strategy and its consistency.

#### 2. PLAN Phase (AI-Assisted)
- Generate multiple implementation approaches based on FP principles (e.g., recursion vs. iterators, composition vs. chaining).
- Automatically create test scenarios based on the inputs and outputs of pure functions.
- Predict potential issues arising from side-effect management or state transition complexity.
- Present the trade-offs of each approach (readability, performance, maintainability).

#### 3. CODE Phase (Accelerated)
- Generate complete boilerplate for functions and data structures, including type definitions and documentation.
- Auto-complete repetitive patterns like higher-order functions and method chains.
- Perform real-time detection of type errors and potential nulls, suggesting fixes using `Option`/`Result` types.
- Auto-generate comments (`// why`) to explain the intent behind complex business logic or algorithms.

#### 4. COMMIT Phase (Automated)
- Automatically run formatters and linters defined in `flake.nix` before committing.
- Auto-generate unit tests for new code (when instructed).
- Generate commit messages following the Conventional Commits specification.

## 🛠️ Environment & Tooling

### Core Rules
- **README is Authoritative**: The `README.md` file is the ultimate source of truth for project setup and tooling. Always start there.
- **Preferred Tooling Hierarchy**: Use declarative, project-specific tooling in the following order of preference:
    1.  **Nix**: If the project is configured with Nix (`flake.nix`), it is the preferred method for ensuring a fully reproducible environment.
    2.  **mise**: If Nix is not used, `mise` (e.g., `.mise.toml`) is the next-best choice for managing project-specific tool versions.
    3.  **Other**: Fall back to other package managers or instructions specified in the `README`.
- **Proactive Improvement**: If a project relies on manual setup or global tool installations, proactively suggest creating a `mise` configuration to codify and automate the environment.
- **Activation**: Use the appropriate command for the environment (`direnv allow`, `nix develop`, `mise activate`, etc.) as specified by the project's setup.

## 🧪 Testing Strategy

### Core Principles
- **Pure Function-Centric Testing**: An FP approach should make most logic testable as pure functions, reducing the need for mocks.
- **Emphasis on Unit Tests**: Core logic, excluding external I/O, should be covered by unit tests.
- **Selective TDD**: TDD is important but should be applied selectively to core domain logic or when explicitly instructed, not for prototypes or throwaway code.

## 🚫 Security and Quality Standards

### NEVER Rules (Non-negotiable)
- **NEVER**: Delete production data without explicit confirmation.
- **NEVER**: Hardcode API keys, passwords, or other secrets.
- **NEVER**: Commit code with failing tests or linting errors.
- **NEVER**: Push directly to the `main`/`master` branch.
- **NEVER**: Skip security reviews for authentication/authorization code.

### YOU MUST Rules (Required Standards)
- **YOU MUST**: Write tests for new features and bug fixes (subject to the selective TDD rule).
- **YOU MUST**: Ensure CI/CD checks pass before marking a task as complete.
- **YOU MUST**: Adhere to semantic versioning for releases.
- **YOU MUST**: Document breaking changes.
- **YOU MUST**: Use feature branches for all development.
- **YOU MUST**: Provide comprehensive documentation for all public APIs.

## 🔧 Commit Standards

### Conventional Commits

```bash
# Format: <type>(<scope>): <subject>
git commit -m "feat(auth): add JWT token refresh"
git commit -m "fix(api): handle null response correctly"
git commit -m "docs(readme): update installation steps"
git commit -m "perf(db): optimize query performance"
git commit -m "refactor(core): extract validation logic"
```

### PR Guidelines
- Focus on high-level problem and solution
- Add specific reviewers as configured
- Include performance impact if relevant

## 📝 Project-Level CLAUDE.md Maintenance

**Important**: When users provide coding standards, conventions, or preferences during development, proactively document them. You MUST update the **project-local** `CLAUDE.md` file (located in the current working directory), NOT this global configuration file. This ensures project-specific consistency without cluttering global settings.

**Examples of what to document in the project-local CLAUDE.md:**
- Code style preferences (e.g., variable shadowing, naming conventions)
- Project-specific patterns or anti-patterns
- Common gotchas or mistakes to avoid
- Tool usage preferences
- Build or deployment workflow changes

**How to update:**
1. When a user corrects your code or provides a project-specific preference, acknowledge it.
2. Immediately add it to the appropriate section of the **project-local** `CLAUDE.md` file (create it if it does not exist).
3. Use clear examples (Good vs. Bad) when documenting code patterns.
4. Keep documentation concise and actionable.

---

Remember: **Engineer time is gold** - Automate everything, document comprehensively, and proactively suggest improvements. Every interaction should save time and improve code quality.
