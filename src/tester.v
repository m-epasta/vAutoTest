module main

import os
import time
import regex

pub struct Stage {
pub:
	id          string
	name        string
	description string
	run_fn      fn (stage Stage, cmd string) (bool, string) @[required]
}

pub struct Tester {
pub mut:
	executable_path string
	config_tests    map[string]TestConfig
	static_vars     map[string]string
	tags_filter     []string
	names_filter    []string
}

pub fn new_tester(executable_path string) Tester {
	return Tester{
		executable_path: executable_path
	}
}

pub fn new_tester_from_config(config Config, tags []string, names []string) Tester {
	return Tester{
		config_tests: config.tests
		static_vars:  config.static_vars
		tags_filter:  tags
		names_filter: names
	}
}

pub fn (mut t Tester) run() {
	log_info('--- Starting autoTest ---')

	if t.config_tests.len > 0 {
		t.run_config_tests()
	} else {
		t.run_single_test()
	}

	log_success('', 'All tests passed!')
}

fn (t Tester) run_single_test() {
	log_info('Target: ${t.executable_path}')
	println('')

	stage := Stage{
		id:          'stage-1'
		name:        'Initial check'
		description: 'Check if the program runs and exits with code 0'
		run_fn:      stage_run_basic
	}

	log_stage(stage.id, 'Running tests for: ${stage.name}')

	success, output := stage.run_fn(stage, t.executable_path)

	if success {
		log_success(stage.id, 'Test passed!')
	} else {
		if output.contains('Permission denied') {
			log_error(stage.id, 'Test failed: Permission denied.')
			log_info('Hint: Try making the script executable with `chmod +x` or run it with an interpreter (e.g., `node script.js`).')
		} else {
			log_error(stage.id, 'Test failed!')
		}
		exit(1)
	}
	println('')
}

fn (mut t Tester) run_config_tests() {
	// Sort test names for deterministic execution
	mut names := t.config_tests.keys()
	names.sort()

	for name in names {
		cfg := t.config_tests[name]

		// Filter by name
		if t.names_filter.len > 0 {
			if name !in t.names_filter {
				continue
			}
		}

		// Filter by tag
		if t.tags_filter.len > 0 {
			mut found := false
			for tag in t.tags_filter {
				if tag in cfg.tags {
					found = true
					break
				}
			}
			if !found {
				continue
			}
		}

		log_stage(name, 'Running test: ${name}')

		// Substitute variables in hooks and command
		before_cmd := t.substitute(cfg.before)
		after_cmd := t.substitute(cfg.after)
		test_command := t.substitute(cfg.command)

		// Run before hook
		if before_cmd != '' {
			if before_cmd.starts_with('r"') {
				log_error(name, 'Regex check NOT supported in before hook (no previous output context)')
				exit(1)
			}
			log_info('Running before hook: ${before_cmd}')
			success_before, _ := run_command_raw(name, 'before', before_cmd, map[string]string{})
			if !success_before {
				log_error(name, 'Before hook failed!')
				exit(1)
			}
		}

		log_info('Command: ${test_command}')

		success, output := run_command_with_output(name, test_command, cfg.env)

		if !success {
			if output.contains('Permission denied') {
				log_error(name, 'Command failed: Permission denied.')
				log_info('Hint: Try making the script executable with `chmod +x` or run it with an interpreter (e.g., `node script.js`).')
			} else {
				log_error(name, 'Command failed!')
			}
			exit(1)
		}

		// Capture variables from output
		t.capture_vars(output)

		// Verify output
		if cfg.expected_output != '' {
			if output.trim_space() == cfg.expected_output.trim_space() {
				log_success(name, 'Output matched expected value!')
			} else {
				log_error(name, 'Output mismatch!')
				log_info('Expected: "${cfg.expected_output}"')
				log_info('Actual:   "${output}"')
				exit(1)
			}
		}

		// Verify regex
		if cfg.expected_regex != '' {
			mut re := regex.regex_opt(cfg.expected_regex) or {
				log_error(name, 'Invalid regex: ${cfg.expected_regex}')
				exit(1)
			}
			if re.matches_string(output) {
				log_success(name, 'Output matched regex pattern!')
			} else {
				log_error(name, 'Regex mismatch!')
				log_info('Pattern: "${cfg.expected_regex}"')
				log_info('Output:  "${output}"')
				exit(1)
			}
		}

		// Run after hook
		if after_cmd != '' {
			if after_cmd.starts_with('r"') {
				// Regex matching instead of command execution
				pattern := after_cmd[2..after_cmd.len - 1].replace('\\"', '"')
				log_info('Verifying output with regex: ${pattern}')
				mut re := regex.regex_opt(pattern) or {
					log_error(name, 'Invalid after regex: ${pattern}')
					exit(1)
				}
				if re.matches_string(output) {
					log_success(name, 'After hook regex matched!')
				} else {
					log_error(name, 'After hook regex mismatch!')
					exit(1)
				}
			} else {
				log_info('Running after hook: ${after_cmd}')
				success_after, _ := run_command_raw(name, 'after', after_cmd, map[string]string{})
				if !success_after {
					log_error(name, 'After hook failed!')
					exit(1)
				}
			}
		}

		log_success(name, 'Test passed!')
		println('')
	}
}

fn (t Tester) substitute(s string) string {
	mut res := s
	for k, v in t.static_vars {
		res = res.replace('$' + k, v)
	}
	return res
}

fn (mut t Tester) capture_vars(output string) {
	lines := output.split_into_lines()
	for line in lines {
		trimmed := line.trim_space()
		if trimmed.starts_with('$') && trimmed.contains('=') && !trimmed.contains(' ') {
			parts := trimmed.split('=')
			if parts.len == 2 {
				key := parts[0][1..].trim_space() // Skip the '$'
				val := parts[1].trim_space()
				// Basic validation for key (variable name)
				if key.all_before(' ').len == key.len {
					t.static_vars[key] = val
				}
			}
		}
	}
}

fn stage_run_basic(stage Stage, cmd string) (bool, string) {
	success, output := run_command_with_output(stage.id, cmd, map[string]string{})
	return success, output
}

fn run_command_with_output(stage_name string, cmd_str string, env map[string]string) (bool, string) {
	mut p := os.new_process('/bin/sh')
	p.set_args(['-c', cmd_str])
	if env.len > 0 {
		p.set_environment(env)
	}
	p.use_stdio_ctl = true
	p.set_redirect_stdio()
	p.run()

	if p.err != '' {
		log_error(stage_name, 'Process error: ${p.err}')
		return false, ''
	}

	mut full_output := []string{}

	for p.is_alive() {
		out := p.stdout_read()
		if out != '' {
			lines := out.split('\n')
			for line in lines {
				if line != '' {
					log_program(stage_name, line)
					full_output << line
				}
			}
		}
		err_out := p.stderr_read()
		if err_out != '' {
			lines := err_out.split('\n')
			for line in lines {
				if line != '' {
					log_program(stage_name, line)
					full_output << line
				}
			}
		}
		time.sleep(10 * time.millisecond)
	}

	p.wait()

	out := p.stdout_read()
	if out != '' {
		lines := out.split('\n')
		for line in lines {
			if line != '' {
				log_program(stage_name, line)
				full_output << line
			}
		}
	}
	err_out_final := p.stderr_read()
	if err_out_final != '' {
		lines := err_out_final.split('\n')
		for line in lines {
			if line != '' {
				log_program(stage_name, line)
				full_output << line
			}
		}
	}

	return p.code == 0, full_output.join('\n')
}

fn run_command_raw(stage_name string, hook_type string, cmd_str string, env map[string]string) (bool, string) {
	mut p := os.new_process('/bin/sh')
	p.set_args(['-c', cmd_str])
	if env.len > 0 {
		p.set_environment(env)
	}
	p.use_stdio_ctl = true
	p.set_redirect_stdio()
	p.run()

	mut full_output := []string{}
	for p.is_alive() {
		out := p.stdout_read()
		if out != '' {
			lines := out.split('\n')
			for line in lines {
				if line != '' {
					log_hook(stage_name, hook_type, line)
					full_output << line
				}
			}
		}
		err_out := p.stderr_read()
		if err_out != '' {
			lines := err_out.split('\n')
			for line in lines {
				if line != '' {
					log_hook(stage_name, hook_type, line)
					full_output << line
				}
			}
		}
		time.sleep(10 * time.millisecond)
	}

	p.wait()
	out := p.stdout_read()
	if out != '' {
		lines := out.split('\n')
		for line in lines {
			if line != '' {
				log_hook(stage_name, hook_type, line)
				full_output << line
			}
		}
	}
	err_out_final := p.stderr_read()
	if err_out_final != '' {
		lines := err_out_final.split('\n')
		for line in lines {
			if line != '' {
				log_hook(stage_name, hook_type, line)
				full_output << line
			}
		}
	}

	return p.code == 0, full_output.join('\n')
}
