.PHONY: test test-file test-coverage test-debug lint format typecheck

LUA_VERSION = 5.1

# Run all tests
test:
	@eval "$$(luarocks path --lua-version=$(LUA_VERSION))" && busted spec/

# Run specific test file
test-file:
	@eval "$$(luarocks path --lua-version=$(LUA_VERSION))" && busted $(file)

# Run tests with coverage
test-coverage:
	@eval "$$(luarocks path --lua-version=$(LUA_VERSION))" && busted --coverage spec/

# Run tests in current Neovim (for debugging)
test-debug:
	@eval "$$(luarocks path --lua-version=$(LUA_VERSION))" && busted spec/

# Run luacheck
lint:
	@luacheck lua/ spec/

# Run stylua format check
format:
	@stylua --check lua/ spec/

# Apply stylua formatting
format-fix:
	@stylua lua/ spec/

# Run typecheck
typecheck:
	@lua-language-server --check .
