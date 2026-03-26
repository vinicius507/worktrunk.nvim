describe("worktrunk.config", function()
  local config

  before_each(function()
    package.loaded["worktrunk.config"] = nil
    vim.g.worktrunk = nil
    config = require("worktrunk.config")
  end)

  after_each(function()
    vim.g.worktrunk = nil
  end)

  describe("setup", function()
    it("should merge user config with defaults", function()
      config.setup({ auto_cd = false })
      local cfg = config.get()

      assert.are.equal(false, cfg.auto_cd)
      assert.are.equal(true, cfg.confirm_remove)
      assert.are.equal(true, cfg.enable_events)
      assert.are.equal("wt", cfg.wt_cmd)
    end)

    it("should use defaults when no config provided", function()
      config.setup()
      local cfg = config.get()

      assert.are.equal(true, cfg.auto_cd)
      assert.are.equal(true, cfg.confirm_remove)
      assert.are.equal(true, cfg.enable_events)
      assert.are.equal("wt", cfg.wt_cmd)
    end)

    it("should validate wt_cmd is a string", function()
      local ok, err = pcall(function()
        config.setup({ wt_cmd = 123 })
      end)

      assert.is_false(ok)
      assert.is_truthy(err:match("wt_cmd"))
    end)

    it("should support vim.g.worktrunk configuration", function()
      vim.g.worktrunk = { auto_cd = false }
      config.setup()
      local cfg = config.get()

      assert.are.equal(false, cfg.auto_cd)
    end)

    it("should merge nested ui config", function()
      config.setup({
        ui = {
          show_full_paths = true,
        },
      })
      local cfg = config.get()

      assert.are.equal(true, cfg.ui.show_full_paths)
      assert.are.equal(60, cfg.ui.picker_width)
    end)

    it("should merge nested hooks config", function()
      config.setup({
        hooks = {
          timeout = 30,
        },
      })
      local cfg = config.get()

      assert.are.equal(30, cfg.hooks.timeout)
      assert.are.equal(true, cfg.hooks.async)
    end)
  end)

  describe("get", function()
    it("should return nil before setup", function()
      local cfg = config.get()
      assert.is_nil(cfg)
    end)

    it("should return config after setup", function()
      config.setup()
      local cfg = config.get()
      assert.is_not_nil(cfg)
      assert.are.equal("wt", cfg.wt_cmd)
    end)
  end)
end)
