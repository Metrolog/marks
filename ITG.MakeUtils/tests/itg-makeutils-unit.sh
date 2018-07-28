#!/bin/sh

export POSIXLY_CORRECT=1

readonly THIS_SCRIPT="$0"
readonly THIS_SCRIPT_FILENAME=$(basename "$THIS_SCRIPT")
readonly MAKE_TESTS_DIR=$(dirname "$0")
readonly MAKE_COMMON_DIR=$(dirname "$MAKE_TESTS_DIR")

# shellcheck source=../shflags/shflags
. "$MAKE_COMMON_DIR/shflags/shflags"
FLAGS_PARENT="$THIS_SCRIPT_FILENAME"

DEFINE_string test_id '' $"test id (slug)"


default_on_test_creation() {

	if [ $# -lt 1 ]; then
		( default_on_test_creation --help )
		exit 1
	fi

	FLAGS_PARENT="default_on_test_creation"
	FLAGS "$@" || exit $?
	eval set -- "${FLAGS_ARGV}"

	exit 0

}


default_on_test_change() {

	if [ $# -lt 1 ]; then
		( default_on_test_change --help )
		exit 1
	fi

	FLAGS_PARENT="default_on_test_change"
	DEFINE_string test_status 'None' $"test status (None, Running, Passed, Failed, Ignored, Skipped, Inconclusive, NotFound, Cancelled, NotRunnable)"
	DEFINE_integer test_exit_code 0 $"test exit code"
	FLAGS "$@" || exit $?
	eval set -- "${FLAGS_ARGV}"

	set -o errexit

	if [[ ${FLAGS_test_exit_code:?} -ne 0 ]]; then
		printf $"Test \"%s\" is %s with exit code %d.\\n" "${FLAGS_test_id:?}" "${FLAGS_test_status:?}" "${FLAGS_test_exit_code:?}"
	else
		printf $"Test \"%s\" is %s.\\n" "${FLAGS_test_id:?}" "${FLAGS_test_status:?}"
	fi

	exit 0

}


main() {

	if [ $# -lt 1 ]; then
		( main --help )
		exit 1
	fi

	FLAGS_PARENT="$THIS_SCRIPT_FILENAME"
	DEFINE_string on_test_add 'default_on_test_creation' $"test creation event handler"
	DEFINE_string on_test_status_change 'default_on_test_change' $"tests events handler"
	FLAGS "$@" || exit $?
	eval set -- "${FLAGS_ARGV}"

	echo '==============================================================================='
	( "${FLAGS_on_test_add:?}" --test_id "${FLAGS_test_id:?}" ) || printf $"Error in %s event handler.\\n" "\"on_test_add\""
	( "${FLAGS_on_test_status_change:?}" --test_id "${FLAGS_test_id:?}" --test_status Running ) || printf $"Error in %s event handler.\\n" "\"on_test_status_change\""
	echo "$@"
	if ( "$@"; ); then
		( "${FLAGS_on_test_status_change:?}" --test_id "${FLAGS_test_id:?}" --test_status Passed ) || printf $"Error in %s event handler.\\n" "\"on_test_status_change\""
	else
		( "${FLAGS_on_test_status_change:?}" --test_id "${FLAGS_test_id:?}" --test_status Failed --test_exit_code $? ) || printf $"Error in %s event handler.\\n" "\"on_test_status_change\""
	fi
	echo '==============================================================================='

	exit 0

}

main "$@"
