local module = {}

--- Defaults being applied to `applyKeymaps`
-- Can be modified to change defaults applied.
module.defaults = {
    mode = 'n',
    prefix = '',
    options = {
        silent = true,
    },
}

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

    vim.keymap.set(
        mergedPresets.mode,
        mergedPresets.prefix,
        second,
        mergedPresets.options
    )
end

return module
