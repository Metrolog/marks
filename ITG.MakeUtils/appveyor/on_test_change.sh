#!/bin/sh

set -o errexit
export POSIXLY_CORRECT=1

on_test_change() {

	local statuses='None|Running|Passed|Failed|Ignored|Skipped|Inconclusive|NotFound|Cancelled|NotRunnable'
	test_duration=0
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

	local test_stdout
	if
		[ ! -z "${test_stdout_filename-}" ]
	then
		test_stdout=$(< "${test_stdout_filename}")
	fi
	local test_stderr
	if
		[ ! -z "${test_stderr_filename-}" ]
	then
		test_stderr=$(< "${test_stderr_filename}")
	fi

	set -o xtrace
	appveyor UpdateTest "${test_id}" \
		-Framework MSTest \
		${test_filename:+-FileName "${test_filename}"} \
		-Outcome "${test_status}" \
		-Duration "${test_duration}" \
		${test_stdout:+-StdOut "${test_stdout}"} \
		${test_stderr:+-StdErr "${test_stderr}"}
	# set +o xtrace

}

on_test_change "$@"
