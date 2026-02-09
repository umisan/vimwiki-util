local core = require("vimwiki-util.core")
local config = require("vimwiki-util.config")
local api = require("vimwiki-util.api")

local year = string.format("%d", os.date("*t").year)
local vimwiki_path = vim.g.vimwiki_list[1]["path"]

local function archive_link()
  local line = api.get_current_line()
  local link_name, err = core.get_link_name(line)
  if err then
    api.notify_error(err)
    return
  end
  local file_path = api.expand(core.get_link_file_path(vimwiki_path, link_name))
  if not api.file_exists(file_path) then
    api.notify_error("file not found: " .. file_path)
  end
  local archive_path = api.expand(core.get_archive_path(vimwiki_path, config.archive_path, year, link_name))
  if api.file_exists(archive_path) then
    api.notify_error("file already exists: " .. archive_path)
  end
  local msg, err = core.wiki_archive(file_path, archive_path)
  if err ~= nil then
    api.notify_error(err)
    return
  end
  local current_line_number = api.get_current_line_number()
  api.modify_current_buffer(current_line_number - 1, current_line_number, {})
  api.notify_info(msg)
end

local function update_archive_index()
  local archive_root = api.expand(core.get_archive_root(vimwiki_path, config.archive_path))
  if api.is_directory(archive_root) == 0 then
    api.notify_error("directory not found: " .. archive_root)
  end
  local file_list_map = {}
  for child, type in api.list_directory(archive_root) do
    if type == "directory" then
      file_list_map[child] = file_list_map[child] or {}
      for grandchild, type in api.list_directory(archive_root .. child) do
        table.insert(file_list_map[child], {name = grandchild, type = type})
      end
    end
  end
  local wiki_list_map = core.filter_wiki_page(file_list_map, config.archive_path)
  local sorted_keys = core.get_sorted_keys(wiki_list_map)
  api.clear_current_buffer()
  for _, key in ipairs(sorted_keys) do
    api.append_to_current_buffer({"= " .. key .. " ="})
    api.append_to_current_buffer({""})
    api.append_to_current_buffer(wiki_list_map[key])
    api.append_to_current_buffer({""})
  end
end

local function setup(opt)
  vim.api.nvim_create_user_command("ArchiveLink", archive_link, {})
  vim.api.nvim_create_user_command("UpdateArchiveIndex", update_archive_index, {})
end

return {
  setup = setup,
}
