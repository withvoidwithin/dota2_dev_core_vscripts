---- ════════════════════════════════════════════════════════════════
----        Copyright © WITHVOIDWITHIN — All rights reserved.
----         https://steamcommunity.com/id/withvoidwithin/
----               https://withvoidwithin.github.io/
---- ════════════════════════════════════════════════════════════════

---- Store — Usage Guide
---- ================================================================================================================================
--[[
    SERVER ONLY.  A small component store.

    Data lives in one shared table (data/store.lua):   store[component_name][key] = value
    StoreAPI is a set of stateless read/write helpers over it. A component marked networked is mirrored
    on every write to a CustomNetTable "component.<name>" (same key) — so the client UI reads one truth.

    Each component is its own module in data/components/ that wraps StoreAPI with typed methods, so call
    sites get autocompletion and never touch raw keys or StoreAPI directly.

    ── Add a component ─────────────────────────────────────────────────────────────────
        1) data/components/<name>.lua

            local Component     = {}
            local ComponentName = "<name>"
            local Store         = require("data.store")
            local StoreAPI      = require("core.store_api")
            local IsNetworked   = true                      -- false → server-only, no NetTable

            --- @param player_id integer
            --- @return _Component_<Name>
            function Component.New(player_id)
                return StoreAPI.SetPlayer(Store, ComponentName, player_id,
                    { player_id = player_id }, IsNetworked)   -- value shape is yours
            end

            --- @param player_id integer
            function Component.Get(player_id)
                return StoreAPI.GetPlayer(Store, ComponentName, player_id)
            end

            return Component

        2) If networked, declare the NetTable in scripts/custom_net_tables.txt:

            custom_net_tables =
            [
                "component.<name>",
            ]

        3) Use it (server):

            local PlayerData = require("data.components.player_data")
            PlayerData.New(player_id)
            local data = PlayerData.Get(player_id)

    ── Key conventions ─────────────────────────────────────────────────────────────────
        SetPlayer   / GetPlayer    → key "player_<id>"        per-player data
        SetGameMode / GetGameMode  → key "gamemode"           singleton data
        Set         / Get          → key tostring(ent_index)  per-entity data

    Columns are created on first write; data survives hot-reload (kept on _G._STORE).
]]

--- @class _StoreAPI
local StoreAPI = {}

---- Write
---- ================================================================================================================================

--- @param store _Store
--- @param component_name string
--- @param ent_index int|string
--- @param value any
--- @param is_networked bool
function StoreAPI.Set(store, component_name, ent_index, value, is_networked)
    local index = tostring(ent_index)

    store[component_name] = store[component_name] or {}
    store[component_name][index] = value

    if is_networked then CustomNetTables:SetTableValue("component."..component_name, index, value) end

    return value
end

--- @param store _Store
--- @param component_name string
--- @param player_id int
--- @param value any
--- @param is_networked bool
function StoreAPI.SetPlayer(store, component_name, player_id, value, is_networked)
    return StoreAPI.Set(store, component_name, "player_"..player_id, value, is_networked)
end

--- @param store _Store
--- @param component_name string
--- @param value any
--- @param is_networked bool
function StoreAPI.SetGameMode(store, component_name, value, is_networked)
    return StoreAPI.Set(store, component_name, "gamemode", value, is_networked)
end

---- Read
---- ================================================================================================================================

--- @param store _Store
--- @param component_name string
--- @param ent_index int|string
function StoreAPI.Get(store, component_name, ent_index)
    local components = store[component_name]

    if components then return store[component_name][tostring(ent_index)] end
end

--- @param store _Store
--- @param component_name string
--- @param player_id int
function StoreAPI.GetPlayer(store, component_name, player_id)
    return StoreAPI.Get(store, component_name, "player_"..player_id)

end

--- @param store _Store
--- @param component_name string
function StoreAPI.GetGameMode(store, component_name)
    return StoreAPI.Get(store, component_name, "gamemode")
end

return StoreAPI

---- Annotations
---- ================================================================================================================================