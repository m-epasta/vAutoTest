module tests

import os

fn test_autotest_suite() {
	println('Triggering vsh test runner...')
	root := os.dir(os.dir(os.real_path(@FILE)))
	res := os.execute('v run ${root}/tests/run_tests.vsh')
	assert res.exit_code == 0
}
