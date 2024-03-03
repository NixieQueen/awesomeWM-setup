#!/usr/bin/env bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

_launchudev() {
	if ! pgrep -f "screenudev.py"; then
		source $SCRIPT_DIR/venv/bin/activate
		$SCRIPT_DIR/screenudev.py &
	fi
}

_launchudev
