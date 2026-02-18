# vAutoTest Roadmap

This document outlines the vision and upcoming features for `vAutoTest`. Our goal is to provide the most premium and user-friendly CLI testing framework.

---

## ✅ Completed Features
- [x] **Config-Driven Testing**: Define tests in `autotest.toml`.
- [x] **Process Isolation**: Commands run in independent shell environments.
- [x] **Lifecycle Hooks**: `before` and `after` script execution.
- [x] **Environment Variables**: Custom env injection per test case.
- [x] **Flexible Assertions**: Exact string and Regex matching.
- [x] **Test Filtering**: Grouping via `tags` and selective execution via `--tag` or `--only`.

---

## 🚧 Upcoming Features

### 1. Developer Experience (DX) & CI/CD
- **Snapshot Testing**: A `--update` flag to automatically save program output as a "golden reference," eliminating manual entry for large outputs.
- **CI Reports**: Support for JSON and JUnit output formats for seamless integration with GitHub Actions, GitLab, and Jenkins.
- **Shared Fixtures**: A `[global]` configuration block for shared environment variables and hooks across all tests.

### 2. Interactive Terminal UI (TUI)
- **Status Sidebar**: A persistent view of test progression and status (Pending, Running, Success, Failed).
- **Rich Diffs**: Side-by-side, color-coded comparisons (Red/Green) when assertions fail.
- **Interactive Mode**: A `dashboard` view to browse test results and logs interactively.

### 3. File System Monitoring
- **Watch Mode**: `vAutoTest watch` to monitor source files and trigger immediate re-tests on save.
- **Smart Retries**: Automatically re-run only the tests that failed in the previous run.

### 4. Advanced Networking & Mocking
- **Mock Servers**: Built-in support for spawning temporary HTTP/TCP mock servers defined in config.
- **Port Readiness**: Automatically wait for specific ports to become available before starting a test.

---

## Long-Term Vision
- **Parallel Execution**: Multi-threaded test runner for massive scale.
- **Sandboxed File Systems**: Virtualize file operations to prevent workspace pollution.