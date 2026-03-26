std = "lua51+nvim"

-- Neovim globals
files["spec"].std = "lua51+nvim+busted"

-- Read/write globals
read_globals = {
  "vim",
}

-- Ignore some patterns
ignore = {
  "631", -- line too long
}

-- Exclude directories
exclude_files = {
  ".luarocks/",
  ".rocks/",
}
