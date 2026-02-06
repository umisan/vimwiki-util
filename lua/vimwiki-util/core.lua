local LINK_PATTERN = "%[%[([^%]|]*)%]%]"

local function getLinkName(line)
  local link_name = string.match(line, LINK_PATTERN)
  if not link_name then
    return nil, "no vimwiki link"
  end
  return link_name, nil
end

local function expandPath(path, homedir)
  if path:sub(1,1) ~= "~" then
    return path, nil
  end
  if homedir == nil or homedir == "" then
    return nil, "homedir should not be nil or empty"
  end
  if path == "~" then
    return homedir, nil
  end
  if path:sub(1, 2) ~= "~/" then
    return homedir .. path:sub(2), nil
  end
  return "", "unexpected path format"
end

local function fileExists(path)
  local f = io.open(path, "r")
  if f then
    f:close()
    return true
  end
  return false
end

--- wikiArchive try to archiving vimwiki link
--- @param homedir string user home directory
--- @param vimwiki_path string path to vimiwiki
--- @param archive_path string path to archiving vimwiki link
--- @param line string target line
--- @return string|nil archive path
--- @return string|nil err
local function wikiArchive(homedir, vimwiki_path, archive_path, line)
  local link_name, err = getLinkName(line)
  if err then
    return nil, err
  end
  local file_path = vimwiki_path .. "/" .. link_name .. ".wiki"
  local expanded_file_path = expandPath(file_path, homedir)
  if not fileExists(expanded_file_path) then
    return nil, "file not found: " .. expanded_file_path
  end
  local expanded_archive_path = expandPath(vimwiki_path .. "/" .. archive_path .. "/" .. link_name .. ".wiki")
  if fileExists(expanded_archive_path) then
    return nil, "file already exists: " .. expanded_archive_path
  end
  local success = os.rename(expanded_file_path, expanded_archive_path)
  if success then
    return "archived: " .. expanded_archive_path, nil
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
    for name, type in file_list do
      if type == "file" and string.match(name, "%.wiki$") then
        table.insert(wiki_list[sub_dir], "[[" .. archive_root .. "/" .. sub_dir .. "/" .. name .. "]]")
    end
  end
  return wiki_list
end

local function getSortedKeys(input) 
  local keys = {}
  for key in pairs(wiki_list_map) do 
    table.insert(keys, key) 
  end
  table.sort(keys)
  return keys
end

return {
  wikiArchive = wikiArchive,
  filterWikiPage = filterWikiPage,
  getSortedKeys = getSortedKeys,
}
