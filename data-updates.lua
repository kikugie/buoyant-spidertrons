local constants = require "constants"
local mod_data = {}

local function iter(t)
    local i = 0
    for _ in pairs(t) do
        i = i + 1
        if t[i] == nil then return pairs { t } end
    end
    return pairs(t)
end

---@param sprite data.RotatedSprite
local function make_sprite_buoyant(sprite)
    if sprite.filename and (sprite.filename:sub(1, 8) == "__base__") then
        sprite.filename = constants.mod_path .. sprite.filename:sub(9, -5) .. "-buoyant.png"
    end
end

---@param leg data.SpiderLegPart?
local function make_leg_buoyant(leg)
    if not leg then return end
    local sprite = leg.bottom_end
    if not sprite then return end
    make_sprite_buoyant(sprite)
    if sprite.layers then
        for _, layer in pairs(sprite.layers) do
            make_sprite_buoyant(layer)
        end
    end
end

---@param spider data.SpiderVehiclePrototype
local function create_jesus_spidertron(spider)
    -- Don't add buoyancy if it doesn't support equipment
    if spider.hidden or not spider.equipment_grid then return end
    local spider_copy = table.deepcopy(spider)

    -- Hide the duplicate entity and give it a new name
    spider_copy.hidden = true
    spider_copy.hidden_in_factoriopedia = true
    spider_copy.factoriopedia_alternative = spider.name
    spider_copy.name = spider.name .. "-buoyant"
    spider_copy.localised_name = spider.localised_name or { "entity-name." .. spider.name }

    -- Make it placeable with normal spidertron
    spider_copy.fast_replaceable_group = spider.fast_replaceable_group or spider.name
    spider_copy.deconstruction_alternative = spider.name
    if spider.placeable_by then
        spider_copy.placeable_by = spider.placeable_by
    elseif spider.minable then
        spider_copy.placeable_by = {
            item = spider.minable.result,
            count = spider.minable.count or 1
        }
    end

    local new_legs = {}
    for _, spec in iter(spider_copy.spider_engine.legs) do
        ---@cast spec data.SpiderLegSpecification
        -- Create new leg specification
        local copy = table.deepcopy(spec)
        copy.leg = spec.leg .. "-buoyant"
        table.insert(new_legs, copy)

        -- Create new leg prototype with no water collision
        local leg = table.deepcopy(data.raw["spider-leg"][spec.leg])
        leg.name = spec.leg .. "-buoyant"
        leg.collision_mask = {
            -- No idea what these masks do, but they work
            layers = {
                car = true,
                object = true,
                is_object = true,
                is_lower_object = true
            }
        }
        -- `leg.graphics_set.foot` could be used, but it looks worse
        if leg.graphics_set then
            make_leg_buoyant(leg.graphics_set.lower_part)
            make_leg_buoyant(leg.graphics_set.lower_part_shadow)
            make_leg_buoyant(leg.graphics_set.lower_part_water_reflection)
        end
        table.insert(mod_data, leg)
    end
    spider_copy.spider_engine.legs = new_legs
    table.insert(mod_data, spider_copy)
end

local registered_grids = {}

---@param grid data.EquipmentGridID
local function enable_buoy_in_grid(grid)
    local instance = table.deepcopy(data.raw["equipment-grid"][grid])
    table.insert(instance.equipment_categories, "buoyant")
    table.insert(mod_data, instance)
    registered_grids[grid] = true
end

-- Create buoyant variants of spidertrons
for _, spidertron in pairs(data.raw["spider-vehicle"]) do
    create_jesus_spidertron(spidertron)

    local grid_type = spidertron.equipment_grid
    if grid_type ~= nil and registered_grids[grid_type] == nil then
        enable_buoy_in_grid(grid_type)
    end
end

data:extend(mod_data)
