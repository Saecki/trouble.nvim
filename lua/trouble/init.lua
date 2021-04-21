local View = require("trouble.view")
local config = require("trouble.config")
local colors = require("trouble.colors")
local util = require("trouble.util")
local lsp = require("trouble.lsp")

colors.setup()

local Trouble = {}

local view

local function is_open() return view and view:is_valid() end

function Trouble.setup(options)
    config.setup(options)
    colors.setup()
end

function Trouble.close() if is_open() then view:close() end end

function Trouble.open(opts)
    if is_open() then
        view:focus()
    else
        view = View.create(opts)
    end
end

function Trouble.toggle()
    if is_open() then
        Trouble.close()
    else
        Trouble.open()
    end
end

function Trouble.refresh(opts)
    if is_open() then
        view:update(opts)
    elseif opts.auto and config.options.auto_open then
        local count = util.count(lsp.diagnostics())
        if count > 0 then Trouble.open(opts) end
    end
end

function Trouble.action(action)
    if not is_open() then return end
    if action == "jump" then view:jump() end
    if action == "open_folds" then Trouble.refresh({open_folds = true}) end
    if action == "close_folds" then Trouble.refresh({close_folds = true}) end

    if action == "toggle_preview" then
        config.options.auto_preview = not config.options.auto_preview
        if config.options.auto_preview then action = "auto_preview" end
    end

    if action == "preview" or
        (action == "auto_preview" and config.options.auto_preview) then
        view:preview()
    end
    if Trouble[action] then Trouble[action]() end
end

return Trouble
