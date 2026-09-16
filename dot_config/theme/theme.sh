#!/bin/bash
# Sets the terminal's background/foreground colors via OSC 10/11 escape
# sequences and remembers the chosen mode across shells.
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

	local bg fg
	if [ "$mode" = "dark" ]; then
		bg="$DARK_BG"
		fg="$DARK_FG"
	else
		mode="light"
		bg="$LIGHT_BG"
		fg="$LIGHT_FG"
	fi

	printf '\e]11;%s\a' "$bg"
	printf '\e]10;%s\a' "$fg"

	export THEME_MODE="$mode"
	mkdir -p "$(dirname "$THEME_STATE_FILE")"
	printf '%s' "$mode" >"$THEME_STATE_FILE"
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
	*)
		echo "Usage: theme {light|dark|toggle}" >&2
		return 1
		;;
	esac
}

# Restore the last chosen mode for this session, defaulting to light.
_theme_apply "$(cat "$THEME_STATE_FILE" 2>/dev/null || echo light)"
