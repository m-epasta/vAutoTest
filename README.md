# autoTest

An alternative to tests framework, writtent in [V](https://vlang.io/)

## Features

- **Interactive CLI Testing**: Run benchmarks and tests against any executable binary.
- **Dynamic Variable Capture**: Capture output variables using the `$VAR=VALUE` syntax and use them in subsequent tests.
- **Static & Const Declarations**: Define global variables or retrieve them dynamically using shell commands (`# command`).
- **Regex Assertions**: Use `r"pattern"` in `before`/`after` hooks and `expected_regex` for powerful output validation.
- **Auto-Discovery**: Support for both `autotest.toml` and `.autotestrc` files.
- **V Integration**: Native support for `v test` via a simple bridge.

## Installation

Ensure you have the [V compiler](https://github.com/vlang/v) installed.

```bash
git clone https://github.com/youruser/autoTest
cd autoTest
v -o autoTest src/
```

Alternatively, if you have [just](https://github.com/casey/just installed:
```bash
git clone https://github.com/m-epasta/autoTest
cd autoTest
just build
```

## Usage

### Command Line Interface

```bash
# Run a single test against an executable
autoTest test -o ./my_binary

# Run a test suite from a configuration file
autoTest test -c tests/autotest.toml

# Filter tests by tag or name
autoTest test --tag fast --only login_test
```

### Configuration (`autotest.toml` or `.autotestrc`)

```toml
# Static variables
static BASE_URL = http://localhost:8080
const API_KEY = # fetch_key_from_vault.sh

[login_test]
command = "curl -X POST $BASE_URL/login"
after = r"Token: (.*)"
tags = ["fast", "api"]

[profile_test]
command = "curl -H 'Authorization: $TOKEN' $BASE_URL/profile"
expected_output = "Welcome User"
```

## Variable Capture

`autoTest` scans program output for lines starting with `$`.
- Output `$SESSION_ID=xyz`
- Subsequent commands can use `$SESSION_ID`.

## Development & Testing

Use the provided `justfile` for common development tasks:

- `just build`: Compiles the project.
- `just test`: Runs the full test suite.
- `just fmt`: Formats the V source code.
- `just clean`: Cleans up build artifacts.

## Permissions & Sudo

If you encounter a **"Permission denied"** error when running a script:

1.  **Make it executable**: `chmod +x scripts/my_script.js`
2.  **Use an interpreter**: `autoTest test -o "node scripts/my_script.js"`

### Running with Sudo
If your test requires `sudo`, remember that `sudo` often clears your `PATH`. Use the `-E` flag to preserve your environment:
```bash
sudo -E PATH=$PATH autoTest test -o my_privileged_binary
```

## License

MIT License - see [LICENSE](./LICENSE) for details.
