# VimAicli

A Vim plugin for AI-assisted text generation and translation using the aicli command-line tool.

## Features

- Generate AI-powered text directly within Vim
- Translate text to different languages
- Manage context and history for AI interactions
- Integrate files and custom context into AI prompts

## Installation

1. Ensure you have [aicli](https://github.com/LordPax/aicli) installed and accessible in your PATH.
2. Install the plugin using your preferred Vim plugin manager.

For example, using [vim-plug](https://github.com/junegunn/vim-plug):

```viml
Plug 'LordPax/vim-aicli'
```

## Configuration

Add these lines to your `.vimrc`, only if you want a different config for vim :

```viml
let g:aicliprg = "aicli"
let g:ai_text_history = "default"
let g:ai_text_sdk = "your_sdk"
let g:ai_text_model = "your_model"
let g:ai_text_temp = "0.7"
```

## Usage

### General

- `:AiSdk [sdk]` - Set or display the SDK

### Text Generation

- `:AiText [instruction]` - Generate text based on the instruction
- `:[range]AiText [instruction]` - Use selected text as context for generation
- `:AiText!` - Insert generated text after selection instead of replacing it

### Context Management and History for Text Generation

- `:AiAddFile <file1> [file2] ...` - Add files to context
- `:AiAddContext [context]` - Add custom context
- `:[range]AiAddContext` - Use selected text as context
- `:AiHistoryClear` - Clear context history
- `:AiHistoryList` - List available history names
- `:AiHistory [name]` - Set or display history name

### Translation

- `:[range]AiTranslate <target> [source]` - Translate text

## Examples

```
:AiText Explain quantum computing
:'<,'>AiText Summarize this text
:AiTranslate fr
:'<,'>AiTranslate es en
:AiAddFile README.md
:AiAddContext We are working on a machine learning project
:AiHistory my_project
```
