-- SPDX-License-Identifier: GPL-3.0-only
-- Importé de https://github.com/cruz53/ics_wireshark_tools (lib/windows.lua),
-- commit d0649b4041b3c91a30334b64aa5a7375de73c0fc du 08/07/2026.
-- Licence amont : GPL-3.0-only (LICENSE amont) — voir README.md.
-- lib/windows.lua
--
-- Shared TextWindow and summary formatting helpers for ICS Visibility.

local source = debug.getinfo(1, "S").source

if source:sub(1, 1) == "@" then
  source = source:sub(2)
end

source = source:gsub("\\", "/")

local root = source:match("^(.*[/\\])") or ""

if root:match("/lib/$") then
  root = root:gsub("/lib/$", "/")
elseif root:match("/protocols/$") then
  root = root:gsub("/protocols/$", "/")
end

local bootstrap = dofile(root .. "lib/bootstrap.lua")
bootstrap.setup_from_file(source)

local counters = require("lib.counters")

local M = {}

local function tostring_safe(value)
  if value == nil then
    return ""
  end

  return tostring(value)
end

local function make_fallback_window(title)
  local win = {
    title = title or "ICS Visibility",
    text = "",
  }

  function win:set(text)
    self.text = tostring_safe(text)
  end

  function win:append(text)
    self.text = self.text .. tostring_safe(text)
  end

  function win:add_button(_label, _callback)
  end

  return win
end

function M.show_text(title, text)
  title = title or "ICS Visibility"
  text = tostring_safe(text)

  if TextWindow == nil or TextWindow.new == nil then
    local fallback = make_fallback_window(title)
    fallback:set(text)

    return fallback
  end

  local win = TextWindow.new(title)
  win:set(text)

  return win
end

function M.add_line(lines, text)
  lines[#lines + 1] = tostring_safe(text)
end

function M.add_blank(lines)
  lines[#lines + 1] = ""
end

function M.add_rule(lines, width, char)
  width = width or 72
  char = char or "="

  lines[#lines + 1] = string.rep(char, width)
end

function M.add_header(lines, title, width)
  width = width or 72

  M.add_line(lines, title)
  M.add_line(lines, string.rep("=", width))
end

function M.add_subheader(lines, title, width)
  width = width or 72

  M.add_blank(lines)
  M.add_line(lines, title)
  M.add_line(lines, string.rep("-", math.min(width, #title)))
end

function M.add_key_value(lines, key, value, key_width)
  key_width = key_width or 22

  M.add_line(
    lines,
    string.format(
      "%-" .. tostring(key_width) .. "s %s",
      tostring_safe(key) .. ":",
      tostring_safe(value)
    )
  )
end

function M.add_count_section(lines, title, counts, limit)
  local items = counters.top(counts, limit)

  M.add_blank(lines)
  M.add_line(lines, title)
  M.add_line(lines, string.rep("-", #title))

  if #items == 0 then
    M.add_line(lines, "  none")

    return
  end

  for _, item in ipairs(items) do
    M.add_line(
      lines,
      string.format(
        "  %-48s %8d",
        tostring_safe(item.key),
        tonumber(item.count) or 0
      )
    )
  end
end

function M.add_list_section(lines, title, values, limit)
  values = values or {}
  limit = limit or #values

  M.add_blank(lines)
  M.add_line(lines, title)
  M.add_line(lines, string.rep("-", #title))

  if #values == 0 then
    M.add_line(lines, "  none")

    return
  end

  for index, value in ipairs(values) do
    if index > limit then
      break
    end

    M.add_line(lines, "  " .. tostring_safe(value))
  end
end

function M.add_table_section(lines, title, headers, rows, limit)
  headers = headers or {}
  rows = rows or {}
  limit = limit or #rows

  M.add_blank(lines)
  M.add_line(lines, title)
  M.add_line(lines, string.rep("-", #title))

  if #rows == 0 then
    M.add_line(lines, "  none")

    return
  end

  M.add_line(lines, "  " .. table.concat(headers, " | "))
  M.add_line(lines, "  " .. string.rep("-", 68))

  for index, row in ipairs(rows) do
    if index > limit then
      break
    end

    local values = {}

    for _, header in ipairs(headers) do
      values[#values + 1] = tostring_safe(row[header])
    end

    M.add_line(lines, "  " .. table.concat(values, " | "))
  end
end

function M.add_notes(lines, notes)
  notes = notes or {}

  M.add_blank(lines)
  M.add_line(lines, "Notes:")
  M.add_line(lines, "------")

  if #notes == 0 then
    M.add_line(lines, "  none")

    return
  end

  for _, note in ipairs(notes) do
    M.add_line(lines, "- " .. tostring_safe(note))
  end
end

function M.join(lines)
  return table.concat(lines or {}, "\n")
end

function M.show_lines(title, lines)
  return M.show_text(title, M.join(lines))
end

function M.show_error(title, message)
  return M.show_text(
    title or "ICS Visibility Error",
    "Error:\n\n" .. tostring_safe(message)
  )
end

function M.add_refresh_button(win, callback)
  if win == nil or win.add_button == nil then
    return
  end

  win:add_button("Refresh", callback)
end

function M.add_clear_button(win, callback)
  if win == nil or win.add_button == nil then
    return
  end

  win:add_button("Clear Counters", callback)
end

function M.add_export_button(win, callback)
  if win == nil or win.add_button == nil then
    return
  end

  win:add_button("Export CSV", callback)
end

return M