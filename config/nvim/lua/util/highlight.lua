-- ref. https://ryota2357.com/blog/2023/nvim-custom-statusline-tabline/

local M = {}
local fn = vim.fn

---@param hls table
---@return nil
function M.set(hls)
    for group, value in pairs(hls) do
        vim.api.nvim_set_hl(0, group, value)
    end
end

---@param links table
---@return nil
function M.link(links)
    for from, to in pairs(links) do
        vim.api.nvim_set_hl(0, from, {
            link = to,
        })
    end
end

return M
