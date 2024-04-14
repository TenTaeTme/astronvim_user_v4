-- curl https://api.github.com/users/octocat

-- curl --location 'http://localhost:9999/api/auth/request' \
-- --header 'Content-Type: text/plain' \
-- --data-raw '{"email":"spik_13@mail.ru"}'

-- curl --location --request GET 'http://localhost:9999/api/admin/resources' \
-- --header 'Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE3MTM2ODQ5OTcsInBheWxvYWQiOnsiZW1haWwiOiJzcGlrXzEzQG1haWwucnUiLCJmaXJzdF9uYW1lIjoiIiwibGFzdF9uYW1lIjoiIiwidXNlcl9pZCI6IjY2MTUyZjBjMzMwMDQzZDJlODJlOTMyNSIsInVzZXJfcm9sZSI6ImFkbWluIiwidXNlcl9zbHVnIjoiODVmOTZhODgtMWNlYi00N2FjLWI1YmQtMjc3OTY3ZTQxYmM4In0sInRva2VuVHlwZSI6MX0.lkxzEx3Mpwt3k2dIxgFdA9Bh8s-PLdsp6vHxx3ye7VY' \
-- --header 'Content-Type: text/plain'
local M = {}

M.debug_mode = 0

local function format_result_lines(result, max_length, preserve_words)
  max_length = max_length or 80 -- Default maximum length of a line
  preserve_words = preserve_words or false -- Default to breaking anywhere if not specified
  local formatted_lines = {}
  local words = {}

  -- Iterate through each line in the result
  for line in result:gmatch "([^\r\n]*)\r?\n?" do
    if #line == 0 then
      -- If the line is empty, preserve the blank line
      table.insert(formatted_lines, "")
    else
      -- Reset the words table for each non-empty line
      words = {}
      -- Extract words from the line
      for word in line:gmatch "%S+" do
        table.insert(words, word)
      end

      -- Rebuild the line respecting the max_length
      local current_line = ""
      local current_length = 0
      for _, word in ipairs(words) do
        if preserve_words then
          -- Break line before word if adding it would exceed max_length
          if current_length + #word + 1 > max_length then
            table.insert(formatted_lines, current_line)
            current_line = word
            current_length = #word
          else
            current_line = current_line .. (#current_line > 0 and " " or "") .. word
            current_length = current_length + (#current_line > 0 and #word + 1 or #word)
          end
        else
          -- Break line immediately when reaching max_length
          for c in word:gmatch "." do
            if current_length == max_length then
              table.insert(formatted_lines, current_line)
              current_line = ""
              current_length = 0
            end
            current_line = current_line .. c
            current_length = current_length + 1
          end
          -- Add a space if not at line start and next word could fit on this line
          if current_length < max_length then
            current_line = current_line .. " "
            current_length = current_length + 1
          end
        end
      end
      -- Don't forget to add the last processed line if not empty
      if #current_line > 0 then table.insert(formatted_lines, current_line) end
    end
  end

  -- Join all formatted lines into a single string with new lines
  return table.concat(formatted_lines, "\n")
end
-- local function format_result_lines(result, max_length)
--   max_length = max_length or 80 -- Default max length of a line
--   local words = {}
--   local formatted_lines = {}
--   local current_line = {}
--
--   -- Break the result into words
--   for word in result:gmatch "%S+" do
--     table.insert(words, word)
--   end
--
--   local current_length = 0
--
--   -- Construct lines ensuring they don't exceed the max_length
--   for _, word in ipairs(words) do
--     if current_length + #word + 1 > max_length then
--       -- When adding this word would exceed max_length, start a new line
--       table.insert(formatted_lines, table.concat(current_line, " "))
--       current_line = {} -- Reset current line
--       current_length = 0 -- Reset length
--     end
--     table.insert(current_line, word)
--     current_length = current_length + #word + 1 -- +1 for the space between words
--   end
--
--   -- Don't forget to add the last line if any
--   if #current_line > 0 then table.insert(formatted_lines, table.concat(current_line, " ")) end
--
--   return formatted_lines
-- end

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

    result = format_result_lines(result, 140, false)

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
