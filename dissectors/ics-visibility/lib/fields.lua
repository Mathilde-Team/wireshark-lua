-- SPDX-License-Identifier: GPL-3.0-only
-- Importé de https://github.com/cruz53/ics_wireshark_tools (lib/fields.lua),
-- commit d0649b4041b3c91a30334b64aa5a7375de73c0fc du 08/07/2026.
-- Licence amont : GPL-3.0-only (LICENSE amont) — voir README.md.
-- lib/fields.lua
--
-- Shared Wireshark Field helpers for ICS Visibility.

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

local M = {}

function M.safe_field(name)
  local ok, field = pcall(Field.new, name)

  if ok then
    return field
  end

  return nil
end

function M.values(field)
  if field == nil then
    return {}
  end

  local results = {pcall(field)}

  if not results[1] then
    return {}
  end

  local values = {}

  for index = 2, #results do
    if results[index] ~= nil then
      values[#values + 1] = tostring(results[index])
    end
  end

  return values
end

function M.first(field)
  local values = M.values(field)

  if #values == 0 then
    return ""
  end

  return values[1]
end

function M.has_values(field)
  return #M.values(field) > 0
end

function M.values_any(primary, fallback)
  local values = M.values(primary)

  if #values > 0 then
    return values
  end

  return M.values(fallback)
end

function M.first_any(primary, fallback)
  local value = M.first(primary)

  if value ~= "" then
    return value
  end

  return M.first(fallback)
end

function M.parse_number(value)
  if value == nil or value == "" then
    return nil
  end

  value = tostring(value)

  local hex = value:match("^%s*0x([0-9a-fA-F]+)")

  if hex ~= nil then
    return tonumber(hex, 16)
  end

  local paren_hex = value:match("%(0x([0-9a-fA-F]+)%)")

  if paren_hex ~= nil then
    return tonumber(paren_hex, 16)
  end

  local leading = value:match("^%s*(%-?%d+)")

  if leading ~= nil then
    return tonumber(leading)
  end

  local paren = value:match("%((%-?%d+)%)")

  if paren ~= nil then
    return tonumber(paren)
  end

  return tonumber(value)
end

function M.first_number(field)
  return M.parse_number(M.first(field))
end

function M.first_number_any(primary, fallback)
  return M.parse_number(M.first_any(primary, fallback))
end

function M.numbers(field)
  local numbers = {}

  for _, value in ipairs(M.values(field)) do
    local number = M.parse_number(value)

    if number ~= nil then
      numbers[#numbers + 1] = number
    end
  end

  return numbers
end

function M.value_is_true(value)
  if value == nil then
    return false
  end

  value = tostring(value):lower()

  if value == "" then
    return false
  end

  if value == "0" then
    return false
  end

  if value == "false" then
    return false
  end

  if value:find("not set", 1, true) then
    return false
  end

  local number = M.parse_number(value)

  if number ~= nil then
    return number ~= 0
  end

  return true
end

function M.has_true(field)
  for _, value in ipairs(M.values(field)) do
    if M.value_is_true(value) then
      return true
    end
  end

  return false
end

function M.has_any_true(primary, fallback)
  return M.has_true(primary) or M.has_true(fallback)
end

function M.named_value(names, code, width)
  if code == nil then
    return "unknown"
  end

  width = width or 2

  return string.format(
    "0x%0" .. tostring(width) .. "X %s",
    code,
    names[code] or "Unknown"
  )
end

function M.first_named(field, names, width)
  return M.named_value(names, M.first_number(field), width)
end

function M.first_named_any(primary, fallback, names, width)
  return M.named_value(
    names,
    M.first_number_any(primary, fallback),
    width
  )
end

function M.named_values(field, names, width)
  local labels = {}

  for _, value in ipairs(M.values(field)) do
    labels[#labels + 1] = M.named_value(
      names,
      M.parse_number(value),
      width
    )
  end

  return labels
end

function M.named_values_any(primary, fallback, names, width)
  local labels = {}

  for _, value in ipairs(M.values_any(primary, fallback)) do
    labels[#labels + 1] = M.named_value(
      names,
      M.parse_number(value),
      width
    )
  end

  return labels
end

function M.join(values, separator)
  separator = separator or " / "

  if values == nil or #values == 0 then
    return ""
  end

  return table.concat(values, separator)
end

return M