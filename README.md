ChatOllama.nvim
ChatOllama is a Neovim plugin that allows you to effortlessly utilize the Ollama API, empowering you to generate natural language responses and code from local LLMs directly within your editor.

By leveraging Ollama, this fork ensures complete privacy, zero API costs, and offline capabilities. Your code and prompts never leave your machine!

(Note: To maintain compatibility with the original codebase, the core commands and Lua modules retain the chatgpt nomenclature, but everything under the hood is routed to your local Ollama instance).

Features
Interactive Q&A: Engage in interactive question-and-answer sessions with powerful local models using an intuitive interface.

Persona-based Conversations: Explore various perspectives and have conversations with different personas by selecting prompts from community-driven prompt libraries.

Code Editing Assistance: Enhance your coding experience with an interactive editing window powered by your local LLM, offering instructions tailored for coding tasks.

Code Completion: Enjoy the convenience of local, AI-driven code completion. Let your local models suggest snippets and completions based on context and programming patterns.

Customizable Actions: Execute a range of actions utilizing Ollama, such as grammar correction, translation, keyword generation, docstring creation, test addition, code optimization, summarization, bug fixing, code explanation, and code readability analysis. You can also define your own custom actions using a JSON file.

Rich Message Rendering: Enhanced chat display with styled code blocks (language headers, copy indicators, foldable), markdown formatting (headers, bold, italic, lists, blockquotes, links), diff highlighting, and sender indicators.

Inline Context References: Use @ to add context from LSP definitions or project files directly in your prompts. References are displayed inline and expanded when sending to the API.

Installation
Make sure you have curl installed on your system.

Make sure you have Ollama installed and running locally.

If you are using packer.nvim as your plugin manager:

Lua
-- Packer
use({
  "ymtec90/ChatOllama.nvim",
    config = function()
      require("chatgpt").setup()
    end,
    requires = {
      "MunifTanjim/nui.nvim",
      "nvim-lua/plenary.nvim",
      "folke/trouble.nvim",
      "nvim-telescope/telescope.nvim"
    }
})
or if you are using lazy.nvim:

Lua
-- Lazy
{
  "ymtec90/ChatOllama.nvim",
    event = "VeryLazy",
    config = function()
      require("chatgpt").setup()
    end,
    dependencies = {
      "MunifTanjim/nui.nvim",
      "nvim-lua/plenary.nvim",
      "folke/trouble.nvim", -- optional
      "nvim-telescope/telescope.nvim"
    }
}
Configuration
ChatOllama.nvim comes with default settings tailored for local execution. You can override them by passing a configuration table to the setup function.

Check the default configurations here:
https://github.com/ymtec90/ChatOllama.nvim/blob/main/lua/chatgpt/config.lua

Example Configuration
A simple configuration pointing to your preferred local coding model could look something like this:

Lua
{
  "ymtec90/ChatOllama.nvim",
  event = "VeryLazy",
  config = function()
    require("chatgpt").setup({
      -- Ollama specific parameters
      openai_params = {
        -- NOTE: model can be a function returning the model name
        -- Example:
        -- model = function()
        --     if some_condition() then
        --         return "llama3"
        --     else
        --         return "qwen2.5-coder:7b"
        --     end
        -- end,
        model = "qwen2.5-coder:7b",
        frequency_penalty = 0,
        presence_penalty = 0,
        max_tokens = 4095,
        temperature = 0.2,
        top_p = 0.1,
        n = 1,
      }
    })
  end,
  dependencies = {
    "MunifTanjim/nui.nvim",
    "nvim-lua/plenary.nvim",
    "folke/trouble.nvim", -- optional
    "nvim-telescope/telescope.nvim"
  }
}
Usage
The plugin exposes the following commands. (Note: The commands retain their original ChatGPT prefix to ensure backward compatibility and avoid breaking existing workflows or WhichKey configurations).

ChatGPT
ChatGPT command opens an interactive chat window using your configured local model (e.g., qwen2.5-coder:7b).

ChatGPTActAs
ChatGPTActAs command opens a prompt selection menu to define the system persona before starting a chat with your local model.

ChatGPTEditWithInstructions
ChatGPTEditWithInstructions command opens an interactive window to edit the selected text or the whole buffer using your local model.

You can map it using the Lua API, e.g., using which-key.nvim:

Lua
local chatgpt = require("chatgpt")
wk.register({
    p = {
        name = "ChatOllama",
        e = {
            function()
                chatgpt.edit_with_instructions()
            end,
            "Edit with instructions",
        },
    },
}, {
    prefix = "<leader>",
    mode = "v",
})
ChatGPTRun
ChatGPTRun [action] command runs specific actions -- See actions.json file for a detailed list. Available actions are:

grammar_correction

translate

keywords

docstring

add_tests

optimize_code

summarize

fix_bugs

explain_code

roxygen_edit

code_readability_analysis

fix_diagnostic -- fix error under cursor

explain_diagnostic -- explain error under cursor

fix_diagnostics -- fix all errors in selection

All the above actions will process completely locally via Ollama.

It is possible to define custom actions with a JSON file. See actions.json for an example. The path of custom actions can be set in the config (see actions_paths field).

An example of a custom action targeting Ollama may look like this:

Python
{
  "action_name": {
    "type": "chat", # or "completion" or "edit"
    "opts": {
      "template": "A template using possible variables",
      "strategy": "replace", # or "display" or "append" or "edit"
      "params": { 
        "model": "qwen2.5-coder:7b", # Any model you have pulled in Ollama
        "stop": [
          "```" # a string used to stop the model
        ]
      }
    },
    "args": {
      "argument": {
          "type": "string",
          "optional": "true",
          "default": "some value"
      }
    }
  }
}
Available template variables:

{{input}} - the selected text

{{filetype}} - neovim filetype

{{filepath}} - relative path to the file

{{argument}} - provided on the command line

{{diagnostic}} - LSP diagnostic under cursor (format: [SEVERITY] message (line N))

{{diagnostics}} - all LSP diagnostics in selection (format: Line N [SEVERITY]: message)

Interactive popup
When using ChatGPT and ChatGPTEditWithInstructions, the following keybindings are available:

Submitting and Closing:

<C-Enter> / <Enter> Submit prompt

q Close chat window

<C-c> Stop generating response

Navigation:

]m / [m Navigate to next/previous message

]c / [c Navigate to next/previous code block

<C-u> / <C-d> Scroll chat window up/down

<Tab> Cycle between windows

Toggles (g prefix):

gs Toggle settings panel (read-only)

gh Toggle help panel

gp Toggle sessions panel

gr Toggle system role window

gm Toggle message role (user/assistant)

gl Cycle layout modes (center/right)

gn Start new session

gd Draft message (add without sending)

Actions:

y Copy code block at cursor

Y Copy entire last answer

d Delete selected message

e Edit selected message

r Rename session (in sessions panel)

za Toggle fold for code block

@ Trigger context autocomplete (LSP, project, file, git diff)

Edit Window specific:

<C-y> Accept changes

<C-d> Toggle diff view

<C-i> Use response as input

Whichkey plugin mappings
Add these to your whichkey plugin mappings for convenient binds:

Lua
c = {
  name = "ChatOllama",
    c = { "<cmd>ChatGPT<CR>", "ChatOllama" },
    e = { "<cmd>ChatGPTEditWithInstruction<CR>", "Edit with instruction", mode = { "n", "v" } },
    g = { "<cmd>ChatGPTRun grammar_correction<CR>", "Grammar Correction", mode = { "n", "v" } },
    t = { "<cmd>ChatGPTRun translate<CR>", "Translate", mode = { "n", "v" } },
    k = { "<cmd>ChatGPTRun keywords<CR>", "Keywords", mode = { "n", "v" } },
    d = { "<cmd>ChatGPTRun docstring<CR>", "Docstring", mode = { "n", "v" } },
    a = { "<cmd>ChatGPTRun add_tests<CR>", "Add Tests", mode = { "n", "v" } },
    o = { "<cmd>ChatGPTRun optimize_code<CR>", "Optimize Code", mode = { "n", "v" } },
    s = { "<cmd>ChatGPTRun summarize<CR>", "Summarize", mode = { "n", "v" } },
    f = { "<cmd>ChatGPTRun fix_bugs<CR>", "Fix Bugs", mode = { "n", "v" } },
    x = { "<cmd>ChatGPTRun explain_code<CR>", "Explain Code", mode = { "n", "v" } },
    r = { "<cmd>ChatGPTRun roxygen_edit<CR>", "Roxygen Edit", mode = { "n", "v" } },
    l = { "<cmd>ChatGPTRun code_readability_analysis<CR>", "Code Readability Analysis", mode = { "n", "v" } },
  },
