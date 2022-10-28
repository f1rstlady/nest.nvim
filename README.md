# nest.nvim

Neovim utility plugin to define keymaps in concise, readable, cascading lists
and trees

- Modular, maintainable pure Lua way to define keymaps
- Written in a single file of ~100 lines
- Allows grouping keymaps the way you think about them concisely

## Installation

### Using [packer.nvim](https://github.com/wbthomason/packer.nvim)

```lua
use { 'LionC/nest.nvim' }
```

### Using [vim-plug](https://github.com/junegunn/vim-plug)

```viml
Plug 'LionC/nest.nvim'
```

### Using [dein](https://github.com/Shougo/dein.vim)

```viml
call dein#add('LionC/nest.nvim')
```

## Quickstart Guide

The `nest` Lua module exposes an `applyKeymaps` function that can be called any
number of times with a list of (nested) keymaps to be set.

Keymaps will default to global, normal (`n`) mode, `noremap` and `silent`
unless overwritten.  Overrides are inherited by nested keymaps.

```lua
local nest = require('nest')

nest.applyKeymaps {
    -- Remove silent from ; : mapping, so that : shows up in command mode
    { ';', ':' , silent = false },
    { ':', ';' },

    -- Prefix  every nested keymap with <leader>
    { '<leader>', {
        -- Prefix every nested keymap with f (meaning actually <leader>f here)
        { 'f', {
            { 'f', '<cmd>Telescope find_files<cr>' },
            -- This will actually map <leader>fl
            { 'l', '<cmd>Telescope live_grep<cr>' },
            -- Prefix every nested keymap with g (meaning actually <leader>fg here)
            { 'g', {
                { 'b', '<cmd>Telescope git_branches<cr>' },
                -- This will actually map <leader>fgc
                { 'c', '<cmd>Telescope git_commits<cr>' },
                { 's', '<cmd>Telescope git_status<cr>' },
            }},
        }},

        -- Lua functions can be right side values instead of key sequences
        { 'l', {
            { 'c', vim.lsp.buf.code_actions },
            { 'r', vim.lsp.buf.rename },
            { 's', vim.lsp.buf.signature_help },
            { 'h', vim.lsp.buf.hover },
        }},
    }},

    -- Use insert mode for all nested keymaps
    { mode = 'i', {
        { 'jk', '<Esc>' },

        -- Set <expr> option for all nested keymaps
        { expr = true, {
            { '<cr>',       'compe#confirm("<CR>")' },
            -- This is equivalent to viml `:inoremap <C-Space> <expr>compe#complete()`
            { '<C-Space>',  'compe#complete()' },
        }},

        -- Buffer `true` sets keymaps only for the current buffer
        { '<C-', buffer = true, {
            { 'h>', '<left>' },
            { 'l>', '<right>' },
            -- You can also set bindings for a specific buffer
            { 'o>', '<Esc>o', buffer = 2 },
        }},
    }},

    -- Keymaps can be defined for multiple modes at once
    { 'H', '^', mode = {'n', v'} },
}
```

The passed `table` can be understood as a tree, with prefixes and config fields
cascading down to all children. This makes it not only very readable and groupable,
but also eases refactoring and modularization. Because `nest`-keymapConfigs are just
simple Lua values, they can be defined in their own files, passed around, plugged
into different prefixes or options etc.

## Advanced Usage

### Change defaults

You can change the defaults used by `applyKeymaps`:

```lua
local nest = require('nest')

nest.defaults.remap = true,
```

Defaults start out as

```lua
{
    mode = 'n',
    prefix = '',
    silent = true,
}
```

## Reference

### `nest.applyKeymaps`

Expects a `keymapConfig`, which is a table with at least two indexed properties
in one of the following four shapes:

#### Keymap

```lua
{ 'inputsequence', 'outputsequence' }
```

Sets a keymap, mapping the input sequence to the output sequence.  The output
sequence may be any value that `vim.keymap.set` accepts.

#### Config Subtree

```lua
{ 'inputprefix', keymapConfig }
```

Append the inputprefix to the current prefix and applies the given
`keymapConfig`s with the new prefix.

#### Config List

```lua
{
    keymapConfig,
    keymapConfig,
    keymapConfig
    -- ...
}
```

Applies all given `keymapConfig`s.

Each `keymapConfig` can also have any of the following fields, which will cascade
to all containing sub-`keymapConfig`s:

#### `mode`

Sets the Vim mode(s) for keymaps contained in the `keymapConfig`.

Accepts all values `vim.keymap.set`s `mode` parameter accepts. See `:help
vim.keymap.set`.

#### Options from `vim.keymap.set`s `options` parameter

All options accepted by `vim.keymap.set`s `options` parameter (e.g. `buffer` and
`silent`) may be set and will cascade down to all children. See `:help
vim.keymap.set`.

### `nest.defaults`

`table` containing the defaults applied to keymaps. Can be modified or overwritten.

Has the same named fields as `keymapConfig`, with an additional field:

#### `prefix`

Sets a `string` prefix to be applied to all keymap inputs.

## Planned Features

See issues and milestones
