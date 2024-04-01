local addonName = ... ---@type string

---@class BetterBags: AceAddon
local addon = LibStub('AceAddon-3.0'):GetAddon(addonName)

---@class Debug
local debug = addon:GetModule('Debug')

---@param data ItemData
---@param id number
---@return boolean
function debug:IsItem(data, id)
  if data and data.itemInfo and data.itemInfo.itemID == id then
    return true
  end
  return false
end

local tooltipLines = 0

---@param first string
---@param second string
function debug:AddTooltipDouble(first, second)
  if tooltipLines % 2 == 0 then
    self.tooltip:AddDoubleLine(first, second, 1, 1, 1, 1, 1, 1)
  else
    self.tooltip:AddDoubleLine(first, second, 0.8, 0.5, 0.8, 0.8, 0.5, 0.8)
  end
  tooltipLines = tooltipLines + 1
end

function debug:AddTooltip(line)
  if tooltipLines % 2 == 0 then
    self.tooltip:AddLine(line, 1, 1, 1)
  else
    self.tooltip:AddLine(line, 0.8, 0.5, 0.8)
  end
  tooltipLines = tooltipLines + 1
end

---@param t table<any, any>
---@param depth number
function debug:WriteTooltip(t, depth)
  local indent = string.rep("   ", depth)
  if depth > 0 then
    local pos = depth * 2
    indent = ("%s%s%s"):format(indent:sub(1,pos-1), "|-", indent:sub(pos+1))
  end
  for k, v in pairs(t) do
    if type(v) == "table" then
      self:AddTooltip(indent .. k .. ":")
      self:WriteTooltip(v, depth + 1)
    elseif v == nil then
      self:AddTooltipDouble(indent .. k, "nil")
    elseif type(v) ~= "string" then
      self:AddTooltipDouble(indent .. k, tostring(v))
    else
      self:AddTooltipDouble(indent .. k, v)
    end
  end
end

---@param item Item
function debug:ShowItemTooltip(item)
  if not self.enabled then return end
  self.tooltip:SetOwner(UIParent, 'ANCHOR_LEFT', 30, 0)
  if item.data.isItemEmpty then
    self:AddTooltip("Empty")
  else
    self:AddTooltip(item.data.itemInfo.itemLink)
  end

  self:WriteTooltip(item.data, 0)

  self.tooltip:Show()
end

---@param item Item
function debug:HideItemTooltip(item)
  _ = item
  tooltipLines = 0
  self.tooltip:Hide()
end

---@return boolean
function debug:MockBackpackItems()
  if not self.enabled then return false end

  ---@class Events: AceModule
  local events = addon:GetModule('Events')

  ---@class Items: AceModule
  local items = addon:GetModule('Items')

  ---@type ExtraSlotInfo
  local extraSlotInfo = {
    emptySlots = {},
    freeSlotKeys = {},
    totalItems = 0,
    freeSlotKey = "",
    freeReagentSlotKey = "",
    emptySlotByBagAndSlot = {},
    dirtyItems = {},
    itemsBySlotKey = {},
  }

  items.slotInfo = CopyTable(extraSlotInfo)

  -- All items in all bags have finished loading, fire the all done event.
  events:SendMessageLater('items/RefreshBackpack/Done', function()
    items._container = nil
    items._doingRefreshAll = false
  end,
  extraSlotInfo)

  return true
end
