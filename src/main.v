module main

import flag
import os

fn main() {
	mut fp := flag.new_flag_parser(os.args)
	fp.application('vAutoTest')
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
			config_path := test_fp.string('c', `c`, 'autotest.toml', 'path to config file')
			tag := test_fp.string('tag', `t`, '', 'only run tests with this tag')
			only := test_fp.string('only', `n`, '', 'only run the test with this name')

			if executable != '' {
				if !os.exists(executable) {
					println('Error: executable not found: ${executable}')
					return
				}
				tester := new_tester(executable)
				tester.run()
			} else {
				if os.exists(config_path) {
					cfg := load_config(config_path) or {
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

					tester := new_tester_from_config(cfg, tags, names)
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
