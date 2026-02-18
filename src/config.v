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

pub fn load_config(path string) !map[string]TestConfig {
	if !os.exists(path) {
		return error('Config file not found: ${path}')
	}
	content := os.read_file(path)!

	// Decode TOML into a map where keys are test names
	mut tests := map[string]TestConfig{}

	doc := toml.parse_text(content)!
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

	return tests
}

fn get_toml_string(m map[string]toml.Any, key string) string {
	val := m[key] or { return '' }
	if val is toml.Null {
		return ''
	}
	return val.string()
}
