# #! Shebang.nvim

This is a tiny neovim plugin that allows you to quickly manipulate shebang lines in your scripts.

It can pick the correct interpreter based on filetype and automatically runs filetype detection
and `chmod +x`.


## Installation

### lazy.nvim

```lua
{
    'LunarLambda/shebang.nvim',
    opts = {}
}
```

## Configuration

```lua
{
    -- Mapping of vim filetypes to interpreter programs.
    -- A single value runs the program using the default interpreter (/usr/bin/env)
    -- Two values runs the program with the specified argument
    -- `default` sets the default interpreter and program to use.
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
        sh = 'bash',
        tcsh = 'tcsh',
        zsh = 'zsh',
        default = { '/usr/bin/env', 'bash' }
    },

    -- List of filetypes for which to automatically insert a shebang line.
    -- Set to true to enable it for all known filetypes.
    auto_insert = false,

    -- automatically run `chmod +x` when you save a new file.
    auto_chmod = true,

    -- set 'modified' when auto_insert is used
    new_modified = false,
}
```
