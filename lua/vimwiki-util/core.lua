local LINK_PATTERN = "%[%[([^%]|]*)%]%]"

local function getLinkName(line)
  local link_name = string.match(line, LINK_PATTERN)
  if not link_name then
    return nil, "no vimwiki link"
  end
  return link_name, nil
end

local function get_link_file_path(vimwiki_path, link_name)
  return vimwiki_path .. "/" .. link_name .. ".wiki"
end

local function get_archive_root(vimwiki_path, archive_path)
  return vimwiki_path .. "/" .. archive_path .. "/"
end

local function get_archive_path(vimwiki_path, archive_path, year, link_name)
  return vimwiki_path .. "/" .. archive_path .. "/" .. year .. "/" .. link_name .. ".wiki"
end

--- wikiArchive try to archiving vimwiki link
--- @param homedir string user home directory
--- @param vimwiki_path string path to vimiwiki
--- @param archive_path string path to archiving vimwiki link
--- @param line string target line
--- @return string|nil archive path
--- @return string|nil err
local function wikiArchive(file_path, archive_path)
  local success = os.rename(file_path, archive_path)
  if success then
    return "archived: " .. archive_path, nil
  else
    return nil, "archive failed"
  end
end

local function isFileExists(file_name)
  return vim.fn.filereadable(file_name) == 1
end

--- filterWikiPage list vimwiki file
--- @param file_list_map table<string, table<string, string>[]>
--- @param archive_root string root path of archive
--- @return table<string, string[]> vimwiki file table
local function filterWikiPage(file_list_map, archive_root)
  local wiki_list = {}
  for sub_dir, file_list in pairs(file_list_map) do
    wiki_list[sub_dir] = wiki_list[sub_dir] or {}
    for name, type in pairs(file_list) do
      if type == "file" and string.match(name, "%.wiki$") then
        table.insert(wiki_list[sub_dir], "[[" .. archive_root .. "/" .. sub_dir .. "/" .. name .. "]]")
      end
    end
  end
  return wiki_list
end

local function getSortedKeys(input) 
  local keys = {}
  for key in pairs(input) do 
    table.insert(keys, key) 
  end
  table.sort(keys)
  return keys
end

return {
  getLinkName = getLinkName,
  get_link_file_path = get_link_file_path,
  get_archive_root = get_archive_root,
  get_archive_path = get_archive_path,
  wikiArchive = wikiArchive,
  filterWikiPage = filterWikiPage,
  getSortedKeys = getSortedKeys,
}
