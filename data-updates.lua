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

---@param leg data.SpiderLegPart
local function apply_textures(leg)
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
    if not spider.equipment_grid then return end
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
    spider_copy.placeable_by = {
        item = spider.minable.result,
        count = spider.minable.count or 1
    }

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
        apply_textures(leg.graphics_set.lower_part)
        apply_textures(leg.graphics_set.lower_part_shadow)
        apply_textures(leg.graphics_set.lower_part_water_reflection)
        table.insert(mod_data, leg)
    end
    spider_copy.spider_engine.legs = new_legs
    table.insert(mod_data, spider_copy)
end

-- Mutate the default spidertron table
local default_grid = table.deepcopy(data.raw["equipment-grid"]["spidertron-equipment-grid"])
table.insert(default_grid.equipment_categories, "buoyant")
table.insert(mod_data, default_grid)

-- Create buoyant variants of spidertrons
for _, spidertron in pairs(data.raw["spider-vehicle"]) do
    create_jesus_spidertron(spidertron)
end

data:extend(mod_data)
