PROJECT OVERVIEW

This repository is "zen-desktop" — the Zen Browser, a Firefox fork that customizes the browser UI (XUL/JS) and ships packaging/patches/tools to build Firefox with Zen UI.

This document is intended as a living summary to be used as context for further LLM-assisted development.

High-level structure

- Top-level files

  - package.json: orchestrates surfer build/import/bootstrap/packaging and invokes engine/mach to run Firefox. Key scripts: "build", "start" (cd engine && python3 ./mach run --noprofile), "ffprefs" (cargo run in tools/ffprefs), "test" (scripts/run_tests.py).
  - pyproject.toml, Cargo toolchain files and engine/ subproject reflect the Firefox engine sources and Rust/py dependencies.
  - src/: Contains the Zen UI code and patches that integrate into the Firefox build (see src/zen and many patches under src/\*).
  - engine/: A copy or subtree of the Firefox "engine" (mozilla-central) used to build the browser; includes its own package.json and Rust/C++/Python sources.
  - tools/: small helper tools (e.g. tools/ffprefs written in Rust used to generate prefs files from prefs/\*.yaml).
  - scripts/: Python helper scripts (update_ff.py, run_tests.py, update_ts_types.py, ...)

- src/zen/: Main UI code in modern JS modules (.mjs) and CSS assets. Examples: ZenStartup.mjs, ZenUIManager.mjs, ZenWorkspaces.mjs, ZenWelcome.mjs, and subdirectories for features (glance, workspaces, mods, etc.).

- src/ (other): hundreds of patches under src/\* that modify Firefox components (browser, toolkit, modules, themes). Many apply XUL, JS, CSS, and C++/Rust patches.

- locales/: Localization strings. tests/: UI tests (mochitest) live under src/zen/tests and are wired into engine/testing/mochitest via scripts/run_tests.py.

Key developer workflows

- Build & Run (high-level)

  - Install dependencies: npm install (top-level). A custom tool called "surfer" (npm package @zen-browser/surfer) is used to orchestrate downloading and patching Firefox sources.
  - Surfer commands: build, download, bootstrap, import, package, reset; surfer download populates engine/ with Firefox artifacts.
  - Start: npm run start -> cd engine && python3 ./mach run --noprofile (runs Firefox using the engine directory)

- Preferences generation

  - prefs/ contains YAML files grouping pref configurations. tools/ffprefs reads prefs/\*.yaml and generates engine/modules/libpref/init/zen-static-prefs.inc and engine/browser/app/profile/zen.js.
  - package.json contains an "ffprefs" script that runs Cargo to run tools/ffprefs.

- Tests
  - scripts/run_tests.py copies ignorePrefs.json into engine/testing/mochitest then runs ./mach mochitest against zen/tests directories inside engine.

Important files I inspected

- package.json (top-level)

  - Key scripts, dependency on @zen-browser/surfer, dev tooling (eslint, prettier, husky)

- engine/package.json

  - Mirrors parts of mozilla-central dev dependencies used while building Firefox

- src/zen/common/ZenStartup.mjs

  - Entrypoint that hooks onto MozBeforeInitialXULLayout and performs layout initialization, workspace init, UI manager init, watermark handling, and delayed startup hooks.
  - Creates background decorations, moves navbars into a new container, registers observers for browser-delayed-startup-finished.

- src/zen/common/ZenUIManager.mjs

  - Central manager for UI behavior: popup tracking, motion (loads motion.min.mjs lazily), URL bar handling, tabs toolbar layout, toast notifications, vertical tabs and animation helper code.
  - Provides many helper methods for interacting with browser chrome (openAndChangeToTab, url transformations, toast notifications).

- src/zen/workspaces/ZenWorkspaces.mjs

  - Manages workspaces: persistent storage promises, initialization, tab selection safety and debouncing, empty-tab handling, pinned tabs, gestures and workspace navigation.
  - It extends nsZenMultiWindowFeature (a native integration for multi-window support).

- tools/ffprefs/src/main.rs

  - Rust tool that loads YAML prefs from prefs/ and writes out static and dynamic prefs into engine/ paths; also injects "#include zen.js" into firefox.js.

- scripts/run_tests.py

  - Copies prefs ignore file and runs mach mochitest for zen/tests inside engine.

- src/zen/moz.build
  - Declares subdirectories for moz.build inclusion (glance, mods, tests, toolkit)

CI & Automation

- .github/workflows/pr-test.yml: (PR checks) sets up Node (from .nvmrc), installs @zen-browser/surfer globally, npm install, runs "surfer download" and "surfer i" (import patches).

Developer toolchain notes

- Node: .nvmrc (project uses a pinned Node version), package.json devDeps (eslint, prettier, husky)
- Python: top-level scripts run with python3; engine/mach is used (mozilla's build system) — typical requirements for building Firefox apply.
- Rust: .rust-toolchain present and tools like tools/ffprefs are Rust binaries.
- moz.build / engine: The src/zen directory includes a moz.build so that the files are integrated into the Firefox build when building engine/.

Recommendations for future LLM tasks

1. Use this docs.md as the single source of truth when performing code changes or generating patches. It references key entry points (ZenStartup, ZenUIManager, ZenWorkspaces) that are good anchor locations.

2. For any UI change, search for the corresponding gZen\* manager and related .mjs file under src/zen/common or related feature folder.

3. For build tasks, use "surfer" commands (npm i -g @zen-browser/surfer) as the primary orchestration tool before invoking mach in engine/.

4. When running tests, use scripts/run_tests.py from project root (it will chdir into engine and run mach mochitest).

Next steps I can take

- Produce a component map (file -> responsibility) for src/zen to improve LLM context.
- Generate a contributor guide snippet with exact commands and common troubleshooting steps (installing required system deps for building Firefox).

If you want any of the next steps, tell me which one and I'll generate the file(s).
