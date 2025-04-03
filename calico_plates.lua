---@class ns
local ns = select(2, ...)
local std = ns.std

local eventFrame, events = std.CreateFrame('Frame'), {}

function events:PLAYER_LOGIN(...)
end

function events:PLAYER_LEAVING_WORLD(...)
end

function events:NAME_PLATE_CREATED(...)
end

function events:NAME_PLATE_UNIT_ADDED(...)
end

function events:NAME_PLATE_UNIT_REMOVED(...)
end

function events:UI_SCALE_CHANGED(...)
end

eventFrame:SetScript('OnEvent', function(self, event, ...)
    events[event](self, ...)
end)

for event in std.pairs(events) do
    eventFrame:RegisterEvent(event)
end
