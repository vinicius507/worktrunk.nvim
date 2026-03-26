#!/bin/bash
set -e

eval "$(luarocks --lua-version=5.1 path)"

# Run busted with nlua
exec busted "$@"
