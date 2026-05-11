local utils = require("chatgpt.utils")

describe("utils.table_shallow_copy", function()
  it("should return an empty table when given an empty table", function()
    local tbl = {}
    local result = utils.table_shallow_copy(tbl)
    assert.are.same({}, result)
    assert.is_not.equal(tbl, result)
  end)

  it("should copy all elements of a simple table", function()
    local tbl = { a = 1, b = 2, c = "test" }
    local result = utils.table_shallow_copy(tbl)
    assert.are.same(tbl, result)
    assert.is_not.equal(tbl, result)
  end)

  it("should perform a shallow copy of nested tables", function()
    local nested = { x = 1 }
    local tbl = { a = nested }
    local result = utils.table_shallow_copy(tbl)
    assert.are.same(tbl, result)
    assert.is.equal(tbl.a, result.a)
    assert.is_not.equal(tbl, result)
  end)

  it("should handle mixed key types", function()
    local tbl = { [1] = "one", ["two"] = 2, [true] = "boolean" }
    local result = utils.table_shallow_copy(tbl)
    assert.are.same(tbl, result)
    assert.is_not.equal(tbl, result)
  end)
end)

describe("utils.collapsed_openai_params", function()
  it("should collapse function parameters into constants", function()
    local params = {
      model = function()
        return "gpt-4"
      end,
      temperature = 0.5,
    }
    local result = utils.collapsed_openai_params(params)
    assert.is.equal("gpt-4", result.model)
    assert.is.equal(0.5, result.temperature)
    assert.is.equal("function", type(params.model))
  end)
end)

describe("utils.split", function()
  it("should split string by whitespace", function()
    local text = "hello world  test"
    local result = utils.split(text)
    assert.are.same({ "hello", "world", "test" }, result)
  end)

  it("should return empty table for empty string", function()
    local result = utils.split("")
    assert.are.same({}, result)
  end)
end)

describe("utils.trimText", function()
  it("should not trim if within maxLength", function()
    local text = "hello"
    local result = utils.trimText(text, 10)
    assert.is.equal("hello", result)
  end)

  it("should trim and add ellipsis if exceeds maxLength", function()
    local text = "hello world"
    local result = utils.trimText(text, 5)
    assert.is.equal("he...", result)
  end)
end)

describe("utils.replace_newlines_at_end", function()
  it("should replace trailing newlines with specified number of newlines", function()
    local text = "hello\n\n\n"
    local result = utils.replace_newlines_at_end(text, 1)
    assert.is.equal("hello\n", result)

    result = utils.replace_newlines_at_end("world", 2)
    assert.is.equal("world\n\n", result)
  end)
end)

describe("utils.calculate_percentage_width", function()
  local mock_vim_api

  before_each(function()
    -- Initialize vim.api if not running in Neovim (like in a bare Lua environment mock)
    -- But since this is a Neovim plugin, vim.api is normally available.
    -- We can use stub from luassert if available, or manually backup the function
    if not _G.vim then
      _G.vim = { api = {} }
    end
    mock_vim_api = _G.vim.api.nvim_get_option
    _G.vim.api.nvim_get_option = function(opt)
      if opt == "columns" then
        return 100
      end
      return 0
    end
  end)

  after_each(function()
    if mock_vim_api then
      _G.vim.api.nvim_get_option = mock_vim_api
    else
      _G.vim.api.nvim_get_option = nil
    end
  end)

  it("should calculate correct percentage width", function()
    local result = utils.calculate_percentage_width("50%")
    assert.is.equal(50, result)

    result = utils.calculate_percentage_width("33.3%")
    assert.is.equal(33, result) -- Because of math.floor
  end)

  it("should throw error if input is not a string", function()
    assert.has_error(function()
      utils.calculate_percentage_width(50)
    end, "Input must be a string with a percent sign at the end (e.g. '50%').")
  end)

  it("should throw error if input string does not end with percent sign", function()
    assert.has_error(function()
      utils.calculate_percentage_width("50")
    end, "Input must be a string with a percent sign at the end (e.g. '50%').")

    assert.has_error(function()
      utils.calculate_percentage_width("50% ")
    end, "Input must be a string with a percent sign at the end (e.g. '50%').")
  end)
end)
