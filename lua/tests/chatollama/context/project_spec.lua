local project = require("chatollama.context.project")

describe("ChatOllama.context.project", function()
  local original_vim
  local original_io_open

  before_each(function()
    -- Save original globals
    original_vim = _G.vim
    original_io_open = io.open

    -- Mock package.loaded for config
    package.loaded["ChatOllama.config"] = {
      options = {
        context = {
          project = {
            context_files = { ".ChatOllama.md", "custom.md" }
          }
        }
      }
    }

    -- Mock vim
    _G.vim = {
      fn = {
        getcwd = function() return "/fake/cwd" end,
        finddir = function(name, path)
          if name == ".git" and path:match("/fake/cwd/project") then
            return "/fake/cwd/project/.git"
          end
          return ""
        end,
        fnamemodify = function(path, mods)
          if mods == ":h" then
            return path:gsub("/%.git$", "")
          end
          return path
        end,
      },
      json = {
        decode = function(str)
          if str:match('"react"') then
            return {
              dependencies = { react = "^18.0.0", express = "^4.17.1", ["next"] = "^12.0.0" },
              devDependencies = { typescript = "^4.5.4", tailwindcss = "^3.0.0", vite = "^2.0.0" }
            }
          end
          return {}
        end
      },
      tbl_contains = function(tbl, val)
        for _, v in ipairs(tbl) do
          if v == val then return true end
        end
        return false
      end,
      notify = function(msg, level)
        -- mock notify
      end,
      log = {
        levels = { WARN = 2 }
      }
    }

    -- Reset the module to force re-evaluation of local variables if needed, though mostly functions are called directly
  end)

  after_each(function()
    _G.vim = original_vim
    io.open = original_io_open
  end)

  describe("detect_project_type", function()
    it("should fallback to cwd if .git not found", function()
      io.open = function(path, mode) return nil end
      local detected, root = project.detect_project_type()
      assert.are.same({}, detected)
      assert.are.same("/fake/cwd", root)
    end)

    it("should use .git parent directory as root", function()
      _G.vim.fn.getcwd = function() return "/fake/cwd/project/src" end
      io.open = function(path, mode) return nil end
      local detected, root = project.detect_project_type()
      assert.are.same({}, detected)
      assert.are.same("/fake/cwd/project", root)
    end)

    it("should detect single manifest file", function()
      io.open = function(path, mode)
        if path:match("package%.json$") then
          return {
            close = function() end,
            read = function() return "{}" end
          }
        end
        return nil
      end

      local detected, root = project.detect_project_type()
      assert.are.same(1, #detected)
      assert.are.same("package.json", detected[1].file)
      assert.are.same("javascript", detected[1].language)
    end)
  end)

  describe("generate_summary", function()
    it("should return nil if no manifests detected", function()
      io.open = function() return nil end
      assert.is_nil(project.generate_summary())
    end)

    it("should extract details from package.json", function()
      io.open = function(path, mode)
        if path:match("package%.json$") then
          return {
            close = function() end,
            read = function()
              return '{"dependencies": {"react": "1"}}'
            end
          }
        end
        return nil
      end

      local summary = project.generate_summary()
      assert.is_true(summary:match("Typescript") ~= nil)
      assert.is_true(summary:match("React") ~= nil)
      assert.is_true(summary:match("Express") ~= nil)
      assert.is_true(summary:match("Next%.js") ~= nil)
      assert.is_true(summary:match("Tailwind") ~= nil)
      assert.is_true(summary:match("Vite") ~= nil)
    end)

    it("should extract details from Cargo.toml", function()
      io.open = function(path, mode)
        if path:match("Cargo%.toml$") then
          return {
            close = function() end,
            read = function()
              return '[dependencies]\ntokio = "1.0"\nactix = "2.0"'
            end
          }
        end
        return nil
      end

      local summary = project.generate_summary()
      assert.is_true(summary:match("Rust project") ~= nil)
      assert.is_true(summary:match("Tokio") ~= nil)
      assert.is_true(summary:match("Actix") ~= nil)
    end)
  end)

  describe("context files", function()
    it("find_context_file should return nil if not found", function()
      io.open = function() return nil end
      assert.is_nil(project.find_context_file())
    end)

    it("find_context_file should return content if found", function()
      io.open = function(path, mode)
        if path:match("%.ChatOllama%.md$") then
          return {
            close = function() end,
            read = function() return "context content" end
          }
        end
        return nil
      end

      local ctx = project.find_context_file()
      assert.is_not_nil(ctx)
      assert.are.same(".ChatOllama.md", ctx.name)
      assert.are.same("context content", ctx.content)
    end)

    it("get_context should return formatted context item", function()
      io.open = function(path, mode)
        if path:match("%.ChatOllama%.md$") then
          return {
            close = function() end,
            read = function() return "context content" end
          }
        end
        return nil
      end

      local ctx = project.get_context()
      assert.is_not_nil(ctx)
      assert.are.same("project", ctx.type)
      assert.are.same(".ChatOllama.md", ctx.name)
      assert.are.same("context content", ctx.content)
    end)

    it("get_context should return nil and notify if no file", function()
      io.open = function() return nil end
      local notified = false
      _G.vim.notify = function(msg, level)
        notified = true
      end

      local ctx = project.get_context()
      assert.is_nil(ctx)
      assert.is_true(notified)
    end)
  end)
end)
