---@class ns
local ns = select(2, ...)

ns.std = {
    type = type,
    pairs = pairs,
    select = select,
    setmetatable = setmetatable,
    sformat = string.format,
    print = print,
    securecallfunction = securecallfunction,
    geterrorhandler = geterrorhandler,

    Mixin = Mixin,
    CreateFrame = CreateFrame,
}
