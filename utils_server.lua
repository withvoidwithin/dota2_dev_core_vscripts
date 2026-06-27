---- ════════════════════════════════════════════════════════════════
----        Copyright © WITHVOIDWITHIN — All rights reserved.
----         https://steamcommunity.com/id/withvoidwithin/
----               https://withvoidwithin.github.io/
---- ════════════════════════════════════════════════════════════════

local source = ... ---@type string?
local path = type(source) == "string" and source:match("(.-)[^%.]+$") or ""

--- @class _Utils_Server: _Utils
local UtilsServer = setmetatable({}, { __index = require(path .. "utils") })

---- Main
---- ================================================================================================================================

--- Precaches a set of resources by type using the provided context.
--- Iterates over a table of resource types and their associated file paths,
--- calling PrecacheResource for each entry.
--- @param context CScriptPrecacheContext The precache context provided by the engine
--- @param res? _PrecacheTable Table of resource types mapped to lists of file paths
--- @usage
--- ```lua
--- _Precache(context, {
---     model         = { "models/heroes/antimage/antimage.vmdl" },
---     particle      = { "particles/units/heroes/hero_antimage/antimage_blink.vpcf" },
---     soundfile     = { "soundevents/game_sounds_heroes/game_sounds_antimage.vsndevts" },
---     model_folder  = { "models/heroes/antimage" },
--- })
--- ```
--- **[ Server ]**
function UtilsServer.Precache(context, res)
    for type, files in pairs(res or {}) do
        for _, File in pairs(files or {}) do
            PrecacheResource(type, File, context)
        end
    end
end

--- Registers a client game event listener and binds its tracking directly to the given context.
--- Automatically unregisters any pre-existing listener for the same event name on this context.
--- @param context table|any The context (table, custom class, or Dota entity) binding this listener
--- @param event_name string The custom network event name to listen for
--- @param callback fun(user_id: number, event: table) Callback executed when the event is received
--- @return number listener_id Returns the registered event listener ID
--- **[ Server Only ]**
function UtilsServer.RegisterClientEventListener(context, event_name, callback)
    context.__utils = context.__utils or {}
    local utils = context.__utils

    utils.client_event_listeners = utils.client_event_listeners or {}
    local listeners = utils.client_event_listeners

    if listeners[event_name] then CustomGameEventManager:UnregisterListener(listeners[event_name]) end
    listeners[event_name] = CustomGameEventManager:RegisterListener(event_name, callback)

    return listeners[event_name]
end

--- Unregisters client game event listeners bound to the given context.
--- If `event_name` is omitted, all registered listeners on this context are unregistered.
--- Cleans up empty internal tracking tables to prevent memory/table pollution.
--- @param context table|any The context (table, custom class, or Dota entity) the listener is bound to
--- @param event_name? string Optional. The custom network event name to unregister. If omitted, unregisters all listeners.
--- **[ Server Only ]**
function UtilsServer.UnregisterClientEventListener(context, event_name)
    local utils = context.__utils
    if not utils then return end

    local listeners = utils.client_event_listeners
    if not listeners then return end

    if event_name then
        local id = listeners[event_name]
        if id then
            CustomGameEventManager:UnregisterListener(id)
            listeners[event_name] = nil
        end
    else
        for name, id in pairs(listeners) do
            CustomGameEventManager:UnregisterListener(id)
            listeners[name] = nil
        end
    end

    if next(listeners) == nil then
        utils.client_event_listeners = nil
        if next(utils) == nil then
            context.__utils = nil
        end
    end
end

---- Annotations
---- ================================================================================================================================

--- @alias _PrecacheType "model_folder" | "model" | "particle_folder" | "particle" | "soundfile"
--- @alias _PrecacheTable table<_PrecacheType, string[]>

return UtilsServer