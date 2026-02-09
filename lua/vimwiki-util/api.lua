local ERROR = vim.log.levels.ERROR
local INFO = vim.log.levels.INFO

local function get_current_line()
  return vim.fn.getline(".")
end

local function get_current_line_number()
  return vim.fn.line(".")
end

local function modify_current_buffer(from, to, content)
    vim.api.nvim_buf_set_lines(0, from, to, true, content)
end

local function append_to_current_buffer(content)
    vim.api.nvim_buf_set_lines(0, -1, -1, false, content)
end

local function clear_current_buffer()
    vim.api.nvim_buf_set_lines(0, 1, -1, true, {})
end

local function expand(path)
  return vim.fn.expand(path)
end

local function file_exists(path)
  return vim.fn.filereadable(path) == 1
end

local function is_directory(path)
  return vim.fn.isdirectory(path) == 1
end

local function list_directory(path)
  return vim.fs.dir(path)
end

local function notify_error(msg)
  vim.notify(msg, ERROR, {})
end

local function notify_info(msg)
  vim.notify(msg, INFO, {})
end

return {
  get_current_line = get_current_line,
  get_current_line_number = get_current_line_number,
  modify_current_buffer = modify_current_buffer,
  append_to_current_buffer = append_to_current_buffer,
  clear_current_buffer = clear_current_buffer,
  expand = expand,
  file_exists = file_exists,
  is_directory = is_directory,
  list_directory = list_directory,
  notify_error = notify_error,
  notify_info = notify_info,
}
