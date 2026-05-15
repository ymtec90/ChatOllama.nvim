vim.api.nvim_create_user_command("ChatOllama", function()
  require("ChatOllama").openChat()
end, {})

vim.api.nvim_create_user_command("ChatOllamaActAs", function()
  require("ChatOllama").selectAwesomePrompt()
end, {})

vim.api.nvim_create_user_command("ChatOllamaEditWithInstructions", function()
  require("ChatOllama").edit_with_instructions()
end, {
  range = true,
})

vim.api.nvim_create_user_command("ChatOllamaRun", function(opts)
  require("ChatOllama").run_action(opts)
end, {
  nargs = "*",
  range = true,
  complete = function()
    local ActionFlow = require("ChatOllama.flows.actions")
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
  require("ChatOllama").complete_code(opts)
end, {})
