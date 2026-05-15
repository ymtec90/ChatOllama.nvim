-- module represents a lua module for the plugin
local M = {}

local Chat = require("ChatOllama.flows.chat")
local Edits = require("ChatOllama.code_edits")
local Actions = require("ChatOllama.flows.actions")
local CodeCompletions = require("ChatOllama.flows.code_completions")

M.open_chat = Chat.open
M.open_chat_with_awesome_prompt = Chat.open_with_awesome_prompt
M.open_chat_with = Chat.open_with
M.edit_with_instructions = Edits.edit_with_instructions
M.run_action = Actions.run_action
M.complete_code = CodeCompletions.complete

return M
