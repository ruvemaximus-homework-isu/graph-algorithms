#!/usr/bin/env lua

---@type string
local GRAPH_INPUT_FILENAME = arg[1]
local output_file = assert(io.open("output.csv", "w"))

if not GRAPH_INPUT_FILENAME then
    print("Usage: lua main.lua <input_file>")
    os.exit(1)
end

local File       = require("file")
local Ant        = require("ant")

-- Ant algorithm settings
local ALPHA      = os.getenv("ALPHA") or 1           -- важность феромонов
local BETA       = os.getenv("BETA") or 1            -- важность весов
local Q          = os.getenv("Q") or 4               -- интенсивность феромона
local P          = os.getenv("P") or 0.6             -- процент остающихся феромонов
local NUM_ANTS   = os.getenv("ANTS") or 100          -- количество муравьев
local NUM_ITERS  = os.getenv("ITERS") or 100         -- количество итераций
local START_NODE = os.getenv("START_NODE") or "RAND" -- начальная точка муравьев


local file = File:new(GRAPH_INPUT_FILENAME)
local nodesCount = 0

local graph = file:read_as_graph()

local best_path = nil
local best_distance = math.huge

local nodes = {}
for node, _ in pairs(graph) do
    table.insert(nodes, node)
    nodesCount = nodesCount + 1
end

print(string.format("Found %d nodes", nodesCount))

local get_start_node

if START_NODE == "RAND" then
    local rand = math.random
    get_start_node = function()
        return nodes[rand(1, nodesCount)]
    end
else
    get_start_node = function()
        return START_NODE
    end
end

output_file:write("iteration,best_route_length\n")

local function update_edge_pheromone(source, target, delta)
    local edge = graph[source][target]
    edge.pheromone = P * edge.pheromone + delta
end

local startTime = os.clock()

for iter = 1, NUM_ITERS do
    -- Инициализация муравьёв
    local ants = {}
    local iterStartTime = os.clock()

    -- Запускаем муравьев
    for i = 1, NUM_ANTS do
        local ant_start_node = get_start_node()

        ants[i] = Ant:new(ant_start_node)

        local ant = ants[i]

        for _ = 1, #nodes do
            local next_node = ant:choose_next_node(graph, ALPHA, BETA)
            if not next_node then break end
            ant:move_to_node(next_node, graph)
        end

        if #ant.path == #nodes and ant.total_distance < best_distance then
            local is_moved_to_start = ant:move_to_node(ant_start_node, graph)

            if is_moved_to_start then
                best_distance = ant.total_distance
                best_path = ant.path
            end
        end
    end

    -- Обновление феромонов
    for i = 1, NUM_ANTS do
        local ant = ants[i]

        local delta = Q / ant.total_distance

        for j = 1, #ant.path - 1 do
            update_edge_pheromone(ant.path[j], ant.path[j + 1], delta)
        end
    end

    print(string.format("[main] Iteration %d/%d complete (%.2fs)", iter, NUM_ITERS, os.clock() - iterStartTime))
    output_file:write(iter .. "," .. best_distance .. "\n")
end

output_file:close()

if best_path == nil then
    print("Best path not found :(")
    os.exit(0)
end

-- Выводим лучший найденный путь и его длину
print()
print("Best path:")
print(table.concat(best_path, " "))
print("---")
print("Total length: ", best_distance)
print(string.format("Execution time: %.2fs", os.clock() - startTime))
