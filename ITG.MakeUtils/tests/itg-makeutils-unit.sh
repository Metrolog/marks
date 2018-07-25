#!/bin/sh

# enable debug mode
if [ "$DEBUG" = "yes" ]; then
	set -x
fi

THIS_SCRIPT="$0"
MAKE_TESTS_DIR=$(dirname "$0")
MAKE_COMMON_DIR=$(dirname "$MAKE_TESTS_DIR")

main() {
	if [ $# -lt 1 ]; then
		"$THIS_SCRIPT" --help
		exit 1
	fi

	export POSIXLY_CORRECT=1

	# shellcheck source=../shflags/shflags
	. "$MAKE_COMMON_DIR/shflags/shflags"
	FLAGS_PARENT="git flow"

	DEFINE_boolean show_commands false 'show actions taken (git commands)' g

	FLAGS "$@" || exit $?
	eval set -- "${FLAGS_ARGV}"



	# sanity checks
	SUBCOMMAND="$1"; shift

	if [ ! -e "$GITFLOW_DIR/git-flow-$SUBCOMMAND" ]; then
		usage
		exit 1
	fi

	# run command
	. "$GITFLOW_DIR/git-flow-$SUBCOMMAND"
	FLAGS_PARENT="git flow $SUBCOMMAND"

	# test if the first argument is a flag (i.e. starts with '-')
	# in that case, we interpret this arg as a flag for the default
	# command
	SUBACTION="default"
	if [ "$1" != "" ] && { ! echo "$1" | grep -q "^-"; } then
		SUBACTION="$1"; shift
	fi
	if ! type "cmd_$SUBACTION" >/dev/null 2>&1; then
		warn "Unknown subcommand: '$SUBACTION'"
		usage
		exit 1
	fi

	# run the specified action
	if [ "$SUBACTION" != "help" ] && [ "$SUBCOMMAND" != "init" ] ; then
    	init
	fi
	"cmd_$SUBACTION" "$@"


}

main "$@"
