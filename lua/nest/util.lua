local M = {}

M.extract = function (keys, table)
    local acc = {}
    for _, k in ipairs(keys) do
        acc[k] = table[k]
    end
    return acc
end

return M
