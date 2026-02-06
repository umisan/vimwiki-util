local core = require("vimwiki-util.core")
local config = require("vimwiki-util.config")
local api = require("vimwiki-util.api")

local year = string.format("%d", os.date("*t").year)
local homedir = os.getenv("HOME")
local vimwiki_path = vim.g.vimwiki_list[1]["path"]

local function archiveLink()
  local msg, err = core.wikiArchive(homedir, vimwiki_path, config.archive_path, api.getCurrentLine())
  if err ~= nil then
    api.notifyError(err)
    return
  end
  local currentLineNumber = api.getCurrentLineNumber()
  api.modifyCurrentBuffer(currentLineNumber - 1, currentLineNumber, {})
  api.notifyInfo(msg)
end

local function updateArchiveIndex() 
  local archive_root = api.expand(vimwiki_path, config.archive_path)
  if api.isDirectory(archive_root) == 0 then
    api.notifyError("directory not found: " .. archive_root)
  end
  local file_list_map = {}
  for child, type in api.listDirectory(archive_root) do
    if type == "direcory" then
      file_list_map[child] = file_list_map[child] or {}
      table.insert(file_list_map[child], api.listDirectory(archive_root .. child))
    end
  end
  local wiki_list_map = core.filterWikiPage(file_list_map, archive_root)
  local sorted_keys = core.getSortedKeys(wiki_list_map)
  api.clearCurrentBuffer()
  for i, key in ipairs(sorted_keys) do
    api.appendToCurrentBuffer({"= " .. key .. " ="})
    api.appendToCurrentBuffer({""})
    api.appendToCurrentBuffer(wiki_list_map[key])
    api.appendToCurrentBuffer({""})
  end
end

local function setup(opt)
  vim.api.nvim_create_user_command("ArchiveLink", archiveLink, {})
  vim.api.nvim_create_user_command("UpdateArchiveIndex", updateArchiveIndex, {})
end

return {
  setup = setup,
}
