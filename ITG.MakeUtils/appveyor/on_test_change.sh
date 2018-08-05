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
		n)	local test_id="$OPTARG";;
		f)	local test_file="$OPTARG";;
		s)	local test_status="$OPTARG";;
		d)	local test_duration="$OPTARG";;
		x)	local test_exit_code="$OPTARG";;
		o)	local test_stdout="$OPTARG";;
		e)	local test_stderr="$OPTARG";;
		?)	printf $"Usage: %s: -n 'test id' [-f 'test file name'] -s '%s' [-d duration] [-o 'stdout'] [-e 'stderr'] [-x exit code]\\n" \
				"$0" "$statuses"
			exit 2;;
		esac
	done
	if
		[ -z "${test_id-}" ] ||
		[ -z "${test_status-}" ] || [[ ! "${test_status}" =~ $statuses ]]
	then
		printf $"Usage: %s: -n 'test id' [-f 'test file name'] -s '%s' [-d duration] [-o 'stdout'] [-e 'stderr'] [-x exit code]\\n" \
			"$0" "$statuses"
		exit 2
	fi
	shift $((OPTIND - 1))
	unset OPTIND

	set -o xtrace
	appveyor UpdateTest \'"${test_id}"\' \
		-Framework MSTest \
		${test_file:+-FileName "${test_file}"} \
		-Outcome "${test_status}" \
		-Duration "${test_duration}" \
		${test_stdout:+-StdOut "${test_stdout}"} \
		${test_stderr:+-StdErr "${test_stderr}"}
	# set +o xtrace

}

on_test_change "$@"
