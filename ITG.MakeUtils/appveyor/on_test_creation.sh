#!/bin/sh

set +o errexit

export POSIXLY_CORRECT=1

readonly THIS_SCRIPT="$0"
readonly THIS_SCRIPT_FILENAME=$(basename "$THIS_SCRIPT")
readonly MAKE_APPVEYOR_DIR=$(dirname "$THIS_SCRIPT")
readonly MAKE_COMMON_DIR=$(dirname "$MAKE_APPVEYOR_DIR")

on_test_creation() {

	if [ $# -lt 1 ]; then
		( on_test_creation --help )
		exit 1
	fi

	# shellcheck source=../shflags/shflags
	. "$MAKE_COMMON_DIR/shflags/shflags"
	FLAGS_PARENT="$THIS_SCRIPT_FILENAME"

	DEFINE_string test_id '' $"test id (slug)"

	FLAGS "$@" || exit $?
	eval set -- "${FLAGS_ARGV}"

	set -o errexit
	appveyor AddTest "${FLAGS_test_id:?}" \
		-Framework MSTest \
		-FileName "${FLAGS_test_file_name:-}"

}

on_test_creation "$@"
