local constants = require "constants"
local spidertron_lib = require "spidertron_lib"

---@param grid LuaEquipmentGrid
---@param is_buoy boolean
---@return boolean
local function check_owner(grid, is_buoy)
    local owner = grid.entity_owner
    if not owner then return false end
    if owner.type ~= "spider-vehicle" then return false end
    return is_buoy == (owner.name:sub(-8) == "-buoyant")
end

---@param event EventData.on_equipment_inserted
local function add_equipment(event)
    if event.equipment.name ~= constants.buoy_item then return end
    if not check_owner(event.grid, false) then return end
    -- Proceed if the entity is not a buoy spidertron

    local entity = event.grid.entity_owner
    ---@cast entity LuaEntity
    local spider_data = spidertron_lib.serialise_spidertron(entity)
    local new_spider = entity.surface.create_entity {
        name = entity.name .. "-buoyant",
        position = entity.position,
        force = entity.force,
        quality = entity.quality,
        create_build_effect_smoke = false,
    }
    if not new_spider then return end
    spidertron_lib.deserialise_spidertron(new_spider, spider_data, true)
    entity.destroy()
end

---@param event EventData.on_equipment_removed
local function remove_equipment(event)
    if event.equipment ~= constants.buoy_item then return end
    if not check_owner(event.grid, true) then return end
    if event.grid.count(constants.buoy_item) > 0 then return end
    -- Proceed if the entity is a buoy spidertron and has no buoys

    local entity = event.grid.entity_owner
    ---@cast entity LuaEntity
    local spider_data = spidertron_lib.serialise_spidertron(entity)
    local new_spider = entity.surface.create_entity {
        name = entity.name:sub(1, -9),
        position = entity.position,
        force = entity.force,
        create_build_effect_smoke = false
    }
    if not new_spider then return end
    spidertron_lib.deserialise_spidertron(new_spider, spider_data, true)
    entity.destroy()
end

script.on_event(defines.events.on_equipment_inserted, add_equipment)
script.on_event(defines.events.on_equipment_removed, remove_equipment)
