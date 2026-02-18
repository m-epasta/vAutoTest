module main

import term

pub fn log_stage(stage_name string, message string) {
	print(term.bold(term.blue('[${stage_name}] ')))
	println(message)
}

pub fn log_program(stage_name string, message string) {
	prefix := term.bold(term.blue('[${stage_name}] '))
	prog_prefix := term.yellow('[your-program] ')
	println('${prefix}${prog_prefix}${message}')
}

pub fn log_hook(stage_name string, hook_type string, message string) {
	prefix := term.bold(term.blue('[${stage_name}] '))
	hook_prefix := term.magenta('[${hook_type}] ')
	println('${prefix}${hook_prefix}${message}')
}

pub fn log_success(stage_name string, message string) {
	if stage_name != '' {
		print(term.bold(term.blue('[${stage_name}] ')))
	}
	println(term.bold(term.green(message)))
}

pub fn log_error(stage_name string, message string) {
	if stage_name != '' {
		print(term.bold(term.blue('[${stage_name}] ')))
	}
	println(term.bold(term.red(message)))
}

pub fn log_info(message string) {
	println(term.gray(message))
}
