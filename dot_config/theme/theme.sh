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

# "#rrggbb" -> "r;g;b" decimal, for building truecolor SGR/LS_COLORS codes.
_hex_to_rgb() {
	local hex="${1#\#}"
	printf '%d;%d;%d' "0x${hex:0:2}" "0x${hex:2:2}" "0x${hex:4:2}"
}

# Builds LS_COLORS for `ls --color` from the 16-slot palette of the given
# mode, using truecolor (38;2;r;g;b) so it matches the palette exactly
# instead of approximating to the 8 basic ANSI hues.
#
# Directories intentionally do NOT use blue in dark mode: this whole dark
# palette is blue-based, so any blue directory color fights the navy
# background for contrast (the illegible-directories problem with the
# distro default). Gold is used instead for a color that reliably pops.
_set_ls_colors() {
	local mode="$1" prefix
	if [ "$mode" = "dark" ]; then
		prefix="DARK_COLOR"
	else
		prefix="LIGHT_COLOR"
	fi

	local -A c
	local i varname
	for i in $(seq 0 15); do
		varname="${prefix}${i}"
		c[$i]="01;38;2;$(_hex_to_rgb "${!varname}")"
	done

	local dir link exe broken pipe socket device archive image video audio doc
	if [ "$mode" = "dark" ]; then
		dir="${c[11]}" # gold - kept off-blue on purpose, see above
		link="${c[14]}" # teal
		exe="${c[10]}" # bright green
		broken="${c[9]}" # bright red
		pipe="${c[3]}" # muted gold
		socket="${c[13]}" # bright purple
		device="${c[11]}" # gold
		archive="${c[5]}" # purple
		image="${c[13]}" # bright purple
		video="${c[6]}" # cyan (exact accent)
		audio="${c[4]}" # blue (exact accent)
		doc="${c[7]}" # dim white
	else
		dir="${c[4]}" # blue (exact accent)
		link="${c[6]}" # cyan (exact accent)
		exe="${c[2]}" # green (exact accent)
		broken="${c[1]}" # red
		pipe="${c[3]}" # yellow (exact accent)
		socket="${c[5]}" # magenta
		device="${c[11]}" # burnt orange (exact accent)
		archive="${c[11]}" # burnt orange (exact accent)
		image="${c[13]}" # bright magenta
		video="${c[14]}" # bright cyan
		audio="${c[6]}" # cyan
		doc="${c[8]}" # muted olive
	fi

	LS_COLORS="di=$dir:ln=$link:ex=$exe:or=$broken:mi=$broken:pi=$pipe:so=$socket"
	LS_COLORS+=":bd=$device:cd=$device:su=$broken:sg=$dir:tw=$exe:ow=$link:st=$socket"
	LS_COLORS+=":*.tar=$archive:*.gz=$archive:*.zip=$archive:*.7z=$archive:*.rar=$archive:*.bz2=$archive:*.xz=$archive:*.zst=$archive"
	LS_COLORS+=":*.jpg=$image:*.jpeg=$image:*.png=$image:*.gif=$image:*.bmp=$image:*.svg=$image:*.webp=$image:*.ico=$image"
	LS_COLORS+=":*.mp4=$video:*.mkv=$video:*.avi=$video:*.mov=$video:*.webm=$video"
	LS_COLORS+=":*.mp3=$audio:*.flac=$audio:*.wav=$audio:*.ogg=$audio:*.m4a=$audio"
	LS_COLORS+=":*.pdf=$doc:*.md=$doc:*.txt=$doc:*.doc=$doc:*.docx=$doc:*.rtf=$doc"
	export LS_COLORS
}

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

	_set_ls_colors "$mode"

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
	echo

	echo "ls --color file-type samples (LS_COLORS):"
	local key val
	for key in di ln ex or; do
		val=$(printf '%s' "$LS_COLORS" | tr ':' '\n' | grep "^${key}=" | cut -d= -f2)
		printf '  \e[%sm%-12s\e[0m' "$val" "$key"
	done
	echo
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
