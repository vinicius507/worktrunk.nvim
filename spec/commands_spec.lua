describe("worktrunk.commands", function()
  local commands
  local helpers = require("spec.helpers")
  local restore_ui

  before_each(function()
    package.loaded["worktrunk.commands"] = nil
    package.loaded["worktrunk.config"] = nil
    require("worktrunk.config").setup()
    commands = require("worktrunk.commands")
    restore_ui = helpers.mock_vim_ui()
  end)

  after_each(function()
    if restore_ui then
      restore_ui()
    end
  end)

  describe("complete", function()
    it("should complete subcommands", function()
      local completions = commands.complete("sw", "Worktree sw", 12)

      assert.is_table(completions)
      -- Check if "switch" is in completions
      local has_switch = false
      for _, v in ipairs(completions) do
        if v == "switch" then
          has_switch = true
          break
        end
      end
      assert.is_true(has_switch, "Expected 'switch' in completions, got: " .. vim.inspect(completions))

      -- Check if "list" is in completions (should not be, since it doesn't start with "sw")
      local has_list = false
      for _, v in ipairs(completions) do
        if v == "list" then
          has_list = true
          break
        end
      end
      assert.is_false(has_list, "Expected 'list' NOT in completions when arglead is 'sw'")
    end)

    it("should complete branch names for switch command", function()
      local mock_result = helpers.mock_wt_list_output({
        { branch = "main", path = "/home/user/project" },
        { branch = "feature-branch", path = "/home/user/project.feature-branch" },
      })

      local restore = helpers.mock_vim_system(mock_result)

      local completions = commands.complete("", "Worktree switch ", 16)

      assert.is_table(completions)
      assert.is_true(vim.tbl_contains(completions, "main"))
      assert.is_true(vim.tbl_contains(completions, "feature-branch"))

      restore()
    end)

    it("should return empty table for unknown subcommand", function()
      local completions = commands.complete("", "Worktree unknown ", 18)

      assert.is_table(completions)
      assert.are.equal(0, #completions)
    end)
  end)

  describe("execute", function()
    it("should execute list subcommand", function()
      local mock_result = helpers.mock_wt_list_output({
        { branch = "main", path = "/home/user/project" },
      })

      local restore = helpers.mock_vim_system(mock_result)

      -- Should not throw
      local ok = pcall(function()
        commands.execute("list")
      end)

      assert.is_true(ok)

      restore()
    end)

    it("should execute switch subcommand with branch", function()
      local mock_result = {
        code = 0,
        stdout = "Switched to feature-branch",
        stderr = "",
      }

      local restore = helpers.mock_vim_system(mock_result)

      local ok = pcall(function()
        commands.execute("switch feature-branch")
      end)

      assert.is_true(ok)

      restore()
    end)

    it("should show error for unknown subcommand", function()
      local notified = false
      local original_notify = vim.notify
      vim.notify = function(msg, level)
        notified = true
        assert.is_truthy(msg:match("Unknown subcommand"))
      end

      commands.execute("unknown")

      assert.is_true(notified)

      vim.notify = original_notify
    end)

    it("should default to list when no subcommand provided", function()
      local mock_result = helpers.mock_wt_list_output({
        { branch = "main", path = "/home/user/project" },
      })

      local restore = helpers.mock_vim_system(mock_result)

      -- Should not throw
      local ok = pcall(function()
        commands.execute("")
      end)

      assert.is_true(ok)

      restore()
    end)

    it("should execute merge subcommand with target", function()
      local mock_result = {
        code = 0,
        stdout = "Merged feature-branch into main",
        stderr = "",
      }

      local restore = helpers.mock_vim_system(mock_result)

      local ok = pcall(function()
        commands.execute("merge main")
      end)

      assert.is_true(ok)

      restore()
    end)

    it("should execute merge subcommand with flags", function()
      local mock_result = {
        code = 0,
        stdout = "Merged with --no-squash --no-ff",
        stderr = "",
      }

      local restore = helpers.mock_vim_system(mock_result)

      local ok = pcall(function()
        commands.execute("merge --no-squash --no-ff develop")
      end)

      assert.is_true(ok)

      restore()
    end)

    it("should execute step commit subcommand", function()
      local mock_result = {
        code = 0,
        stdout = "Committed changes",
        stderr = "",
      }

      local restore = helpers.mock_vim_system(mock_result)

      local ok = pcall(function()
        commands.execute("step commit")
      end)

      assert.is_true(ok)

      restore()
    end)

    it("should execute step squash subcommand", function()
      local mock_result = {
        code = 0,
        stdout = "Squashed commits",
        stderr = "",
      }

      local restore = helpers.mock_vim_system(mock_result)

      local ok = pcall(function()
        commands.execute("step squash")
      end)

      assert.is_true(ok)

      restore()
    end)

    it("should show info for step without subcommand", function()
      local ok = pcall(function()
        commands.execute("step")
      end)

      assert.is_true(ok)
    end)
  end)

  describe("parse_args", function()
    describe("parse_switch_args", function()
      it("should parse switch args with --create flag", function()
        local branch, opts = commands.parse_switch_args({ "--create", "new-branch" })

        assert.are.equal("new-branch", branch)
        assert.is_true(opts.create)
      end)

      it("should parse switch args with -c shorthand", function()
        local branch, opts = commands.parse_switch_args({ "-c", "new-branch" })

        assert.are.equal("new-branch", branch)
        assert.is_true(opts.create)
      end)

      it("should parse switch args with --base flag", function()
        local branch, opts = commands.parse_switch_args({ "--create", "--base=main", "new-branch" })

        assert.are.equal("new-branch", branch)
        assert.is_true(opts.create)
        assert.are.equal("main", opts.base)
      end)

      it("should parse switch args with -b shorthand", function()
        local branch, opts = commands.parse_switch_args({ "-c", "-b", "develop", "new-branch" })

        assert.are.equal("new-branch", branch)
        assert.are.equal("develop", opts.base)
      end)

      it("should parse switch args with --execute flag", function()
        local branch, opts = commands.parse_switch_args({ "--execute=nvim", "feature-branch" })

        assert.are.equal("feature-branch", branch)
        assert.are.equal("nvim", opts.execute)
      end)

      it("should parse switch args with -x shorthand", function()
        local branch, opts = commands.parse_switch_args({ "-x", "code .", "feature-branch" })

        assert.are.equal("feature-branch", branch)
        assert.are.equal("code .", opts.execute)
      end)

      it("should parse switch args with --clobber flag", function()
        local branch, opts = commands.parse_switch_args({ "--clobber", "feature-branch" })

        assert.are.equal("feature-branch", branch)
        assert.is_true(opts.clobber)
      end)

      it("should parse switch args with --no-cd flag", function()
        local branch, opts = commands.parse_switch_args({ "--no-cd", "feature-branch" })

        assert.are.equal("feature-branch", branch)
        assert.is_true(opts.no_cd)
      end)

      it("should parse switch args with --branches flag", function()
        local branch, opts = commands.parse_switch_args({ "--branches" })

        assert.is_nil(branch)
        assert.is_true(opts.branches)
      end)

      it("should parse switch args with --remotes flag", function()
        local branch, opts = commands.parse_switch_args({ "--remotes" })

        assert.is_nil(branch)
        assert.is_true(opts.remotes)
      end)

      it("should parse switch args with -y/--yes flag", function()
        local branch, opts = commands.parse_switch_args({ "-y", "feature-branch" })
        assert.are.equal("feature-branch", branch)
        assert.is_true(opts.yes)

        branch, opts = commands.parse_switch_args({ "--yes", "feature-branch" })
        assert.are.equal("feature-branch", branch)
        assert.is_true(opts.yes)
      end)

      it("should parse switch args with --no-verify flag", function()
        local branch, opts = commands.parse_switch_args({ "--no-verify", "feature-branch" })

        assert.are.equal("feature-branch", branch)
        assert.is_true(opts.no_verify)
      end)

      it("should parse switch args with multiple flags", function()
        local branch, opts = commands.parse_switch_args({
          "--create",
          "--base=main",
          "--clobber",
          "--yes",
          "--no-verify",
          "new-branch",
        })

        assert.are.equal("new-branch", branch)
        assert.is_true(opts.create)
        assert.are.equal("main", opts.base)
        assert.is_true(opts.clobber)
        assert.is_true(opts.yes)
        assert.is_true(opts.no_verify)
      end)

      it("should recognize ^ shortcut for default branch", function()
        local branch, opts = commands.parse_switch_args({ "^" })

        assert.are.equal("^", branch)
        assert.is_nil(opts.create)
      end)

      it("should recognize - shortcut for previous worktree", function()
        local branch, opts = commands.parse_switch_args({ "-" })

        assert.are.equal("-", branch)
      end)

      it("should recognize @ shortcut for current branch", function()
        local branch, opts = commands.parse_switch_args({ "@" })

        assert.are.equal("@", branch)
      end)

      it("should recognize pr:N shortcut for GitHub PR", function()
        local branch, opts = commands.parse_switch_args({ "pr:123" })

        assert.are.equal("pr:123", branch)
      end)

      it("should recognize mr:N shortcut for GitLab MR", function()
        local branch, opts = commands.parse_switch_args({ "mr:456" })

        assert.are.equal("mr:456", branch)
      end)

      it("should return nil branch when no branch specified", function()
        local branch, opts = commands.parse_switch_args({ "--branches" })

        assert.is_nil(branch)
        assert.is_true(opts.branches)
      end)
    end)

    describe("parse_remove_args", function()
      it("should parse remove args with force option", function()
        local branches, opts = commands.parse_remove_args({ "--force", "old-branch" })

        assert.are.equal(1, #branches)
        assert.are.equal("old-branch", branches[1])
        assert.is_true(opts.force)
      end)

      it("should parse remove args with -f shorthand", function()
        local branches, opts = commands.parse_remove_args({ "-f", "branch1" })

        assert.are.equal(1, #branches)
        assert.is_true(opts.force)
      end)

      it("should parse remove args with -D/--force-delete flag", function()
        local branches, opts = commands.parse_remove_args({ "-D", "unmerged-branch" })

        assert.are.equal(1, #branches)
        assert.is_true(opts.force_delete)

        branches, opts = commands.parse_remove_args({ "--force-delete", "unmerged-branch" })
        assert.is_true(opts.force_delete)
      end)

      it("should parse remove args with --no-delete-branch flag", function()
        local branches, opts = commands.parse_remove_args({ "--no-delete-branch", "feature-branch" })

        assert.are.equal(1, #branches)
        assert.is_true(opts.no_delete_branch)
      end)

      it("should parse remove args with --foreground flag", function()
        local branches, opts = commands.parse_remove_args({ "--foreground", "feature-branch" })

        assert.are.equal(1, #branches)
        assert.is_true(opts.foreground)
      end)

      it("should parse remove args with -y/--yes flag", function()
        local branches, opts = commands.parse_remove_args({ "-y", "branch1" })
        assert.is_true(opts.yes)

        branches, opts = commands.parse_remove_args({ "--yes", "branch1" })
        assert.is_true(opts.yes)
      end)

      it("should parse remove args with --no-verify flag", function()
        local branches, opts = commands.parse_remove_args({ "--no-verify", "branch1" })

        assert.is_true(opts.no_verify)
      end)

      it("should support multiple branches", function()
        local branches, opts = commands.parse_remove_args({ "branch1", "branch2", "branch3" })

        assert.are.equal(3, #branches)
        assert.are.equal("branch1", branches[1])
        assert.are.equal("branch2", branches[2])
        assert.are.equal("branch3", branches[3])
      end)

      it("should support multiple branches with flags", function()
        local branches, opts = commands.parse_remove_args({
          "--force",
          "--yes",
          "branch1",
          "branch2",
        })

        assert.are.equal(2, #branches)
        assert.is_true(opts.force)
        assert.is_true(opts.yes)
      end)

      it("should return empty branches table when only flags provided", function()
        local branches, opts = commands.parse_remove_args({ "--force", "--yes" })

        assert.are.equal(0, #branches)
        assert.is_true(opts.force)
      end)
    end)

    describe("parse_list_args", function()
      it("should parse list args with --branches flag", function()
        local opts = commands.parse_list_args({ "--branches" })

        assert.is_true(opts.branches)
      end)

      it("should parse list args with --remotes flag", function()
        local opts = commands.parse_list_args({ "--remotes" })

        assert.is_true(opts.remotes)
      end)

      it("should parse list args with --full flag", function()
        local opts = commands.parse_list_args({ "--full" })

        assert.is_true(opts.full)
      end)

      it("should parse list args with --progressive flag", function()
        local opts = commands.parse_list_args({ "--progressive" })

        assert.is_true(opts.progressive)
      end)

      it("should parse list args with multiple flags", function()
        local opts = commands.parse_list_args({ "--branches", "--remotes", "--full" })

        assert.is_true(opts.branches)
        assert.is_true(opts.remotes)
        assert.is_true(opts.full)
      end)

      it("should return empty opts when no args provided", function()
        local opts = commands.parse_list_args({})

        assert.is_table(opts)
        assert.is_nil(opts.branches)
      end)
    end)

    describe("parse_merge_args", function()
      it("should parse merge args with target branch", function()
        local target, opts = commands.parse_merge_args({ "develop" })

        assert.are.equal("develop", target)
      end)

      it("should parse merge args with --no-squash flag", function()
        local target, opts = commands.parse_merge_args({ "--no-squash", "main" })

        assert.are.equal("main", target)
        assert.is_true(opts.no_squash)
      end)

      it("should parse merge args with --no-commit flag", function()
        local target, opts = commands.parse_merge_args({ "--no-commit" })

        assert.is_nil(target)
        assert.is_true(opts.no_commit)
      end)

      it("should parse merge args with --no-rebase flag", function()
        local target, opts = commands.parse_merge_args({ "--no-rebase" })

        assert.is_true(opts.no_rebase)
      end)

      it("should parse merge args with --no-remove flag", function()
        local target, opts = commands.parse_merge_args({ "--no-remove" })

        assert.is_true(opts.no_remove)
      end)

      it("should parse merge args with --no-ff flag", function()
        local target, opts = commands.parse_merge_args({ "--no-ff" })

        assert.is_true(opts.no_ff)
      end)

      it("should parse merge args with --stage flag", function()
        local target, opts = commands.parse_merge_args({ "--stage=tracked" })

        assert.are.equal("tracked", opts.stage)
      end)

      it("should parse merge args with -y/--yes flag", function()
        local target, opts = commands.parse_merge_args({ "-y" })
        assert.is_true(opts.yes)

        target, opts = commands.parse_merge_args({ "--yes" })
        assert.is_true(opts.yes)
      end)

      it("should parse merge args with --no-verify flag", function()
        local target, opts = commands.parse_merge_args({ "--no-verify" })

        assert.is_true(opts.no_verify)
      end)

      it("should parse merge args with multiple flags", function()
        local target, opts = commands.parse_merge_args({
          "--no-squash",
          "--no-ff",
          "--stage=all",
          "--yes",
          "--no-verify",
          "develop",
        })

        assert.are.equal("develop", target)
        assert.is_true(opts.no_squash)
        assert.is_true(opts.no_ff)
        assert.are.equal("all", opts.stage)
        assert.is_true(opts.yes)
        assert.is_true(opts.no_verify)
      end)

      it("should return nil target when no target provided", function()
        local target, opts = commands.parse_merge_args({})

        assert.is_nil(target)
      end)
    end)

    describe("parse_step_args", function()
      it("should parse step args with commit subcommand", function()
        local subcmd, opts = commands.parse_step_args({ "commit" })

        assert.are.equal("commit", subcmd)
      end)

      it("should parse step args with squash subcommand", function()
        local subcmd, opts = commands.parse_step_args({ "squash" })

        assert.are.equal("squash", subcmd)
      end)

      it("should parse step args with rebase subcommand", function()
        local subcmd, opts = commands.parse_step_args({ "rebase" })

        assert.are.equal("rebase", subcmd)
      end)

      it("should parse step args with push subcommand", function()
        local subcmd, opts = commands.parse_step_args({ "push" })

        assert.are.equal("push", subcmd)
      end)

      it("should parse step args with diff subcommand", function()
        local subcmd, opts = commands.parse_step_args({ "diff" })

        assert.are.equal("diff", subcmd)
      end)

      it("should parse step args with copy-ignored subcommand", function()
        local subcmd, opts = commands.parse_step_args({ "copy-ignored" })

        assert.are.equal("copy-ignored", subcmd)
      end)

      it("should parse step args with --stage flag for commit", function()
        local subcmd, opts = commands.parse_step_args({ "commit", "--stage=tracked" })

        assert.are.equal("commit", subcmd)
        assert.are.equal("tracked", opts.stage)
      end)

      it("should return nil subcommand when no args provided", function()
        local subcmd, opts = commands.parse_step_args({})

        assert.is_nil(subcmd)
      end)
    end)
  end)
end)
