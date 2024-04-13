-- curl https://api.github.com/users/octocat

-- curl --location 'http://localhost:9999/api/auth/request' \
-- --header 'Content-Type: text/plain' \
-- --data-raw '{"email":"spik_13@mail.ru"}'
--
local M = {}

M.debug_mode = 0

local function debug_print(...)
  if M.debug_mode == 1 then print(...) end
end

local function remove_carriage_returns(str) return str:gsub("\r", "") end

function M.run_curl_command()
  local line_number = vim.api.nvim_win_get_cursor(0)[1] - 1
  local bufnr = vim.api.nvim_get_current_buf()
  local lines = vim.api.nvim_buf_get_lines(bufnr, line_number, vim.api.nvim_buf_line_count(bufnr), false)
  local command_parts = {}
  local found_curl = false

  debug_print("Starting to analyze buffer lines from current line number:", line_number + 1)

  for i, line in ipairs(lines) do
    debug_print("Analyzing line:", line)
    -- Check for the presence of the 'curl' command or continuation in the line
    local is_curl_line = line:match "^%s*[#/;%*%-%[%{'\"].*curl%s+"
    local continuation_line = line:match "^%s*[#/;%*%-%[%{'\"]+(.*)"

    if i == 1 and is_curl_line then
      found_curl = true
      -- Extract everything after 'curl' including potential continuation characters
      local match = line:match "curl%s+(.*)"
      if match:match "\\%s*$" then -- Check if ends with a backslash
        debug_print "Continuation line ends with a backslash, trimming."
        match = match:gsub("\\%s*$", "")
        debug_print("Trimmed continuation line:", match)
      end
      table.insert(command_parts, match)
      debug_print("Found initial curl command, adding to parts:", match)
    elseif found_curl and continuation_line then
      -- Append continuation lines directly
      local trimmed_continuation = continuation_line
      if trimmed_continuation:match "\\%s*$" then -- Check if ends with a backslash
        debug_print "Continuation line ends with a backslash, trimming."
        trimmed_continuation = trimmed_continuation:gsub("\\%s*$", "")
        debug_print("Trimmed continuation line:", trimmed_continuation)
      end
      table.insert(command_parts, trimmed_continuation)
      debug_print("Continuation command found, adding to parts:", trimmed_continuation)
    elseif found_curl and not continuation_line then
      debug_print "No continuation found or different content, stopping."
      break
    end
  end

  if #command_parts > 0 then
    local curl_command = "curl -s -i " .. table.concat(command_parts, " ") -- Concatenate all parts with a space
    debug_print("Executing full curl command:", curl_command)
    local handle = io.popen(curl_command .. " 2>&1")
    local result = handle:read "*a"
    handle:close()

    debug_print("Command execution result:", result)

    local result_lines = vim.split(result, "\n")
    table.insert(result_lines, 1, "")
    table.insert(result_lines, 1, "Command: " .. curl_command)
    table.insert(result_lines, 3, "")

    local buf = vim.api.nvim_create_buf(false, true)
    local width = math.floor(vim.o.columns * 0.8)
    local height = math.floor(vim.o.lines * 0.8)
    local win = vim.api.nvim_open_win(buf, true, {
      relative = "editor",
      width = width,
      height = height,
      col = math.floor(vim.o.columns * 0.1),
      row = math.floor(vim.o.lines * 0.1),
      style = "minimal",
      border = "rounded",
    })

    for i, line in ipairs(result_lines) do
      result_lines[i] = remove_carriage_returns(line)
    end

    vim.api.nvim_buf_set_lines(buf, 0, -1, false, result_lines)
    -- vim.api.nvim_buf_add_highlight(buf, -1, "Title", 1, 0, -1)
    local command_color = "Title"
    local blankline_color = "Constant"
    local rest_color = "String"

    local blankline_detected = false
    local start_colouring = false

    for i, line in ipairs(result_lines) do
      debug_print("Highlighting line:", i, line)
      if i == 1 then
        -- Highlight the first line (command line) with a specific color
        vim.api.nvim_buf_add_highlight(buf, -1, command_color, i - 1, 0, -1)
      elseif line:match "^%s*$" then
        debug_print("Blank line detected at line:", i, line)
        -- Highlight blank lines with another color
        blankline_detected = true
        if start_colouring then blankline_detected = false end
      elseif blankline_detected then
        -- Highlight lines after a blank line with a different color
        start_colouring = true
        vim.api.nvim_buf_add_highlight(buf, -1, blankline_color, i - 1, 0, -1)
      else
        -- Highlight the remaining lines as body text with a default color
        vim.api.nvim_buf_add_highlight(buf, -1, rest_color, i - 1, 0, -1)
      end
    end
  else
    print "No curl command found in the initial analysis."
  end
end

return M
