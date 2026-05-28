---- ════════════════════════════════════════════════════════════════
----        Copyright © WITHVOIDWITHIN — All rights reserved.
----         https://steamcommunity.com/id/withvoidwithin/
----               https://withvoidwithin.github.io/
---- ════════════════════════════════════════════════════════════════

local path = type(...) == "string" and (...):match("(.-)[^%.]+$") or ""

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

---- Annotations
---- ================================================================================================================================

--- @alias _PrecacheType "model_folder" | "model" | "particle_folder" | "particle" | "soundfile"
--- @alias _PrecacheTable table<_PrecacheType, string[]>

return UtilsServer
