# Project Architecture

The project contains few v files under src/:

- **`main.v`**: Entry point and CLI flag parsing.
- **`config.v`**: TOML/.rc configuration parsing and `TestConfig` struct.
- **`tester.v`**: Core logic for process management, output capturing, and assertion verification.
- **`ui.v`**: Terminal formatting utilities (colors, prefixes, logging).

## Development Setup

1. **V Compiler**: Require atleast V 0.5.0 c81e4e9 (maybe older) .
2. **Standard Library**: Uses `os`, `flag`, `term`, `time`, `regex`, and `toml`.

### Build Commands

```bash
# fast build
v src -o autoTest

# Or release build
v -prod src -o autoTest
```

## Working with Source

### Adding New Assertion Types
If you want to add a new matcher (e.g., `expected_json`):
1. Update the `TestConfig` struct in `config.v`.
2. Update `get_toml_string` / parsing logic in `config.v`.
3. Add the validation logic to `Tester.run_config_tests()` in `tester.v`.

## Testing the Tester

To test your changes to `autoTest` itself:
1. Rebuild the binary: `v src -o autoTest` or `just build`.
2. Run the provided suite: `just test`.
3. Use `autotest.toml` or `.autotestrc` to define edge cases for testing.

## Code Style

- Follow the offical [V Code Style](https://github.com/vlang/v/blob/master/doc/docs.md#code-style).
- Use `v fmt -w src/` or `just fmt` before committing.
