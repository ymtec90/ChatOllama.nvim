vim.api.nvim_create_user_command("ChatOllama", function()
  require("chatollama").openChat()
end, {})

vim.api.nvim_create_user_command("ChatOllamaActAs", function()
  require("chatollama").selectAwesomePrompt()
end, {})

vim.api.nvim_create_user_command("ChatOllamaEditWithInstructions", function()
  require("chatollama").edit_with_instructions()
end, {
  range = true,
})

vim.api.nvim_create_user_command("ChatOllamaRun", function(opts)
  require("chatollama").run_action(opts)
end, {
  nargs = "*",
  range = true,
  complete = function()
    local ActionFlow = require("chatollama.flows.actions")
    local action_definitions = ActionFlow.read_actions()

    local actions = {}
    for key, _ in pairs(action_definitions) do
      table.insert(actions, key)
    end
    table.sort(actions)

    return actions
  end,
})

vim.api.nvim_create_user_command("ChatOllamaCompleteCode", function(opts)
  require("chatollama").complete_code(opts)
end, {})
