#!/bin/sh

set +o errexit

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
	DEFINE_integer duration 0 $"test execution duration"
	FLAGS "$@" || exit $?
	eval set -- "${FLAGS_ARGV}"

	if [[ ${FLAGS_duration:?} -ne 0 ]]; then
		if [[ ${FLAGS_test_exit_code:?} -ne 0 ]]; then
			printf $"Test \"%s\" is %s with exit code %d in %d ms.\\n" "${FLAGS_test_id:?}" "${FLAGS_test_status:?}" "${FLAGS_test_exit_code:?}" "${FLAGS_duration:?}"
		else
			printf $"Test \"%s\" is %s in %d ms.\\n" "${FLAGS_test_id:?}" "${FLAGS_test_status:?}" "${FLAGS_duration:?}"
		fi
	else
		if [[ ${FLAGS_test_exit_code:?} -ne 0 ]]; then
			printf $"Test \"%s\" is %s with exit code %d.\\n" "${FLAGS_test_id:?}" "${FLAGS_test_status:?}" "${FLAGS_test_exit_code:?}"
		else
			printf $"Test \"%s\" is %s.\\n" "${FLAGS_test_id:?}" "${FLAGS_test_status:?}"
		fi
	fi

	exit 0

}


main() {

	if [ $# -lt 1 ]; then
		( main --help )
		exit 1
	fi

	FLAGS_PARENT="$THIS_SCRIPT_FILENAME"
	DEFINE_string on_test_add '' $"test creation event handler"
	DEFINE_string on_test_status_change '' $"tests events handler"
	FLAGS "$@" || exit $?
	eval set -- "${FLAGS_ARGV}"

	shopt -s execfail
	echo '==============================================================================='
	( default_on_test_creation --test_id "${FLAGS_test_id:?}" ) || printf $"Error in %s event handler.\\n" "\"on_test_add\""
	if [ "${FLAGS_on_test_add}" ]; then
		( exec -c "${FLAGS_on_test_add}" --test_id "${FLAGS_test_id:?}" ) || printf $"Error in %s event handler.\\n" "\"on_test_add\""
	fi
	( default_on_test_change --test_id "${FLAGS_test_id:?}" --test_status Running ) || printf $"Error in %s event handler.\\n" "\"on_test_status_change\""
	if [ "${FLAGS_on_test_status_change}" ]; then
		( exec -c "${FLAGS_on_test_status_change}" --test_id "${FLAGS_test_id:?}" --test_status Running ) || printf $"Error in %s event handler.\\n" "\"on_test_status_change\""
	fi
  	echo "$@"
	TEST_EXIT_CODE=0
	START_TIME=$(($(date +%s%3N)))
	if ( eval "$@" ); then
		FINISH_TIME=$(($(date +%s%3N)))
		DURATION=$((FINISH_TIME-START_TIME))
		( default_on_test_change --test_id "${FLAGS_test_id:?}" --test_status Passed --duration $DURATION ) || printf $"Error in %s event handler.\\n" "\"on_test_status_change\""
		if [ "${FLAGS_on_test_status_change}" ]; then
			( exec -c "${FLAGS_on_test_status_change}" --test_id "${FLAGS_test_id:?}" --test_status Passed --duration $DURATION ) || printf $"Error in %s event handler.\\n" "\"on_test_status_change\""
		fi
	else
		TEST_EXIT_CODE=$?
		FINISH_TIME=$(($(date +%s%3N)))
		DURATION=$((FINISH_TIME-START_TIME))
		( default_on_test_change --test_id "${FLAGS_test_id:?}" --test_status Failed --duration $DURATION --test_exit_code $TEST_EXIT_CODE ) || printf $"Error in %s event handler.\\n" "\"on_test_status_change\""
		if [ "${FLAGS_on_test_status_change}" ]; then
			( exec -c "${FLAGS_on_test_status_change}" --test_id "${FLAGS_test_id:?}" --test_status Failed --duration $DURATION --test_exit_code $TEST_EXIT_CODE ) || printf $"Error in %s event handler.\\n" "\"on_test_status_change\""
		fi
	fi
	echo '==============================================================================='

	exit $TEST_EXIT_CODE

}

main "$@"
