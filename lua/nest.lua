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

local function mergeOptions(left, right)
    if right == nil then
        return left or {}
    end

    local ret = vim.tbl_deep_extend('force', left, right) or {}

    if right.prefix ~= nil then
        ret.prefix = left.prefix .. right.prefix
    end

    return ret
end

--- Applies the given `keymapConfig`, creating nvim keymaps
function module.applyKeymaps(config, presets)
    local mergedPresets = mergeOptions(
        presets or module.defaults,
        config
    )

    local first = config[1]

    local appliedConfig = vim.deepcopy(config)

    -- on the top level, save the current defaults
    if presets == nil then
        appliedConfig = mergeOptions(module.defaults, config)
    end

    appliedConfig.cond = nil

    if appliedConfig.buffer == true or appliedConfig.buffer == 0 then
        appliedConfig.buffer = vim.api.nvim_get_current_buf()
    end

    if type(first) == 'table' then
        for index, subConf in ipairs(config) do
            appliedConfig[index] = module.applyKeymaps(subConf, mergedPresets)
        end

        return vim.tbl_isempty(appliedConfig)
            and nil
            or appliedConfig
    end

    local second = config[2]

    mergedPresets.prefix = mergedPresets.prefix .. first

    if type(second) == 'table' then
        local appSubConf = module.applyKeymaps(second, mergedPresets)

        if appSubConf == nil then
            return nil
        else
            appliedConfig[2] = appSubConf
            return appliedConfig
        end
    end

    if not evalCondition(mergedPresets.cond) then
      return nil
    end

    local nvimAPIOptions = {
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

    vim.keymap.set(
        mergedPresets.mode,
        mergedPresets.prefix,
        second,
        util.extract(nvimAPIOptions, mergedPresets)
    )

    return appliedConfig
end

--- Reverts the given `keymapConfig`, deleting nvim keymaps
function module.revertKeymaps(config, presets)
    local mergedPresets = mergeOptions(
        presets or { prefix = '' },
        config
    )

    local first = config[1]

    if type(first) == 'table' then
        for _, subConf in ipairs(config) do
            module.revertKeymaps(subConf, mergedPresets)
        end

        return
    end

    local second = config[2]

    mergedPresets.prefix = mergedPresets.prefix .. first

    if type(second) == 'table' then
        module.revertKeymaps(second, mergedPresets)

        return
    end

    local nvimAPIOptions = {
        'buffer',
    }

    vim.keymap.del(
        mergedPresets.mode,
        mergedPresets.prefix,
        util.extract(nvimAPIOptions, mergedPresets)
    )
end

return module

-- vi: sw=4
