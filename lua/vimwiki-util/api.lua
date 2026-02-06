local ERROR = vim.log.levels.ERROR
local INFO = vim.log.levels.INFO

local function getCurrentLine()
  return vim.fn.getline(".")
end

local function getCurrentLineNumber()
  return vim.fn.line(".")
end

local function modifyCurrentBuffer(from, to, content)
    vim.api.nvim_buf_set_lines(0, from, to, true, content)
end

local function appendToCurrentBuffer(content)
    vim.api.nvim_buf_set_lines(0, -1, -1, false, content)
end

local function clearCurrentBuffer()
    vim.api.nvim_buf_set_lines(0, 1, -1, true, {})
end

local function expand(path)
  return vim.fn.expand(path)
end

local function file_exists(path)
  return vim.fn.filereadable(path) == 1
end

local function isDirectory(path)
  return vim.fn.isdirectory(path) == 1
end

local function listDirectory(path)
  return vim.fs.dir(path)
end

local function notifyError(msg)
  vim.notify(msg, ERROR, {})
end

local function notifyInfo(msg)
  vim.notify(msg, INFO, {})
end

return {
  getCurrentLine = getCurrentLine, 
  getCurrentLineNumber = getCurrentLineNumber,
  modifyCurrentBuffer = modifyCurrentBuffer,
  appendToCurrentBuffer = appendToCurrentBuffer,
  clearCurrentBuffer = clearCurrentBuffer,
  expand = expand,
  file_exists = file_exists,
  isDirectory = isDirectory,
  listDirectory = listDirectory,
  notifyError = notifyError,
  notifyInfo = notifyInfo,
}
