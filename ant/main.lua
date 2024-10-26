#!/usr/bin/env lua

local input_file = arg[1]

local File       = require("file")
local Ant        = require("ant")

local ALPHA      = os.getenv("ALPHA") or 1   -- важность феромонов
local BETA       = os.getenv("BETA") or 1    -- важность весов
local Q          = os.getenv("BETA") or 4    -- интенсивность феромона
local P          = os.getenv("P") or 0.6     -- процент остающихся феромонов
local NUM_ANTS   = os.getenv("ANTS") or 100  -- Количество муравьев
local NUM_ITERS  = os.getenv("ITERS") or 100 -- Количество итераций

if not input_file then
    print("Usage: lua main.lua <input_file>")
    os.exit(1)
end

-- Создаём экземпляр класса File
local file = File:new(input_file)

local graph = file:read_as_graph()

local best_path = nil
local best_distance = math.huge

local nodes = {}
for node, _ in pairs(graph) do
    table.insert(nodes, node)
end

local rand = math.random

local function get_start_node()
    return nodes[rand(1, #nodes)]
end

local startTime = os.clock()

for iter = 1, NUM_ITERS do
    -- Инициализация муравьёв
    local ants = {}
    local iterStartTime = os.clock()

    for i = 1, NUM_ANTS do
        ants[i] = Ant:new(get_start_node())

        local ant = ants[i]
        for _ = 1, #nodes do
            local next_node = ant:choose_next_node(graph, ALPHA, BETA)
            if not next_node then break end
            ant:move_to_node(next_node, graph)
        end

        if #ant.path == #nodes and ant.total_distance < best_distance then
            best_distance = ant.total_distance
            best_path = ant.path
        end
    end

    -- Обновление феромонов
    for i = 1, NUM_ANTS do
        local ant = ants[i]

        local delta = Q / ant.total_distance

        for j = 1, #ant.path - 1 do
            local edge = graph[ant.path[j]][ant.path[j + 1]]
            edge.pheromone = P * edge.pheromone + delta
        end
    end

    print(string.format("[main] Iteration %d/%d complete (%.2fs)", iter, NUM_ITERS, os.clock() - iterStartTime))
    print(string.format("[main] Best distance: %d", best_distance))
end

-- Выводим лучший найденный путь и его длину
print()
print("Best path:")
print(table.concat(best_path, " "))
print("---")
print("Total length: ", best_distance)
print(string.format("Execution time: %.2fs", os.clock() - startTime))
