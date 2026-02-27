#!/usr/bin/v run

import os

fn main() {
	println('Running autoTest suite...')
	root := os.dir(os.dir(os.real_path(@FILE)))
	os.chdir(root)!

	// Rebuild the project first to ensure we have the latest binary
	println('Building autoTest...')
	res_build := os.execute('v -o autoTest src/')
	if res_build.exit_code != 0 {
		println('Build failed:')
		println(res_build.output)
		exit(1)
	}

	println('Running tests from tests/.autotestrc...')
	res_test := os.execute('./autoTest test -c tests/.autotestrc')
	println(res_test.output)

	if res_test.exit_code != 0 {
		println('Tests failed!')
		exit(1)
	}

	println('All tests passed successfully!')
}
