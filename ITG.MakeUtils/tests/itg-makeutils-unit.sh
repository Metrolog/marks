#!/bin/sh

set -o errexit
export POSIXLY_CORRECT=1

default_on_test_creation() {

	while getopts n:f: opt
	do
		case $opt in
		(n)	local test_id="$OPTARG";;
		(f)	local test_filename="$OPTARG";;
		(?)	printf $"Usage: %s: -n 'test id' [-f 'test file name']\\n" \
		 		"$0"
			exit 2;;
		esac
	done
	if [ -z "${test_id-}" ]
	then
		printf $"Usage: %s: -n 'test id' [-f 'test file name']\\n" \
			"$0"
		exit 2
	fi
	shift $((OPTIND - 1))
	unset OPTIND

	if [ -z "${test_filename-}" ]; then
		printf $"Test \"%s\" (from file \"%s\").\\n" "${test_id}" "${test_filename}"
	else
		printf $"Test \"%s\".\\n" "${test_id}"
	fi

}


default_on_test_change() {

	local statuses='None|Running|Passed|Failed|Ignored|Skipped|Inconclusive|NotFound|Cancelled|NotRunnable'
	while getopts n:f:s:d:o:e:x: opt
	do
		# shellcheck disable=2034
		case $opt in
		(n)	local test_id="$OPTARG";;
		(f)	local test_filename="$OPTARG";;
		(s)	local test_status="$OPTARG";;
		(d)	local test_duration="$OPTARG";;
		(x)	local test_exit_code="$OPTARG";;
		(o)	local test_stdout_filename="$OPTARG";;
		(e)	local test_stderr_filename="$OPTARG";;
		(?)	printf $"Usage: %s: -n 'test id' [-f 'test file name'] -s '%s' [-d duration] [-o 'stdout file name'] [-e 'stderr file name'] [-x exit code]\\n" \
				"$0" "$statuses"
			exit 2;;
		esac
	done
	if
		[ -z "${test_id-}" ] ||
		[ -z "${test_status-}" ] || [[ ! "${test_status}" =~ $statuses ]]
	then
		printf $"Usage: %s: -n 'test id' [-f 'test file name'] -s '%s' [-d duration] [-o 'stdout file name'] [-e 'stderr file name'] [-x exit code]\\n" \
			"$0" "$statuses"
		exit 2
	fi
	shift $((OPTIND - 1))
	unset OPTIND

	if [[ ${test_duration-0} -ne 0 ]]
	then
		if [[ ${test_exit_code-0} -ne 0 ]]
		then
			printf $"Test \"%s\" is %s with exit code %d in %d ms.\\n" "${test_id}" "${test_status}" "${test_exit_code}" "${test_duration}"
		else
			printf $"Test \"%s\" is %s in %d ms.\\n" "${test_id}" "${test_status}" "${test_duration}"
		fi
	else
		if [[ ${test_exit_code-0} -ne 0 ]]
		then
			printf $"Test \"%s\" is %s with exit code %d.\\n" "${test_id}" "${test_status}" "${test_exit_code}"
		else
			printf $"Test \"%s\" is %s.\\n" "${test_id}" "${test_status}"
		fi
	fi

}


main() {

	while getopts n:r:f:a:s: opt
	do
		case $opt in
		(n)	local test_id="$OPTARG";;
		(r)	local test_recipe_filename="$OPTARG";;
		(f)	local test_file="$OPTARG";;
		(a)	local test_on_add="$OPTARG";;
		(s)	local test_on_status_change="$OPTARG";;
		(?)	printf $"Usage: %s: -n 'test id' [-r 'test recipe script file name'] [-f 'test file name'] [-a 'test creation event handler'] [-s 'tests events handler']\\n" \
				"$0"
			exit 2;;
		esac
	done
	if
		[ -z "${test_id-}" ] ||
		[ -z "${test_recipe_filename-}" ]
	then
		printf $"Usage: %s: -n 'test id' [-r 'test recipe script file name'] [-f 'test file name'] [-a 'test creation event handler'] [-s 'tests events handler']\\n" \
			"$0"
		exit 2
	fi
	shift $((OPTIND - 1))
	unset OPTIND

	echo '==============================================================================='
	default_on_test_creation -n "${test_id}" \
		${test_file:+-f "${test_file}"}
	if [ "${test_on_add:-}" ]
	then
		( "${test_on_add}" -n "${test_id}" \
			${test_file:+-f "${test_file}"} \
		) || printf $"Error in \"%s\" event handler.\\n" 'on test add'
	fi
	default_on_test_change -n "${test_id}" \
		${test_file:+-f "${test_file}"} \
		-s Running
	if [ "${test_on_status_change:-}" ]
	then
		( "${test_on_status_change}" -n "${test_id}" \
			${test_file:+-f "${test_file}"} \
			-s Running \
		) || printf $"Error in \"%s\" event handler.\\n" 'on test status change'
	fi
	local TEST_EXIT_CODE=0
	local START_TIME=$(($(date +%s%3N)))

	local TEST_STDOUT_FILENAME
	TEST_STDOUT_FILENAME=$(mktemp)
	local TEST_STDERR_FILENAME
	TEST_STDERR_FILENAME=$(mktemp)
	local TEST_EXIT_CODE
	set +o errexit
	set -o pipefail
	{
		{
			set -o errexit
			# set -o xtrace
			# shellcheck disable=1090
			. "${test_recipe_filename}"
			set +o xtrace
		} | tee "$TEST_STDOUT_FILENAME"
	} 3>&1 1>&2 2>&3 | tee "$TEST_STDERR_FILENAME" 1>&2
	TEST_EXIT_CODE=$?
	set +o xtrace
	local FINISH_TIME=$(($(date +%s%3N)))
	local DURATION=$((FINISH_TIME-START_TIME))

	if [[ $TEST_EXIT_CODE -eq 0 ]]; then
		default_on_test_change -n "${test_id}" \
			${test_file:+-f "${test_file}"} \
			-s Passed \
			-d $DURATION \
			-o "${TEST_STDOUT_FILENAME}" \
			-e "${TEST_STDERR_FILENAME}"
		if [ "${test_on_status_change:-}" ]
		then
			( "${test_on_status_change}" -n "${test_id}" \
				${test_file:+-f "${test_file}"} \
				-s Passed \
				-d $DURATION \
				-o "${TEST_STDOUT_FILENAME}" \
				-e "${TEST_STDERR_FILENAME}"
			) || printf $"Error in \"%s\" event handler.\\n" 'on test status change'
		fi
	else
		default_on_test_change -n "${test_id}" \
			${test_file:+-f "${test_file}"} \
			-s Failed \
			-x $TEST_EXIT_CODE \
			-d $DURATION \
			-o "${TEST_STDOUT_FILENAME}" \
			-e "${TEST_STDERR_FILENAME}"
		if [ "${test_on_status_change:-}" ]
		then
			( "${test_on_status_change}" -n "${test_id}" \
				${test_file:+-f "${test_file}"} \
				-s Failed \
				-x $TEST_EXIT_CODE \
				-d $DURATION \
				-o "${TEST_STDOUT_FILENAME}" \
				-e "${TEST_STDERR_FILENAME}"
			) || printf $"Error in \"%s\" event handler.\\n" 'on test status change'
		fi
	fi
	echo '==============================================================================='
	rm "${TEST_STDOUT_FILENAME}"
	rm "${TEST_STDERR_FILENAME}"

	exit $TEST_EXIT_CODE

}

main "$@"
