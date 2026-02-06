local M = {}

function M.setup(opts)
  opts = opts or {}
  require("vimwiki-util.commands").setup(opts)
end

return M

