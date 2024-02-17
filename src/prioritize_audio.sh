#!/usr/bin/bash

# prioritize_audio.sh: Increases the priority of audio (and related) programs.
# Copyright (C) 2024  Ahmad Al-Shaghanbi
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with this program; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

program_name=$(basename -- "$0")
skip_root_check=0

if [[ "$1" = "--no-root-check" ]]; then
	skip_root_check=1
fi

if ! (( skip_root_check )) && [[ "$UID" -ne 0 ]]; then
	printf -- "%s: This script must be run as root!\n" "$program_name"
	exit 1
fi

pids=($(pidof bluetoothd) $(pidof pipewire) $(pidof pulseaudio) $(pidof wireplumber) $(pidof pipewire-media-session))

for i in "${pids[@]}"; do
	renice --priority -11 --pid "$i"
done
