local simulations = {}

--- Fills the surface with concrete and water
---@return string
local function build_buoy_simulation_init()
    ---@type string[]
    local lines = {}
    table.insert(lines, "game.simulation.camera_position = {0, -1}")
    table.insert(lines, "game.simulation.camera_zoom = 1")
    table.insert(lines, "game.surfaces[1].set_tiles({")
    for y = -15, 15 do
        for x = -20, -5 do
            table.insert(lines, string.format("{ position = {%d, %d}, name = \"refined-concrete\" },", x, y))
        end
    end
    table.insert(lines, "})")
    table.insert(lines, "game.surfaces[1].set_tiles({")
    for y = -15, 15 do
        for x = -4, 20 do
            table.insert(lines, string.format("{ position = {%d, %d}, name = \"water\" },", x, y))
        end
    end
    table.insert(lines, "})")
    table.insert(lines, "game.surfaces[1].create_entity { name=\"spidertron\", position={-18, 0} }")

    return table.concat(lines, "\n")
end

---@type data.SimulationDefinition
simulations.buoy_effect = {
    init = build_buoy_simulation_init(),
    update = [[
        local spider = game.surfaces[1].find_entities_filtered { area = { {-20, -5}, {20, 5} }, type = "spider-vehicle" }[1]
        local mod = game.tick % 300
        if mod == 0 then
            spider.autopilot_destination = { 18, 0 }
        elseif mod == 90 then
            spider.autopilot_destination = { -6, 0 }
        elseif mod == 180 then
            spider.autopilot_destination = { 18, 0 }
            spider.grid.put { name = "buoy-equipment" }
            rendering.draw_text { text = { "", {"", "+1 "}, {"equipment-name.buoy-equipment"} }, surface = 1, target = {-7, 0}, color = {1, 1, 1}, scale = 2, time_to_live = 30 }
        elseif mod == 290 then
            spider.teleport({-18, 0})
            spider.grid.clear()
        end
    ]],
    mods = { "buoyant-spidertrons" }
}

return simulations
