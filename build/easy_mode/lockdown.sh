#!/bin/sh
printf '\033c\033]0;%s\a' Lockdown
base_path="$(dirname "$(realpath "$0")")"
"$base_path/lockdown.x86_64" "$@"
