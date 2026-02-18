# Developer Help & Contributor Guide (`DEVHELP.md`)

Welcome to the `vAutoTest` development guide! This document provides technical insights for those looking to contribute to or extend the tool.

## Project Architecture

The project is structured into several modular V files within the `src/` directory:

- **`main.v`**: Entry point and CLI flag parsing.
- **`config.v`**: TOML configuration parsing and `TestConfig` struct.
- **`tester.v`**: Core logic for process management, output capturing, and assertion verification.
- **`ui.v`**: Terminal formatting utilities (colors, prefixes, logging).

## Development Setup

1. **V Compiler**: Requires V latest stable (or nightly).
2. **Standard Library**: Uses `os`, `flag`, `term`, `time`, `regex`, and `toml`.

### Build Commands

```bash
# Debug build (fast)
v src -o vAutoTest

# Optimized build for release
v -prod src -o vAutoTest
```

## Working with Source

### Process Management in V
The tool uses `os.Process` with `use_stdio_ctl = true` and `set_redirect_stdio()`. 
Commands are wrapped in `/bin/sh -c` to ensure robust path resolution and environment variable support.

### Adding New Assertion Types
If you want to add a new matcher (e.g., `expected_json`):
1. Update the `TestConfig` struct in `config.v`.
2. Update `get_toml_string` / parsing logic in `config.v`.
3. Add the validation logic to `Tester.run_config_tests()` in `tester.v`.

## Testing the Tester

To test your changes to `vAutoTest` itself:
1. Rebuild the binary: `v src -o vAutoTest`.
2. Run the provided suite: `./vAutoTest test`.
3. Use `autotest.toml` to define edge cases for testing.

## Code Style

- Follow the offical [V Code Style](https://github.com/vlang/v/blob/master/doc/docs.md#code-style).
- Use `v fmt -w src/` before committing.

---

Thank you for contributing to making `vAutoTest` the best premium testing experience!
