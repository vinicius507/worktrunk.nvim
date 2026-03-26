.PHONY: test test-file test-coverage test-debug lint format typecheck

# Run all tests
test:
	@eval "$$(luarocks path)" && busted spec/

# Run specific test file
test-file:
	@eval "$$(luarocks path)" && busted $(file)

# Run tests with coverage
test-coverage:
	@eval "$$(luarocks path)" && busted --coverage spec/

# Run tests in current Neovim (for debugging)
test-debug:
	@eval "$$(luarocks path)" && busted spec/

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
