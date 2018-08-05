#!/bin/sh

set -o errexit
export POSIXLY_CORRECT=1

on_test_creation() {

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

	set -o xtrace
	appveyor AddTest "${test_id}" \
		-Framework MSTest \
		${test_filename:+-FileName "${test_filename}"}
	# set +o xtrace

}

on_test_creation "$@"
