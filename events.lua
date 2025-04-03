--[[
local em = EventManager_New()
em:Register(evts)         -- add evts to event registrar
em:Unregister(evts)       -- remove all handlers for evt and remove it from registrary

em:Handle(evt, func, id?) -- register a handler for evt
em:RmHandler(evt, id)     -- remove handler
em:ClearHandlers(evt)     -- remove all handlers for evt

em:Dispatch(evt, ...)     -- call handlers for evt with ...

em[EVENT] = func          -- em:Handle
em[EVENT][id] = func|nil  -- em:Handle|em:RmHandler
em[EVENT] = nil           -- em:Unregister
em[EVENT](...)            -- em:Dispatch
em[EVENT]:ClearHandlers() -- em:ClearHandlers
]]

---@class ns
local ns = select(2, ...)
local std = ns.std

---@return fun(): integer
local function mkCounter()
    local i = 0
    return function()
        i = i + 1
        return i
    end
end

---@alias HandlerId integer|string
---@alias HandlerFn fun(...: any)

---@class EventHandlerMeta
---@operator call: fun(...: any) # alias for EventHandler:Dispatch(...)
---@field __newindex fun(self: EventHandler, id: HandlerId, fn: HandlerFn?) alias for self:Handle or self:RmHandler if fn is nil
---@field [HandlerId] HandlerFn alias for EventHandler.funcs

---@class EventHandler: EventHandlerMeta
---@field funcs { [HandlerId]: HandlerFn }
---@field private genId fun(): integer
local EventHandler = {}

---@return EventHandler
local function EventHandler_New()
    local eh = std.Mixin({ funcs = {}, genId = mkCounter() }, EventHandler)
    std.setmetatable(eh, {
        __call = eh.Dispatch,
        __index = eh.funcs,
        __newindex = function(self, id, func)
            if func == nil then
                self:RmHandler(id)
            else
                self:Handle(func, id)
            end
        end,
    })
    return eh
end

---@param func HandlerFn
---@param id HandlerId?
---@return HandlerId?
function EventHandler:Handle(func, id)
    if std.type(func) ~= 'function' then return nil end

    if id then
        if std.type(id) ~= 'number' and std.type(id) ~= 'string' then return nil end
        if self.funcs[id] then return nil end
    end

    id = id or self:genId()
    self.funcs[id] = func
    return id
end

---@param id HandlerId
---@return HandlerFn?
function EventHandler:RmHandler(id)
    local fn = self.funcs[id]
    self.funcs[id] = nil
    return fn
end

function EventHandler:ClearHandlers()
    self.funcs = {}
end

---@param ... any
function EventHandler:Dispatch(...)
    -- local function errorhandler(err) return std.geterrorhandler()(err) end

    for i, fn in std.pairs(self.funcs) do
        fn(...)
        -- std.securecallfunction(fn, ...)
        -- std.xpcall(fn, errorhandler, ...)
        -- std.print(std.sformat('[%s] calling %s with %s', tostring(i), fn, arg))
    end
end

---@class EventManagerMeta
---@field __newindex fun(self: EventManager, event: string, fn: HandlerFn?) alias for self:Handle or self:Unregister if fn is nil
---@field [string] EventHandler alias for EventManager.events

---@class EventManager: EventManagerMeta
---@field events { [string]: EventHandler }
local EventManager = {}

---@return EventManager
local function EventManager_New()
    local em = std.Mixin({ events = {} }, EventManager)
    std.setmetatable(em, {
        __index = em.events,
        __newindex = function(self, event, func)
            if func == nil then
                self:Unregister(event)
            else
                self:Handle(event, func)
            end
        end,
    })

    return em
end

---@param ... string
function EventManager:Register(...)
    local e
    for i = 1, std.select("#", ...) do
        e = std.select(i, ...)
        if not self.events[e] then
            self.events[e] = EventHandler_New()
        end
    end
end

---@param ... string
function EventManager:Unregister(...)
    local e
    for i = 1, std.select("#", ...) do
        e = std.select(i, ...)
        self.events[e] = nil
    end
end

---@param event string
---@param func fun(...)
---@param id HandlerId?
---@return HandlerId?
function EventManager:Handle(event, func, id)
    if not self.events[event] then return nil end
    return self.events[event]:Handle(func, id)
end

---@param event string
---@param id HandlerId
---@return HandlerFn?
function EventManager:RmHandler(event, id)
    if not self.events[event] then return nil end
    return self.events[event]:RmHandler(id)
end

---@param event string
function EventManager:ClearHandlers(event)
    if not self.events[event] then return end
    self.events[event]:ClearHandlers()
end

---@param event string
---@param ... any
function EventManager:Dispatch(event, ...)
    if not self.events[event] then return end
    self.events[event]:Dispatch(...)
end

ns.EventManager_New = EventManager_New
