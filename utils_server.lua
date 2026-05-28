---- ════════════════════════════════════════════════════════════════
----        Copyright © WITHVOIDWITHIN — All rights reserved.
----         https://steamcommunity.com/id/withvoidwithin/
----               https://withvoidwithin.github.io/
---- ════════════════════════════════════════════════════════════════

--- Precaches a set of resources by type using the provided context.
--- Iterates over a table of resource types and their associated file paths,
--- calling PrecacheResource for each entry.
--- @param context CScriptPrecacheContext The precache context provided by the engine
--- @param res? _PrecacheTable Table of resource types mapped to lists of file paths
--- @usage
--- function Precache(context)
---     _Precache(context, {
---         model         = { "models/heroes/antimage/antimage.vmdl" },
---         particle      = { "particles/units/heroes/hero_antimage/antimage_blink.vpcf" },
---         soundfile     = { "soundevents/game_sounds_heroes/game_sounds_antimage.vsndevts" },
---         model_folder  = { "models/heroes/antimage" },
---     })
--- end
--- **[ Server ]**
function _Precache(context, res)
    for type, files in pairs(res or {}) do
        for _, File in pairs(files or {}) do
            PrecacheResource(type, File, context)
        end
    end
end

---- Annotations
---- ================================================================================================================================

--- @alias _PrecacheType
--- | "model_folder"
--- | "model"
--- | "particle_folder"
--- | "particle"
--- | "soundfile"

--- @alias _PrecacheTable {[_PrecacheType]: table<string>}
