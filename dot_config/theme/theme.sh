#!/bin/bash
# Sets the terminal's background/foreground colors (OSC 11/10) and the
# 16-slot ANSI palette (OSC 4), then remembers the chosen mode across
# shells.
#
# Palette values live in palette.env (see that file for the single source
# of truth shared with Neovim). Supported by real terminal emulators
# (Windows Terminal, iTerm2, kitty, WezTerm, Alacritty, foot); VS Code's
# integrated terminal ignores these codes, see devcontainer.json instead.

THEME_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
THEME_STATE_FILE="$HOME/.cache/theme_mode"

_theme_apply() {
	local mode="$1"
	# shellcheck source=/dev/null
	source "$THEME_DIR/palette.env"

	local bg fg prefix
	if [ "$mode" = "dark" ]; then
		bg="$DARK_BG"
		fg="$DARK_FG"
		prefix="DARK_COLOR"
	else
		mode="light"
		bg="$LIGHT_BG"
		fg="$LIGHT_FG"
		prefix="LIGHT_COLOR"
	fi

	printf '\e]11;%s\a' "$bg"
	printf '\e]10;%s\a' "$fg"

	local i varname color
	for i in $(seq 0 15); do
		varname="${prefix}${i}"
		color="${!varname}"
		printf '\e]4;%d;%s\a' "$i" "$color"
	done

	export THEME_MODE="$mode"
	mkdir -p "$(dirname "$THEME_STATE_FILE")"
	printf '%s' "$mode" >"$THEME_STATE_FILE"
}

_theme_test() {
	echo "COLORTERM=${COLORTERM:-<unset>} (should be 'truecolor')"
	echo

	echo "16-color ANSI palette (should match your $THEME_MODE-mode hexes):"
	local i
	for i in $(seq 0 15); do
		printf '\e[48;5;%dm  \e[0m' "$i"
	done
	echo
	echo

	echo "Truecolor gradient (should be smooth, not banded, if RGB is supported):"
	local r
	for r in $(seq 0 4 255); do
		printf '\e[48;2;%d;100;150m \e[0m' "$r"
	done
	echo
	echo

	echo "If the gradient above shows visible stripes/bands instead of a smooth"
	echo "fade, or COLORTERM is unset, this terminal is falling back to a"
	echo "256-color approximation instead of exact hex values."
}

theme() {
	case "$1" in
	light | dark)
		_theme_apply "$1"
		;;
	toggle)
		if [ "$THEME_MODE" = "dark" ]; then
			_theme_apply "light"
		else
			_theme_apply "dark"
		fi
		;;
	test)
		_theme_test
		;;
	*)
		echo "Usage: theme {light|dark|toggle|test}" >&2
		return 1
		;;
	esac
}

# Restore the last chosen mode for this session, defaulting to light.
_theme_apply "$(cat "$THEME_STATE_FILE" 2>/dev/null || echo light)"
