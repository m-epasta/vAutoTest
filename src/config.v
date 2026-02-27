module main

import toml
import os

pub struct TestConfig {
pub:
	command         string
	expected_output string
	expected_regex  string
	before          string
	after           string
	env             map[string]string
	tags            []string
}

pub struct Config {
pub:
	tests       map[string]TestConfig
	static_vars map[string]string
}

pub fn load_config(path string) !Config {
	if !os.exists(path) {
		return error('Config file not found: ${path}')
	}
	content := os.read_file(path)!

	mut static_vars := map[string]string{}
	mut clean_content := []string{}

	lines := content.split_into_lines()
	for line in lines {
		trimmed := line.trim_space()
		if trimmed == '' {
			clean_content << line
			continue
		}

		if trimmed.starts_with('static ') || trimmed.starts_with('const ') {
			parts := trimmed.split('=')
			if parts.len >= 2 {
				name := parts[0].replace('static ', '').replace('const ', '').trim_space()
				mut val := parts[1..].join('=').trim_space()

				if val.starts_with('#') {
					cmd := val[1..].trim_space()
					res := os.execute(cmd)
					if res.exit_code == 0 {
						val = res.output.trim_space()
					} else {
						return error('Failed to execute command for static var ${name}: ${res.output}')
					}
				}
				static_vars[name] = val
			}
			continue
		}

		// Handle key = r"value" -> key = 'value' (TOML literal string)
		if trimmed.contains('= r"') {
			mut new_line := line
			new_line = new_line.replace('= r"', "= '")
			if new_line.ends_with('"') {
				new_line = new_line[..new_line.len - 1] + "'"
			}
			// Re-add the r" prefix internally so tester.v knows it's a regex
			parts := new_line.split('=')
			if parts.len >= 2 {
				key := parts[0].trim_space()
				val := parts[1..].join('=').trim_space()
				if val.starts_with("'") && val.ends_with("'") {
					inner := val[1..val.len - 1]
					new_line = "${key} = \"r\\\"${inner}\\\"\""
				}
			}
			clean_content << new_line
		} else {
			clean_content << line
		}
	}

	// Decode TOML into a map where keys are test names
	mut tests := map[string]TestConfig{}

	doc := toml.parse_text(clean_content.join('\n')) or {
		ext := os.file_ext(path).to_lower()
		if ext in ['.js', '.v', '.vsh', '.sh', '.py'] {
			return error('Failed to parse ${path} as TOML. It looks like a source code file (${ext}).\nDid you mean to use -o to run a single test or use a .toml/.autotestrc config file?')
		}
		return error('Failed to parse config as TOML: ${err}')
	}
	any := doc.to_any()

	m := any.as_map()
	for name, data in m {
		test_map := data.as_map()

		mut env_vars := map[string]string{}
		if env_any := test_map['env'] {
			env_map := env_any.as_map()
			for k, v in env_map {
				env_vars[k] = v.string()
			}
		}

		mut tags_list := []string{}
		if tags_any := test_map['tags'] {
			tags_arr := tags_any.array()
			for t in tags_arr {
				tags_list << t.string()
			}
		}

		tests[name] = TestConfig{
			command:         get_toml_string(test_map, 'command')
			expected_output: get_toml_string(test_map, 'expected_output')
			expected_regex:  get_toml_string(test_map, 'expected_regex')
			before:          get_toml_string(test_map, 'before')
			after:           get_toml_string(test_map, 'after')
			env:             env_vars
			tags:            tags_list
		}
	}

	return Config{
		tests:       tests
		static_vars: static_vars
	}
}

fn get_toml_string(m map[string]toml.Any, key string) string {
	val := m[key] or { return '' }
	if val is toml.Null {
		return ''
	}
	return val.string()
}
