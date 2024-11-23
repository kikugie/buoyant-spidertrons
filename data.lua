local constants = require "constants"
local simulations = require "simulations"

local buoy_item = table.deepcopy(data.raw["item"]["belt-immunity-equipment"])
buoy_item.name = constants.buoy_item
buoy_item.icon = constants.mod_path .. "/graphics/icons/buoy.png"
buoy_item.place_as_equipment_result = constants.buoy_item
buoy_item.factoriopedia_simulation = simulations.buoy_effect

local buoy_equipment = table.deepcopy(data.raw["night-vision-equipment"]["night-vision-equipment"])
buoy_equipment.name = constants.buoy_item
buoy_equipment.sprite = {
    filename = constants.mod_path .. "/graphics/equipment/buoy.png",
    size = { 64, 128 }
}
buoy_equipment.shape = {
    width = 1,
    height = 2,
    type = "full"
}
buoy_equipment.categories = { "buoyant" }
buoy_equipment.color_lookup = { { 1, "identity" } }
buoy_equipment.darkness_to_turn_on = 0
buoy_equipment.energy_input = "0W"
buoy_equipment.energy_source = { type = "electric", usage_priority = "primary-input" }

local buoy_ingredients = {
    { type = "item", name = "iron-stick", amount = 5 },
}
if mods["space-age"] then
    table.insert(buoy_ingredients, { type = "item", name = "carbon-fiber", amount = 10 })
else
    table.insert(buoy_ingredients, { type = "item", name = "plastic-bar", amount = 10 })
end
local buoy_recipe = {
    type = "recipe",
    name = constants.buoy_item,
    enabled = false,
    energy_required = 10,
    ingredients = buoy_ingredients,
    results = { { type = "item", name = constants.buoy_item, amount = 1 } }
}

local buoy_science = {
    { "automation-science-pack", 1 },
    { "logistic-science-pack",   1 },
    { "chemical-science-pack",   1 },
}
if mods["space-age"] then
    table.insert(buoy_science, { "agricultural-science-pack", 1 })
end
local buoy_technology = {
    type = "technology",
    name = constants.buoy_item,
    icons = util.technology_icon_constant_equipment(constants.mod_path .. "/graphics/technology/buoy.png"),
    prerequisites = { "spidertron" },
    effects = {
        {
            type = "unlock-recipe",
            recipe = constants.buoy_item
        }
    },
    unit = {
        ingredients = buoy_science,
        count = 200,
        time = 15
    }
}

local buoy_equipment_category = {
    type = "equipment-category",
    name = "buoyant"
}

data:extend { buoy_item, buoy_equipment, buoy_recipe, buoy_technology, buoy_equipment_category }
