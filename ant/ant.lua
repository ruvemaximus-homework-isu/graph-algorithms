local Ant = {}
Ant.__index = Ant

local rand = math.random

function Ant:new(start_node)
    local instance = setmetatable({}, Ant)

    instance.path = { start_node }
    instance.visited = { [start_node] = true }
    instance.total_distance = 0

    return instance
end

-- Выбор следующего узла на основе вероятности
function Ant:choose_next_node(graph, ALPHA, BETA)
    local probabilities = {}
    local sum = 0
    local roads_from_node = graph[self:current_node()] or {}

    for neighbor, edge in pairs(roads_from_node) do
        if not self.visited[neighbor] then
            local probability = (edge.pheromone ^ ALPHA) * ((1 / edge.weight) ^ BETA)

            probabilities[neighbor] = probability
            sum = sum + probability
        end
    end

    -- Если нет доступных узлов, муравей застрял
    if sum == 0 then
        -- да простит нас муравей-бро
        return nil
    end

    -- Выбор узла по вероятностям
    local threshold = rand() * sum
    local cumulative_probability = 0

    for node, probability in pairs(probabilities) do
        cumulative_probability = cumulative_probability + probability
        if cumulative_probability >= threshold then
            return node
        end
    end
end

function Ant:current_node()
    return self.path[#self.path]
end

-- Перемещение к следующему узлу
function Ant:move_to_node(target_node, graph)
    self.total_distance = self.total_distance + graph[self:current_node()][target_node].weight
    self.path[#self.path + 1] = target_node
    self.visited[target_node] = true
end

return Ant
