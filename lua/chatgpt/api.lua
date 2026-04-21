local job = require("plenary.job")
local Config = require("chatgpt.config")
local logger = require("chatgpt.common.logger")
local Utils = require("chatgpt.utils")

local Api = {}

function Api.completions(custom_params, cb)
  local openai_params = Utils.collapsed_openai_params(Config.options.openai_params)
  local params = vim.tbl_extend("keep", custom_params, openai_params)
  
  -- Forçar o uso do modelo local do Ollama
  params.model = "qwen2.5-coder:7b"
  
  Api.make_call(Api.COMPLETIONS_URL, params, cb)
end

function Api.chat_completions(custom_params, cb, should_stop)
  local openai_params = Utils.collapsed_openai_params(Config.options.openai_params)
  local params = vim.tbl_extend("keep", custom_params, openai_params)
  
  -- Forçar o uso do modelo local do Ollama
  params.model = "qwen2.5-coder:7b"
  
  local stream = params.stream or false
  if stream then
    local raw_chunks = ""
    local state = "START"

    cb = vim.schedule_wrap(cb)

    local extra_curl_params = Config.options.extra_curl_params
    local args = {
      "--silent",
      "--show-error",
      "--no-buffer",
      Api.CHAT_COMPLETIONS_URL,
      "-H",
      "Content-Type: application/json",
      "-H",
      Api.AUTHORIZATION_HEADER,
      "-d",
      vim.json.encode(params),
    }

    if extra_curl_params ~= nil then
      for _, param in ipairs(extra_curl_params) do
        table.insert(args, param)
      end
    end

    Api.exec(
      "curl",
      args,
      function(chunk)
        local ok, json = pcall(vim.json.decode, chunk)
        if ok and json ~= nil then
          if json.error ~= nil then
            cb(json.error.message, "ERROR")
            return
          end
        end
        for line in chunk:gmatch("[^\n]+") do
          local raw_json = string.gsub(line, "^data: ", "")
          if raw_json == "[DONE]" then
            cb(raw_chunks, "END")
          else
            ok, json = pcall(vim.json.decode, raw_json, {
              luanil = {
                object = true,
                array = true,
              },
            })
            if ok and json ~= nil then
              if
                json
                and json.choices
                and json.choices[1]
                and json.choices[1].delta
                and json.choices[1].delta.content
              then
                cb(json.choices[1].delta.content, state)
                raw_chunks = raw_chunks .. json.choices[1].delta.content
                state = "CONTINUE"
              end
            end
          end
        end
      end,
      function(err, _)
        cb(err, "ERROR")
      end,
      should_stop,
      function()
        cb(raw_chunks, "END")
      end
    )
  else
    Api.make_call(Api.CHAT_COMPLETIONS_URL, params, cb)
  end
end

local EDIT_SYSTEM_PROMPT = [[You are a code editing assistant. Apply the requested changes to the provided code.

Rules:
- Output ONLY the modified code, nothing else
- Do NOT wrap the code in markdown code blocks or backticks
- Preserve the original indentation and code style
- Only change what is necessary to fulfill the request
- Keep all unrelated code exactly as it was]]

function Api.edits(custom_params, cb)
  local messages = {
    { role = "system", content = EDIT_SYSTEM_PROMPT },
    { role = "user", content = custom_params.input or "" },
    { role = "user", content = custom_params.instruction or "Apply the requested changes" },
  }

  local params = {
    -- Forçar o uso do modelo local do Ollama
    model = "qwen2.5-coder:7b",
    messages = messages,
    temperature = custom_params.temperature,
    top_p = custom_params.top_p,
  }

  Api.chat_completions(params, cb)
end

function Api.make_call(url, params, cb)
  local tmp_msg_filename = os.tmpname()
  local f = io.open(tmp_msg_filename, "w+")
  if f == nil then
    vim.notify("Cannot open temporary message file: " .. tmp_msg_filename, vim.log.levels.ERROR)
    return
  end
  f:write(vim.fn.json_encode(params))
  f:close()

  local args = {
    url,
    "-H",
    "Content-Type: application/json",
    "-H",
    Api.AUTHORIZATION_HEADER,
    "-d",
    "@" .. tmp_msg_filename,
  }

  local extra_curl_params = Config.options.extra_curl_params
  if extra_curl_params ~= nil then
    for _, param in ipairs(extra_curl_params) do
      table.insert(args, param)
    end
  end

  Api.job = job
    :new({
      command = "curl",
      args = args,
      on_exit = vim.schedule_wrap(function(response, exit_code)
        Api.handle_response(response, exit_code, cb, tmp_msg_filename)
      end),
    })
    :start()
end

Api.handle_response = vim.schedule_wrap(function(response, exit_code, cb, tmp_msg_filename)
  os.remove(tmp_msg_filename)
  if exit_code ~= 0 then
    vim.notify("An Error Occurred ...", vim.log.levels.ERROR)
    cb("ERROR: API Error")
  end

  local result = table.concat(response:result(), "\n")
  local json = vim.fn.json_decode(result)
  if json == nil then
    cb("No Response.")
  elseif json.error then
    cb("// API ERROR: " .. json.error.message)
  else
    local message = json.choices[1].message
    if message ~= nil then
      local message_response
      local first_message = json.choices[1].message
      if first_message.function_call then
        message_response = vim.fn.json_decode(first_message.function_call.arguments)
      else
        message_response = first_message.content
      end
      if (type(message_response) == "string" and message_response ~= "") or type(message_response) == "table" then
        cb(message_response, json.usage)
      else
        cb("...")
      end
    else
      local response_text = json.choices[1].text
      if type(response_text) == "string" and response_text ~= "" then
        cb(response_text, json.usage)
      else
        cb("...")
      end
    end
  end
end)

function Api.close()
  if Api.job then
    job:shutdown()
  end
end

local splitCommandIntoTable = function(command)
  local cmd = {}
  for word in command:gmatch("%S+") do
    table.insert(cmd, word)
  end
  return cmd
end

-- Funções utilitárias mantidas para não quebrar dependências do plugin,
-- embora não sejam mais estritamente necessárias para a inicialização do Ollama.
local function loadConfigFromCommand(command, optionName, callback, defaultValue)
  local cmd = splitCommandIntoTable(command)
  job
    :new({
      command = cmd[1],
      args = vim.list_slice(cmd, 2, #cmd),
      on_exit = function(j, exit_code)
        if exit_code ~= 0 then
          logger.warn("Config '" .. optionName .. "' did not return a value when executed")
          return
        end
        local value = j:result()[1]:gsub("%s+$", "")
        if value ~= nil and value ~= "" then
          callback(value)
        elseif defaultValue ~= nil and defaultValue ~= "" then
          callback(defaultValue)
        end
      end,
    })
    :start()
end

local function startsWith(str, start)
  return string.sub(str, 1, string.len(start)) == start
end

local function ensureUrlProtocol(str)
  if startsWith(str, "https://") or startsWith(str, "http://") then
    return str
  end

  -- Modificado para HTTP por padrão para conexões locais com Ollama
  return "http://" .. str 
end

function Api.setup()
  -- Configuração direta para o Ollama local
  Api.OPENAI_API_HOST = "localhost:11434"
  Api.COMPLETIONS_URL = ensureUrlProtocol(Api.OPENAI_API_HOST .. "/v1/completions")
  Api.CHAT_COMPLETIONS_URL = ensureUrlProtocol(Api.OPENAI_API_HOST .. "/v1/chat/completions")
  
  -- Ollama não precisa de chave de API, mas definimos um dummy para evitar que 
  -- o curl falhe ou falte a variável no resto do código.
  Api.OPENAI_API_KEY = "ollama-dummy-key"
  Api.AUTHORIZATION_HEADER = "Authorization: Bearer " .. Api.OPENAI_API_KEY
end

function Api.exec(cmd, args, on_stdout_chunk, on_complete, should_stop, on_stop)
  local stdout = vim.loop.new_pipe()
  local stderr = vim.loop.new_pipe()
  local stderr_chunks = {}

  local handle, err
  local function on_stdout_read(_, chunk)
    if chunk then
      vim.schedule(function()
        if should_stop and should_stop() then
          if handle ~= nil then
            handle:kill(2) -- send SIGINT
            stdout:close()
            stderr:close()
            handle:close()
            on_stop()
          end
          return
        end
        on_stdout_chunk(chunk)
      end)
    end
  end

  local function on_stderr_read(_, chunk)
    if chunk then
      table.insert(stderr_chunks, chunk)
    end
  end

  handle, err = vim.loop.spawn(cmd, {
    args = args,
    stdio = { nil, stdout, stderr },
  }, function(code)
    stdout:close()
    stderr:close()
    if handle ~= nil then
      handle:close()
    end

    vim.schedule(function()
      if code ~= 0 then
        on_complete(vim.trim(table.concat(stderr_chunks, "")))
      end
    end)
  end)

  if not handle then
    on_complete(cmd .. " could not be started: " .. err)
  else
    stdout:read_start(on_stdout_read)
    stderr:read_start(on_stderr_read)
  end
end

return Api
