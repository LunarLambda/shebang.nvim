# #! Shebang.nvim

This is a tiny neovim plugin that allows you to quickly manipulate shebang lines in your scripts.

It can pick the correct interpreter based on filetype and automatically runs filetype detection
and `chmod +x`.


## Installation

See [](#Configuration) for options.

### lazy.nvim

```lua
{
    'LunarLambda/shebang.nvim',
    opts = {}
}
```

### Manual

Install shebang.nvim into your `runtimepath`, then run the following in your `init.lua`:

```lua
reqiure('shebang').setup({})
```

## Configuration

```lua
{
    -- Mapping of vim filetypes to interpreter programs.
    -- A single value runs the program using the default interpreter (/usr/bin/env)
    -- Two values runs the program with the specified argument.
    -- `default` sets the default interpreter and program to use if no filetype is set.
    interpreters = {
        bash = 'bash',
        csh = 'csh',
        fish = 'fish',
        lua = 'lua',
        perl = 'perl',
        php = 'php',
        python = 'python3',
        python2 = 'python2',
        ruby = 'ruby',
        -- NOTE: use { '/bin/sh', '' } for plain sh
        sh = 'bash',
        tcsh = 'tcsh',
        zsh = 'zsh',
        default = { '/usr/bin/env', 'bash' }
    },

    -- List of filetypes for which to automatically insert a shebang line when opening new files.
    -- Set to true to enable it for all filetypes.
    -- Set to 'shell' to enable it for shell scripts only.
    auto_insert = {},

    -- Automatically run `chmod +x` when saving the file after inserting a shebang.
    auto_chmod = true,

    -- When auto_insert is used, mark the buffer as modified after inserting the shebang.
    -- By default, the buffer is not marked, allowing you to close it without saving if
    -- you didn't make any edits.
    new_modified = false,
}
```

## `:Shebang` Command

The `:Shebang` command can be used in the following forms:

- `:Shebang` - Use the current filetype, falling back to the default
- `:Shebang <arg>` - Use the default interpreter with `arg`
- `:Shebang <interpreter> <arg>` - Use `interpreter` with `arg`
- `:Shebang <interpreter> -` - Use `interpreter` without an argument
- `:Shebang!` - Remove shebang line from file
- `:Shebang! ...` - Like `:Shebang`, replaces the shebang line if one already exists

The command executes `filetype detect` afterwards.

If `auto_chmod` is set, `chmod +x` is executed after the file is written for the first time.

Quickly creating a new script can be done with `nvim <file> +Shebang`

### Examples

Form                     | Shebang
-------------------------|--------
`:Shebang` (python file) | `#!/usr/bin/env python3`
`:Shebang foo`           | `#!/usr/bin/env foo`
`:Shebang /bin/foo -a`   | `#!/bin/foo -a`
`:Shebang /bin/sh -`     | `#!/bin/sh`
