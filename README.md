# ChatOllama.nvim

![Lua](https://img.shields.io/badge/Made%20with%20Lua-blueviolet.svg?style=for-the-badge&logo=lua)

`ChatOllama` é um plugin para Neovim que permite utilizar a API do Ollama de forma integrada, permitindo gerar respostas em linguagem natural e código a partir de LLMs locais diretamente no seu editor.

Ao utilizar o Ollama, este fork garante **privacidade total**, **custo zero de API** e **funcionalidade offline**. Seu código e prompts nunca saem da sua máquina!

## Funcionalidades

- **Q&A Interativo**: Sessões de perguntas e respostas com modelos locais poderosos através de uma interface intuitiva.
- **Conversas baseadas em Personas**: Explore diferentes perspectivas conversando com personas específicas através de bibliotecas de prompts da comunidade.
- **Assistência na Edição de Código**: Janela de edição interativa alimentada pelo seu LLM local, oferecendo instruções específicas para tarefas de programação.
- **Completar Código**: Sugestões de código geradas localmente baseadas no contexto e padrões de programação.
- **Ações Customizáveis**: Execute ações como correção gramatical, tradução, geração de docstrings, adição de testes, otimização, correção de bugs e explicação de código. Você pode definir suas próprias ações via JSON.
- **Renderização Rica de Mensagens**: Blocos de código estilizados, markdown (negrito, itálico, listas), destaque de diff e indicadores de remetente.
- **Referências de Contexto Inline**: Use `@` para adicionar contexto de definições LSP ou arquivos do projeto diretamente nos seus prompts.

## Instalação

- Certifique-se de ter o `curl` instalado.
- Certifique-se de ter o [Ollama](https://ollama.com/) instalado e rodando localmente.

### Usando [lazy.nvim](https://github.com/folke/lazy.nvim):

```lua
-- Lazy
{
  "ymtec90/ChatOllama.nvim",
    event = "VeryLazy",
    config = function()
      require("chatollama").setup()
    end,
    dependencies = {
      "MunifTanjim/nui.nvim",
      "nvim-lua/plenary.nvim",
      "folke/trouble.nvim", -- opcional
      "nvim-telescope/telescope.nvim"
    }
}
```

## Configuração
O `ChatOllama.nvim` já vem configurado para execução local. Você pode customizar o modelo padrão (ex: qwen2.5-coder:7b) no seu setup:

```lua
require("chatollama").setup({
  openai_params = {
    model = "qwen2.5-coder:7b",
    max_tokens = 4095,
    temperature = 0.2,
    top_p = 0.1,
  }
})
```

## Uso
Os comandos mantêm o prefixo original para compatibilidade:

### `ChatOllama`
Abre a janela de chat interativo com o modelo configurado.

### `ChatOllamaEditWithInstructions`
Abre a janela interativa para editar o texto selecionado ou o arquivo inteiro usando o LLM local.

### `ChatOllamaRun [ação]`
Executa ações específicas. Exemplos:

`ChatOllamaRun add_tests`: Adiciona testes unitários ao código selecionado.

`ChatOllamaRun explain_code`: Explica o funcionamento do código.

`ChatOllamaRun fix_bugs`: Tenta encontrar e corrigir erros no trecho selecionado.

## Atalhos na Janela Interativa
`<C-Enter> / <Enter>`: Enviar prompt

`q`: Fechar janela

`<C-c>`: Interromper geração

`]c / [c`: Navegar entre blocos de código

`y`: Copiar bloco de código sob o cursor

## Mapeamentos Sugeridos (WhichKey)
```lua
local ChatOllama = require("chatollama")
wk.register({
    c = {
        name = "ChatOllama",
        c = { "<cmd>ChatOllama<CR>", "Chat" },
        e = { "<cmd>ChatOllamaEditWithInstruction<CR>", "Editar com Instrução", mode = { "n", "v" } },
        a = { "<cmd>ChatOllamaRun add_tests<CR>", "Adicionar Testes", mode = { "n", "v" } },
        f = { "<cmd>ChatOllamaRun fix_bugs<CR>", "Corrigir Bugs", mode = { "n", "v" } },
        x = { "<cmd>ChatOllamaRun explain_code<CR>", "Explicar Código", mode = { "n", "v" } },
    },
}, { prefix = "<leader>" })
```
## 💖 Créditos e Agradecimentos

Este projeto é um fork direto do incrível [ChatGPT.nvim](https://github.com/jackMort/ChatGPT.nvim), criado por [jackMort](https://github.com/jackMort). 

Toda a fundação da interface de usuário (UI), renderização de markdown, mapeamentos de teclas e a arquitetura central do plugin são méritos do projeto original. O **ChatGPT.nvim** nasceu com o propósito de adaptar essa excelente base para um ecossistema 100% local, focado em privacidade e custo zero, utilizando o [Ollama](https://ollama.com/).

Se você gosta da experiência de uso deste plugin, por favor, considere dar uma estrela (⭐) no [repositório original](https://github.com/jackMort/ChatGPT.nvim) e apoiar o criador!
