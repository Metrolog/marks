#!/bin/sh

set +o errexit

export POSIXLY_CORRECT=1

readonly THIS_SCRIPT="$0"
readonly THIS_SCRIPT_FILENAME=$(basename "$THIS_SCRIPT")
readonly MAKE_APPVEYOR_DIR=$(dirname "$THIS_SCRIPT")
readonly MAKE_COMMON_DIR=$(dirname "$MAKE_APPVEYOR_DIR")

on_test_change() {

	if [ $# -lt 1 ]; then
		( on_test_change --help )
		exit 1
	fi

	# shellcheck source=../shflags/shflags
	. "$MAKE_COMMON_DIR/shflags/shflags"
	FLAGS_PARENT="$THIS_SCRIPT_FILENAME"

	DEFINE_string test_id '' $"test id (slug)"
	DEFINE_string test_status 'None' $"test status (None, Running, Passed, Failed, Ignored, Skipped, Inconclusive, NotFound, Cancelled, NotRunnable)"
	DEFINE_integer test_exit_code 0 $"test exit code"
	DEFINE_integer duration 0 $"test execution duration"

	FLAGS "$@" || exit $?
	eval set -- "${FLAGS_ARGV}"

	set -o errexit
	appveyor UpdateTest "${FLAGS_test_id:?}" \
		-FileName "${FLAGS_test_file_name:-}" \
		-Outcome "${FLAGS_test_status:?}" \
		-Duration "${FLAGS_duration:?}" \
		-StdOut "${FLAGS_test_stdout:-}" \
		-StdErr "${FLAGS_test_stderr:-}"

}

on_test_change "$@"
