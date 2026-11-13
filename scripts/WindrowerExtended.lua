-- Windrower Extended v1.0.0.0 (FS25) - PC/Mac release candidate (multiplayer enabled).
-- Extends the existing GIANTS Windrower specialization; never creates shop vehicles.
-- Retains original crop effects/animation, work areas and drop area behavior.
WindrowerExtended = WindrowerExtended or {}
local WE = WindrowerExtended
WE.PREFIX = "[WindrowerExtended] "

-- The five swath types from the MacDon Pack.
WE.BASE_TYPES = { "WHEAT_CUT", "BARLEY_CUT", "OAT_CUT", "CANOLA_CUT", "SOYBEAN_CUT" }
-- Optional candidates, applied only if a compatible map/mod actually registers them.
-- Names vary across third-party swathing mods; unregistered names are silently skipped.
WE.OPTIONAL_TYPES = { "SORGHUM_CUT", "LONG_GRAIN_RICE_CUT", "RICE_LONG_GRAIN_CUT", "LONGGRAINRICE_CUT" }

function WE.afterWindrowerLoad(vehicle, savegame)
    local spec = vehicle ~= nil and vehicle.spec_windrower or nil
    if spec == nil or type(spec.supportedFillTypes) ~= "table" or spec.windrowerExtendedApplied then
        return
    end
    local manager = g_fillTypeManager
    if manager == nil or type(manager.getFillTypeIndexByName) ~= "function" then
        print(WE.PREFIX .. "FillTypeManager not ready; no changes made")
        return
    end
    spec.windrowerExtendedApplied = true
    local seen = {}
    for _, index in ipairs(spec.supportedFillTypes) do seen[index] = true end
    local added = {}
    local function add(name)
        local index = manager:getFillTypeIndexByName(name)
        if index == nil or (FillType ~= nil and index == FillType.UNKNOWN) or seen[index] then
            return
        end
        table.insert(spec.supportedFillTypes, index)
        seen[index] = true
        table.insert(added, name)
        if vehicle.addAIDensityHeightTypeRequirement ~= nil then
            vehicle:addAIDensityHeightTypeRequirement(index)
        end
    end
    for _, name in ipairs(WE.BASE_TYPES) do add(name) end
    for _, name in ipairs(WE.OPTIONAL_TYPES) do add(name) end
    if #added > 0 then
        local vehicleName = vehicle.configFileNameClean or vehicle.typeName or "windrower"
        print(string.format("%s%s: %s", WE.PREFIX, tostring(vehicleName), table.concat(added, ", ")))
    end
end

if Windrower ~= nil and type(Windrower.onLoad) == "function"
    and Utils ~= nil and type(Utils.appendedFunction) == "function" then
    Windrower.onLoad = Utils.appendedFunction(Windrower.onLoad, WE.afterWindrowerLoad)
    print(WE.PREFIX .. "Windrower load hook installed")
else
    print(WE.PREFIX .. "ERROR: Windrower specialization unavailable")
end
