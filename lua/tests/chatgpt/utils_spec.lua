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
