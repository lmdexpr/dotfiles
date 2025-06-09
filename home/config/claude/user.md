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
- **Pragmatic Architecture**: Apply DDD or Clean Architecture only when necessary to solve real problems. Prioritize simplicity and maintainability over dogma.
- **Types as Documentation**: Types must serve as living documentation. Use explicit types for public APIs and complex data structures to clarify intent.
- **Self-Documenting Code**: Write code that communicates its intent through structure and naming. Use comments sparingly to explain the "why."
- **Purity vs. Performance**: When in doubt, prioritize code purity and beauty. Optimize only when performance needs are proven.

## 📚 AI Assistant Guidelines

### Interaction Style
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
- Never mention tools used (no co-authored-by)
- Add specific reviewers as configured
- Include performance impact if relevant

---

Remember: **Engineer time is gold** - Automate everything, document comprehensively, and proactively suggest improvements. Every interaction should save time and improve code quality.
