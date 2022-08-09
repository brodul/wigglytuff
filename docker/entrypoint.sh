#!/usr/bin/env nix-shell
#!nix-shell --argstr buildType prod -i bash /app/shell.nix
poetry run "$@"
