local module = {}

local util = require('nest.util')

--- Defaults being applied to `applyKeymaps`
-- Can be modified to change defaults applied.
module.defaults = {
    cond = true,
    mode = 'n',
    prefix = '',
    silent = true,
}

local function evalCondition(cond)
    if type(cond) == 'boolean' then
        return cond
    elseif type(cond) == 'function' then
        return evalCondition(cond())
    else
        return false
    end
end

local function extractNvimOptions(options)
    local nvimOptions = {
        'buffer',
        'desc',
        'expr',
        'noremap',
        'nowait',
        'remap',
        'replace_keycodes',
        'script',
        'silent',
        'unique'
    }
    return util.extract(nvimOptions, options)
end

local function mergeOptions(left, right)
    if right == nil then
        return left or {}
    end

    local ret = vim.tbl_deep_extend("force", left, right) or {}

    if right.prefix ~= nil then
        ret.prefix = left.prefix .. right.prefix
    end

    return ret
end

--- Applies the given `keymapConfig`, creating nvim keymaps
module.applyKeymaps = function (config, presets)
    local mergedPresets = mergeOptions(
        presets or module.defaults,
        config
    )

    local first = config[1]

    if type(first) == 'table' then
        for _, it in ipairs(config) do
            module.applyKeymaps(it, mergedPresets)
        end

        return
    end

    local second = config[2]

    mergedPresets.prefix = mergedPresets.prefix .. first

    if type(second) == 'table' then
        module.applyKeymaps(second, mergedPresets)

        return
    end

    if not evalCondition(mergedPresets.cond) then
      return
    end

    vim.keymap.set(
        mergedPresets.mode,
        mergedPresets.prefix,
        second,
        extractNvimOptions(mergedPresets)
    )
end

return module
