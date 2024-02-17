#!/usr/bin/bash

# setclock.sh: Downclocks the cpu or resets it to kernel locked.
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
version_major=1
version_minor=0
version_patch=0

show_version() {
	printf -- "%s: %s.%s.%s\n" "$program_name" "$version_major" "$version_minor" "$version_patch"
	exit 0
}

show_usage() {
	printf -- "Usage: %s [...OPTIONS]\n" "$program_name"
	printf -- "\nOPTIONS:\n"
	printf -- "  -h  --help     Show this help message.\n"
	printf -- "  -v  --version  Show version number and exit.\n"
	printf -- "  -s  --skip-root-check Skip checking if running as root.\n"
	printf -- "  -f  --force    Skip all checks."
	printf -- "  -u  --up       Set max clock frequency to the maximum.\n"
	printf -- "  -d  --down     Set max clock frequency to the minimum.\n"
	printf -- "\n"
	exit "${1:-0}"
}

OPTS=$(getopt -o "hvsfud" -l "help,version,force,skip-root-check,up,down" -n "$program_name" -- "$@")
if [[ "$?" -ne 0 ]]; then
	show_usage 1
fi

eval set -- "$OPTS"
unset OPTS

skip_root_check=0
clock=0

while true; do
	case "$1" in
		'-v'|'--version')
			show_version
		;;
		'-h'|'--help')
			show_usage 0
		;;
		'-s'|'--skip-root-check')
			skip_root_check=1
		;;
		'-f'|'--force')
			skip_root_check=1
		;;
		'-u'|'--up')
			clock=3.4GHz
		;;
		'-d'|'--down')
			clock=0.4GHz
		;;
		'--') break;;
	esac
	shift
done

if ! (( skip_root_check )) && [[ $UID -ne 0 ]]; then
	printf -- "%s: This script must be run as root!\n" "$program_name"
	exit 1
fi

cpupower frequency-set -u "$clock"
grep -F "cpu MHz" /proc/cpuinfo
