# vAutoTest

**vAutoTest** is a powerful, CodeCrafters-inspired testing tool designed to provide a premium testing experience for CLI applications. It features real-time output capturing, lifecycle hooks, regex assertions, and flexible test filtering—all with beautiful, colored terminal feedback.

---

## ✨ Features

- **CodeCrafters Style**: Beautiful, real-time testing stages with colored logs.
- **Config-Driven**: Define your tests in a simple `autotest.toml` file.
- **Dynamic Hooks**: Run setup (`before`) and cleanup (`after`) commands for each test.
- **Regex Assertions**: Verify your program's output using powerful regular expressions.
- **Environment Support**: Inject custom environment variables per test case.
- **Smart Filtering**: Run specific tests using tags or names via the CLI.
- **Zero Dependencies**: Compiled to a single binary for ease of use.

---

## Getting Started

### Installation

Ensure you have [V](https://vlang.io/) installed.

```bash
# Clone the repository
git clone https://github.com/your-username/vAutoTest.git
cd vAutoTest

# Build the binary
v src -o vAutoTest
```

### Quick Start

Create an `autotest.toml` in your project root:

```toml
[hello_world]
command = "v run tests/hello.v"
expected_output = "Hello world!"
tags = ["fast"]
```

Run the tests:

```bash
./vAutoTest test
```

---

## 🛠️ Configuration Guide (`autotest.toml`)

Each section in the TOML file represents a test case.

| Key | Type | Description |
| :--- | :--- | :--- |
| `command` | String | The main command to execute. |
| `expected_output` | String | (Optional) Exact match for the program output (whitespace-trimmed). |
| `expected_regex` | String | (Optional) Regex pattern to match against the output. |
| `before` | String | (Optional) Command to run before the test (setup). |
| `after` | String | (Optional) Command to run after the test (cleanup). |
| `env` | Map | (Optional) Key-value pairs of environment variables. |
| `tags` | Array | (Optional) List of tags for grouping tests. |

### Example Example

```toml
[advanced_test]
before = "echo 'setup' > data.tmp"
after = "rm data.tmp"
command = "echo $GREETING && cat data.tmp"
env = { GREETING = "Hello from vAutoTest" }
expected_regex = "Hello.*\nsetup"
tags = ["slow", "advanced"]
```

---

## ⌨CLI Usage

### Run all tests
```bash
./vAutoTest test
```

### Run tests by Tag
```bash
./vAutoTest test --tag fast
```

### Run a specific test by Name
```bash
./vAutoTest test --only hello_world
```

### Specify a custom Config Path
```bash
./vAutoTest test --config my_tests.toml
```

---

## Roadmap

Check out [ROADMAP.md](ROADMAP.md) to see what's coming next!

## Contributing

Contributions are welcome! Please see [DEVHELP.md](DEVHELP.md) for development guidelines.

---

Built with the best programming language [V Programming Language](https://vlang.io/).
