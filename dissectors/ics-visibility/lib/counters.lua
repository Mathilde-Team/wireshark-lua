-- SPDX-License-Identifier: GPL-3.0-only
-- Importé de https://github.com/cruz53/ics_wireshark_tools (lib/counters.lua),
-- commit d0649b4041b3c91a30334b64aa5a7375de73c0fc du 08/07/2026.
-- Licence amont : GPL-3.0-only (LICENSE amont) — voir README.md.
-- lib/counters.lua
--
-- Shared counter/table helpers for ICS Visibility.
--
-- This module is intentionally dependency-light because almost every protocol
-- module uses it.

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

local function normalize_key(key)
  if key == nil then
    return "unknown"
  end

  key = tostring(key)

  if key == "" then
    return "unknown"
  end

  return key
end

local function normalize_amount(amount)
  if amount == nil then
    return 1
  end

  amount = tonumber(amount)

  if amount == nil then
    return 1
  end

  return amount
end

function M.bump(tbl, key, amount)
  key = normalize_key(key)
  amount = normalize_amount(amount)

  tbl[key] = (tbl[key] or 0) + amount

  return tbl[key]
end

function M.bump_all(tbl, values, amount)
  if values == nil then
    return
  end

  for _, value in ipairs(values) do
    M.bump(tbl, value, amount)
  end
end

function M.set(tbl, key, value)
  key = normalize_key(key)
  value = tonumber(value) or 0

  tbl[key] = value

  return tbl[key]
end

function M.add(dst, src)
  if src == nil then
    return dst
  end

  for key, value in pairs(src) do
    M.bump(dst, key, value)
  end

  return dst
end

function M.clear(tbl)
  for key, _ in pairs(tbl) do
    tbl[key] = nil
  end
end

function M.copy(tbl)
  local copied = {}

  if tbl == nil then
    return copied
  end

  for key, value in pairs(tbl) do
    copied[key] = value
  end

  return copied
end

function M.total(tbl)
  local total = 0

  if tbl == nil then
    return total
  end

  for _, value in pairs(tbl) do
    total = total + (tonumber(value) or 0)
  end

  return total
end

function M.unique_count(tbl)
  local count = 0

  if tbl == nil then
    return count
  end

  for _, _ in pairs(tbl) do
    count = count + 1
  end

  return count
end

function M.is_empty(tbl)
  if tbl == nil then
    return true
  end

  for _, _ in pairs(tbl) do
    return false
  end

  return true
end

function M.sorted_items(tbl)
  local items = {}

  if tbl == nil then
    return items
  end

  for key, count in pairs(tbl) do
    items[#items + 1] = {
      key = tostring(key),
      label = tostring(key),
      count = tonumber(count) or 0,
      value = tonumber(count) or 0,
    }
  end

  table.sort(items, function(left, right)
    if left.count == right.count then
      return left.key < right.key
    end

    return left.count > right.count
  end)

  return items
end

function M.top(tbl, limit)
  local items = M.sorted_items(tbl)

  if limit == nil or limit <= 0 or #items <= limit then
    return items
  end

  local trimmed = {}

  for index = 1, limit do
    trimmed[#trimmed + 1] = items[index]
  end

  return trimmed
end

function M.to_rows(tbl, key_name, count_name, limit)
  key_name = key_name or "key"
  count_name = count_name or "count"

  local rows = {}

  for _, item in ipairs(M.top(tbl, limit)) do
    rows[#rows + 1] = {
      [key_name] = item.key,
      [count_name] = item.count,
    }
  end

  return rows
end

function M.keys(tbl)
  local keys = {}

  if tbl == nil then
    return keys
  end

  for key, _ in pairs(tbl) do
    keys[#keys + 1] = tostring(key)
  end

  table.sort(keys)

  return keys
end

function M.values(tbl)
  local values = {}

  if tbl == nil then
    return values
  end

  for _, value in pairs(tbl) do
    values[#values + 1] = value
  end

  table.sort(values)

  return values
end

return M