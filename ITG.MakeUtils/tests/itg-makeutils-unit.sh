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
DEFINE_string test_file '' $"test file path"

default_on_test_creation() {

	if [ $# -lt 1 ]; then
		( default_on_test_creation --help )
		exit 1
	fi

	FLAGS_PARENT="default_on_test_creation"
	FLAGS "$@" || exit $?
	eval set -- "${FLAGS_ARGV}"

	if [ "${FLAGS_test_file?}" ]; then
		printf $"Test \"%s\" (from file \"%s\").\\n" "${FLAGS_test_id:?}" "${FLAGS_test_file:-}"
	else
		printf $"Test \"%s\".\\n" "${FLAGS_test_id:?}"
	fi

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
	DEFINE_string test_stdout '' $"test stdout pipe's content"
	DEFINE_string test_stderr '' $"test stderr pipe's content"
	FLAGS "$@" || exit $?
	eval set -- "${FLAGS_ARGV}"

	if [ "${FLAGS_test_stdout?}" ]; then
		echo ${FLAGS_test_stdout}
	fi
	if [ "${FLAGS_test_stderr?}" ]; then
		echo ${FLAGS_test_stderr} >&2
	fi
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
	unset FLAGS_ARGC
	echo '==============================================================================='
	( default_on_test_creation --test_id "${FLAGS_test_id:?}" \
		${FLAGS_test_file:+--test_file "${FLAGS_test_file}"}
	) || printf $"Error in %s event handler.\\n" "\"on_test_add\""
	if [ "${FLAGS_on_test_add?}" ]; then
		( "${FLAGS_on_test_add}" --test_id "${FLAGS_test_id:?}" \
			${FLAGS_test_file:+--test_file "${FLAGS_test_file}"} \
		) || printf $"Error in %s event handler.\\n" "\"on_test_add\""
	fi
	( default_on_test_change --test_id "${FLAGS_test_id:?}" \
		${FLAGS_test_file:+--test_file "${FLAGS_test_file}"} \
		--test_status Running \
	) || printf $"Error in %s event handler.\\n" "\"on_test_status_change\""
	if [ "${FLAGS_on_test_status_change?}" ]; then
		( "${FLAGS_on_test_status_change}" --test_id "${FLAGS_test_id:?}" \
			${FLAGS_test_file:+--test_file "${FLAGS_test_file}"} \
			--test_status Running \
		) || printf $"Error in %s event handler.\\n" "\"on_test_status_change\""
	fi
  	echo "$@"
	local TEST_EXIT_CODE=0
	local START_TIME=$(($(date +%s%3N)))

	local TEST_STDOUT_FILENAME=$(mktemp)
	local TEST_STDERR_FILENAME=$(mktemp)
	( eval "$@" ) > $TEST_STDOUT_FILENAME 2> $TEST_STDERR_FILENAME
	local TEST_EXIT_CODE=$?
	local FINISH_TIME=$(($(date +%s%3N)))
	local DURATION=$((FINISH_TIME-START_TIME))
	local TEST_STDOUT=$(< "${TEST_STDOUT_FILENAME}")
	rm "${TEST_STDOUT_FILENAME}"
	local TEST_STDOUT_QUOTED="${TEST_STDOUT}"
	if [ "${TEST_STDOUT_QUOTED}" ]; then
		TEST_STDOUT_QUOTED="${TEST_STDOUT_QUOTED@Q}"
		TEST_STDOUT_QUOTED="${TEST_STDOUT_QUOTED:1}"
	else
		TEST_STDOUT_QUOTED=\'\'
	fi
	local TEST_STDERR=$(< "${TEST_STDERR_FILENAME}")
	rm "${TEST_STDERR_FILENAME}"
	local TEST_STDERR_QUOTED="${TEST_STDERR}"
	if [ "${TEST_STDERR_QUOTED}" ]; then
		TEST_STDERR_QUOTED="${TEST_STDERR_QUOTED@Q}"
		TEST_STDERR_QUOTED="${TEST_STDERR_QUOTED:1}"
	else
		TEST_STDERR_QUOTED=\'\'
	fi

	if [[ $TEST_EXIT_CODE -eq 0 ]]; then
		( default_on_test_change --test_id "${FLAGS_test_id:?}" \
			${FLAGS_test_file:+--test_file "${FLAGS_test_file}"} \
			--test_status Passed \
			--duration $DURATION \
#			--test_stdout "${TEST_STDOUT_QUOTED}" \
#			--test_stderr "${TEST_STDERR_QUOTED}" \
		) || printf $"Error in %s event handler.\\n" "\"on_test_status_change\""
		if [ "${FLAGS_on_test_status_change?}" ]; then
			( "${FLAGS_on_test_status_change}" --test_id "${FLAGS_test_id:?}" \
				${FLAGS_test_file:+--test_file "${FLAGS_test_file}"} \
				--test_status Passed \
				--duration $DURATION \
#				--test_stdout "${TEST_STDOUT_QUOTED}" \
#				--test_stderr "${TEST_STDERR_QUOTED}" \
			) || printf $"Error in %s event handler.\\n" "\"on_test_status_change\""
		fi
	else
		( default_on_test_change --test_id "${FLAGS_test_id:?}" \
			${FLAGS_test_file:+--test_file "${FLAGS_test_file}"} \
			--test_status Failed \
			--duration $DURATION \
			--test_exit_code $TEST_EXIT_CODE \
#			--test_stdout "${TEST_STDOUT_QUOTED}" \
#			--test_stderr "${TEST_STDERR_QUOTED}" \
		) || printf $"Error in %s event handler.\\n" "\"on_test_status_change\""
		if [ "${FLAGS_on_test_status_change?}" ]; then
			( "${FLAGS_on_test_status_change}" --test_id "${FLAGS_test_id:?}" \
				${FLAGS_test_file:+--test_file "${FLAGS_test_file}"} \
				--test_status Failed \
				--duration $DURATION \
				--test_exit_code $TEST_EXIT_CODE \
#				--test_stdout "${TEST_STDOUT_QUOTED}" \
#				--test_stderr "${TEST_STDERR_QUOTED}" \
			) || printf $"Error in %s event handler.\\n" "\"on_test_status_change\""
		fi
	fi
	echo '==============================================================================='

	exit $TEST_EXIT_CODE

}

main "$@"
