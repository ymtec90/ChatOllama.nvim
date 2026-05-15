-- main module file
local api = require("ChatOllama.api")
local module = require("ChatOllama.module")
local config = require("ChatOllama.config")
local signs = require("ChatOllama.signs")

local M = {}

M.setup = function(options)
  -- set custom highlights
  vim.api.nvim_set_hl(0, "ChatOllamaQuestion", { fg = "#b4befe", italic = true, bold = false, default = true })

  vim.api.nvim_set_hl(0, "ChatOllamaWelcome", { fg = "#9399b2", italic = true, bold = false, default = true })

  vim.api.nvim_set_hl(0, "ChatOllamaTotalTokens", { fg = "#ffffff", bg = "#444444", default = true })
  vim.api.nvim_set_hl(0, "ChatOllamaTotalTokensBorder", { fg = "#444444", default = true })

  vim.api.nvim_set_hl(0, "ChatOllamaTokens", { fg = "#cdd6f4", bg = "#313244", default = true })
  vim.api.nvim_set_hl(0, "ChatOllamaTokensBorder", { fg = "#313244", default = true })

  vim.api.nvim_set_hl(0, "ChatOllamaMessageAction", { fg = "#ffffff", bg = "#1d4c61", italic = true, default = true })

  vim.api.nvim_set_hl(0, "ChatOllamaCompletion", { fg = "#9399b2", italic = true, bold = false, default = true })

  vim.api.nvim_set_hl(0, "ChatOllamaContextRef", { fg = "#89b4fa", bg = "#1e1e2e", bold = true, default = true })

  vim.api.nvim_set_hl(0, "ChatOllamaInlineCode", { fg = "#f38ba8", bg = "#1e1e2e", default = true })
  vim.api.nvim_set_hl(0, "ChatOllamaCodeBlock", { bg = "#181825", default = true })
  vim.api.nvim_set_hl(0, "ChatOllamaCodeBlockHeader", { fg = "#6c7086", bg = "#181825", italic = true, default = true })

  vim.api.nvim_set_hl(0, "ChatOllamaLink", { fg = "#89b4fa", underline = true, default = true })
  vim.api.nvim_set_hl(0, "ChatOllamaBold", { bold = true, default = true })
  vim.api.nvim_set_hl(0, "ChatOllamaItalic", { italic = true, default = true })
  vim.api.nvim_set_hl(0, "ChatOllamaHeader", { fg = "#cba6f7", bold = true, default = true })
  vim.api.nvim_set_hl(0, "ChatOllamaDivider", { fg = "#313244", default = true })
  vim.api.nvim_set_hl(0, "ChatOllamaListMarker", { fg = "#f9e2af", bold = true, default = true })
  vim.api.nvim_set_hl(0, "ChatOllamaBlockquote", { fg = "#a6adc8", italic = true, default = true })
  vim.api.nvim_set_hl(0, "ChatOllamaHRule", { fg = "#45475a", default = true })
  vim.api.nvim_set_hl(0, "ChatOllamaTaskDone", { fg = "#a6e3a1", default = true })
  vim.api.nvim_set_hl(0, "ChatOllamaTaskPending", { fg = "#f9e2af", default = true })
  vim.api.nvim_set_hl(0, "ChatOllamaStrikethrough", { strikethrough = true, fg = "#6c7086", default = true })
  vim.api.nvim_set_hl(0, "ChatOllamaLinkText", { fg = "#89dceb", default = true })
  vim.api.nvim_set_hl(0, "ChatOllamaLinkUrl", { fg = "#6c7086", underline = true, default = true })
  vim.api.nvim_set_hl(0, "ChatOllamaCodeLang", { fg = "#ffffff", bg = "#45475a", bold = true, default = true })
  vim.api.nvim_set_hl(0, "ChatOllamaDiffAdd", { fg = "#a6e3a1", bg = "#1e3a2f", default = true })
  vim.api.nvim_set_hl(0, "ChatOllamaDiffDel", { fg = "#f38ba8", bg = "#3a1e2f", default = true })
  vim.api.nvim_set_hl(0, "ChatOllamaSenderUser", { fg = "#89b4fa", bold = true, default = true })
  vim.api.nvim_set_hl(0, "ChatOllamaSenderAssistant", { fg = "#a6e3a1", bold = true, default = true })

  vim.api.nvim_set_hl(0, "ChatOllamaSessionHeader", { fg = "#6c7086", bold = true, default = true })
  vim.api.nvim_set_hl(0, "ChatOllamaSessionCursor", { fg = "#f9e2af", bold = true, default = true })

  vim.api.nvim_set_hl(0, "ChatOllamaHintsBar", { link = "Normal", default = true })
  vim.api.nvim_set_hl(0, "ChatOllamaHintsKey", { fg = "#f9e2af", bold = true, default = true })
  vim.api.nvim_set_hl(0, "ChatOllamaHintsText", { fg = "#6c7086", default = true })
  vim.api.nvim_set_hl(0, "ChatOllamaHintsSep", { fg = "#45475a", default = true })

  vim.cmd("highlight default link ChatOllamaSelectedMessage ColorColumn")

  config.setup(options)
  api.setup()
  signs.setup()
end

--
-- public methods for the plugin
--

M.openChat = function()
  module.open_chat()
end

M.selectAwesomePrompt = function()
  module.open_chat_with_awesome_prompt()
end

M.open_chat_with = function(opts)
  module.open_chat_with(opts)
end

M.edit_with_instructions = function()
  module.edit_with_instructions()
end

M.run_action = function(opts)
  module.run_action(opts)
end

M.complete_code = module.complete_code

-- Context APIs (deprecated but kept for backwards compatibility)
M.add_context = function()
  local lsp_context = require("ChatOllama.context.lsp")
  lsp_context.get_context(function(item)
    if item then
      local Context = require("ChatOllama.context")
      local ref = Context.make_ref(item)
      Context.add(ref, item)
      vim.notify(string.format("Context added: %s", ref), vim.log.levels.INFO)
    end
  end)
end

M.add_project_context = function()
  local project_context = require("ChatOllama.context.project")
  local item = project_context.get_context()
  if item then
    local Context = require("ChatOllama.context")
    local ref = Context.make_ref(item)
    Context.add(ref, item)
    vim.notify(string.format("Context added: %s", ref), vim.log.levels.INFO)
  end
end

return M
