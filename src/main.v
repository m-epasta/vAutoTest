module main

import flag
import os

fn main() {
	mut fp := flag.new_flag_parser(os.args)
	fp.application('autoTest')
	fp.description('A CLI tool that make interactive tests for you')
	fp.version('0.1.0')

	// Subcommands
	if os.args.len < 2 {
		println(fp.usage())
		return
	}

	command := os.args[1]

	match command {
		'test' {
			mut test_fp := flag.new_flag_parser(os.args[1..])
			executable := test_fp.string('o', `o`, '', 'executable bin to test')
			mut config_path := test_fp.string('c', `c`, '', 'path to config file')
			tag := test_fp.string('tag', `t`, '', 'only run tests with this tag')
			only := test_fp.string('only', `n`, '', 'only run the test with this name')

			if executable != '' {
				if !executable.contains(' ') && !os.exists(executable) {
					println('Error: executable not found: ${executable}')
					return
				}
				mut tester := new_tester(executable)
				tester.run()
			} else {
				if config_path == '' {
					if os.exists('autotest.toml') {
						config_path = 'autotest.toml'
					} else if os.exists('.autotestrc') {
						config_path = '.autotestrc'
					} else {
						config_path = 'autotest.toml'
					}
				}

				if os.exists(config_path) {
					config := load_config(config_path) or {
						println('Error loading config: ${err}')
						return
					}

					mut tags := []string{}
					if tag != '' {
						tags << tag
					}

					mut names := []string{}
					if only != '' {
						names << only
					}

					mut tester := new_tester_from_config(config, tags, names)
					tester.run()
				} else {
					println('Error: neither -o <executable> nor ${config_path} found')
					return
				}
			}
		}
		'help', '--help', '-h' {
			println(fp.usage())
		}
		else {
			println('Unknown command: ${command}')
			println(fp.usage())
		}
	}
}
