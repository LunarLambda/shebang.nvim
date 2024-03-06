local M = {}

local AUGROUP = vim.api.nvim_create_augroup('Shebang', { clear = true })

local INTERPRETERS = {
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
}

local OPTIONS = {
    interpreters = INTERPRETERS,
    auto_insert = false,
    auto_chmod = true,
    new_modified = false,
}

local function has_shebang()
    return vim.fn.getline(1):match('^#!') ~= nil
end

local function register_chmod_autocmd()
    local autocmds = vim.api.nvim_get_autocmds({
        group = AUGROUP,
        buffer = vim.fn.bufnr(),
    })

    if #autocmds == 0 then
        vim.api.nvim_create_autocmd('BufWritePost', {
            group = AUGROUP,
            buffer = vim.fn.bufnr(),
            once = true,
            command = 'silent! !chmod +x -- %:p',
            desc = 'Set executable bit on write',
        })
    end
end

function M.get_shebang_line(args)
    local interp = {}

    args.interpreter = args.interpreter or {}

    interp[1] = args.interpreter[2] and args.interpreter[1] or M.config.interpreters.default[1]
    interp[2] = args.interpreter[2] or args.interpreter[1] or M.config.interpreters.default[2]

    if args.filetype then
        local ft_interp = M.config.interpreters[args.filetype]

        if type(ft_interp) == 'string' then
            interp[2] = ft_interp
        elseif type(ft_interp) == 'table' then
            interp[1] = ft_interp[2] and ft_interp[1] or interp[1]
            interp[2] = ft_interp[2] or ft_interp[1]
        elseif ft_interp ~= nil then
            error('invalid interpreter spec')
        end
    end

    if interp[2] ~= '' then
        return string.format('#!%s %s', interp[1], interp[2])
    else
        return string.format('#!%s', interp[1])
    end
end

function M.set_shebang_line(args)
    local has_shebang = has_shebang()

    if not args.force and has_shebang then
        return
    end

    local shebang = M.get_shebang_line(args)

    local replace_line = has_shebang and 1 or 0

    local modified = has_shebang and vim.fn.getline(1) ~= shebang

    vim.api.nvim_buf_set_lines(0, 0, replace_line, false, { shebang })

    if not args.nomodify and modified then
        vim.bo.modified = true
    end

    local is_file_buffer = vim.bo.buftype == '' and vim.api.nvim_buf_get_name(0) ~= ''

    if M.config.auto_chmod and is_file_buffer then
        register_chmod_autocmd()
    end

    if vim.fn.did_filetype() == 0 then
        vim.cmd('filetype detect')
    end
end

function M.remove_shebang_line()
    if has_shebang() then
        vim.api.nvim_buf_set_lines(0, 0, 1, false, {})
        vim.bo.modified = true
    end
end

local function shebang_cmd(args)
    assert(#args.fargs < 3, ':Shebang takes 0, 1, or 2 arguments')

    if args.bang and #args.fargs == 0 then
        M.remove_shebang_line()
    else
        if args.fargs[2] == '-' then
            args.fargs[2] = ''
        end

        M.set_shebang_line({
            force = args.bang,
            interpreter = args.fargs,
            filetype = #args.fargs == 0 and vim.bo.filetype or nil
        })
    end
end

function M.setup(opts)
    opts = vim.tbl_deep_extend('keep', opts or {}, OPTIONS)

    M.config = opts

    vim.api.nvim_create_user_command('Shebang', shebang_cmd, {
        bang = true,
        nargs = '*',
        desc = 'Add shebang to file',
    })

    if not M.config.auto_insert then
        return
    end

    local autocmds = vim.api.nvim_get_autocmds({
        group = AUGROUP,
        event = 'BufNewFile'
    })

    if #autocmds == 0 then
        vim.api.nvim_create_autocmd('BufNewFile', {
            group = AUGROUP,
            callback = function()
                local ft = vim.bo.filetype
                local auto = M.config.auto_insert

                if ft == '' then
                    return
                end

                if auto == true or vim.tbl_contains(auto, ft) then
                    M.set_shebang_line({ filetype = ft, nomodify = not M.config.new_modified })
                end
            end
        })
    end
end

return M
