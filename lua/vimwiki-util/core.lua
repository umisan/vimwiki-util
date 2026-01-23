function WikiArchive()
  local line = vim.fn.getline(".")
  local link_pattern = "%[%[([^%]|]*)%]%]"
  local link_name = string.match(line, link_pattern)
  if not link_name then
    vim.notify("no vimwiki link", vim.log.levels.ERROR)
    return
  end

  local vimwiki_path = vim.g.vimwiki_list[1]["path"]
  local file_path = vimwiki_path .. "/" .. link_name .. ".wiki"
  local expanded_file_path = vim.fn.expand(file_path)

  if not IsFileExists(expanded_file_path) then
    vim.notify("file not found: " .. expanded_file_path, vim.log.levels.ERROR)
    return
  end

  local year = string.format("%d", os.date("*t").year)
  local archive_path = vimwiki_path .. "/" .. vim.g.archive_path .. "/" .. year .. "/" .. link_name .. ".wiki"
  local expanded_archive_path = vim.fn.expand(archive_path)

  if IsFileExists(expanded_archive_path) then
    vim.notify("file already exists: " .. expanded_archive_path, vim.log.levels.ERROR)
    return
  end

  local success = os.rename(expanded_file_path, expanded_archive_path)

  if success then
    vim.notify("archived: " .. archive_path, vim.log.levels.INFO)
    local current_line = vim.fn.line(".")
    vim.api.nvim_buf_set_lines(0, current_line - 1, current_line, false, {})
  else
    vim.notify("failed to archive", vim.log.levels.ERROR)
  end
end

function IsFileExists(file_name)
  return vim.fn.filereadble(file_name) == 1
end

function UpdateArchiveIndex() 
  local vimwiki_path = vim.g.vimwiki_list[1]["path"]
  local year = string.format("%d", os.date("*t").year)
  local archive_dir = vimwiki_path .. "/" .. vim.g.archive_path .. "/" .. year .. "/"
  local expanded_archive_path = vim.fn.expand(archive_dir)

  if vim.fn.isdirectory(expanded_archive_path) == 0 then
    vim.notify("directory not found: " .. archive_dir, vim.log.levels.ERROR)
    return
  end

  local wiki_list = {}
  for name, type in vim.fs.dir(expanded_archive_path) do
    if type == "file" and string.match(name, "%.wiki$") then
      table.insert(wiki_list, "[[" .. "./" .. vim.g.archive_path .. "/" .. year .. "/" .. name .. "]]")
    end
  end

  local target_index = 0
  local current_buffer = vim.api.nvim_get_current_buf()
  local lines = vim.api.nvim_buf_get_lines(current_buffer, 0, -1, true)
  for i = 0, #lines do
    if lines[i] == "= 2025 =" then
      target_index = i
      break
    end
  end
  local end_index = -1
  lines = vim.api.nvim_buf_get_lines(current_buffer, target_index, -1, true)
  for i = 0, #lines do
    if lines[i] == "" then
      end_index = target_index + i
      break
    end
  end
  vim.api.nvim_buf_set_lines(current_buffer, target_index, end_index, true, {})
  vim.api.nvim_buf_set_lines(current_buffer, target_index, #wiki_list, false, wiki_list)
end

vim.api.nvim_create_user_command("ArchiveLink", WikiArchive, {})
vim.api.nvim_create_user_command("UpdateArchiveIndex", UpdateArchiveIndex, {})
vim.g.archive_path = "archive"
