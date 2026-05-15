local utils = require("ChatOllama.utils")

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

describe("utils.match_indentation", function()
  it("should return output unchanged if indentation already matches", function()
    local input = "  local function a()\n"
    local output = "  print('hello')\n"
    local result = utils.match_indentation(input, output)
    assert.is.equal(output, result)
  end)

  it("should apply input indentation to output lines", function()
    local input = "    print(a)\n"
    local output = "a = 1\nb = 2\n"
    local result = utils.match_indentation(input, output)
    assert.is.equal("    a = 1\n    b = 2\n", result)
  end)

  it("should handle empty lines in output without adding trailing whitespace", function()
    local input = "  def func():\n"
    local output = "pass\n\nprint(1)\n"
    local result = utils.match_indentation(input, output)
    assert.is.equal("  pass\n\n  print(1)\n", result)
  end)

  it("should ignore leading newlines when finding indentation", function()
    local input = "\n\n  hello\n"
    local output = "\nworld\n"
    local result = utils.match_indentation(input, output)
    assert.is.equal("\n  world\n", result)
  end)

  it("should handle empty strings and string without newlines", function()
    local input = "\t\tlocal a = 1"
    local output = "b = 2"
    local result = utils.match_indentation(input, output)
    assert.is.equal("\t\tb = 2", result)
  end)
end)
