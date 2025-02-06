local Ant   = {}
Ant.__index = Ant

local rand  = math.random

function Ant:new(start_node)
    local instance = setmetatable({}, Ant)

    instance.path = { start_node }
    instance.visited = { [start_node] = true }
    instance.total_distance = 0

    return instance
end

function Ant:get_neighbors(graph)
    return graph[self.path[#self.path]] or {}
end

-- получение суммы всех вероятностей про перехода
function Ant:get_neighbor_probabilities(graph, ALPHA, BETA)
    local probabilities = {}
    local sum = 0

    for node, edge in pairs(self:get_neighbors(graph)) do
        if not self.visited[node] then
            local probability = (edge.pheromone ^ ALPHA) * ((1 / edge.weight) ^ BETA)

            probabilities[node] = probability
            sum = sum + probability
        end
    end

    return (sum > 0 and { sum, probabilities } or nil)
end

-- выбор узла по вероятностям
function Ant:choice_random_neighbor(sum, probabilities)
    local threshold = rand() * sum
    local cumulative_probability = 0

    for node, probability in pairs(probabilities) do
        cumulative_probability = cumulative_probability + probability
        if cumulative_probability >= threshold then
            return node
        end
    end

    error("Failed to get node to go to :(")
end

-- выбор следующего узла на основе вероятности
function Ant:choose_next_node(graph, ALPHA, BETA)
    local probabilities = self:get_neighbor_probabilities(graph, ALPHA, BETA)

    -- если нет доступных узлов, муравей застрял
    -- да простит нас муравей бро, скипнем его
    if not probabilities then
        return nil
    end

    return self:choice_random_neighbor(probabilities[1], probabilities[2])
end

-- Перемещение к следующему узлу
function Ant:move_to_node(target_node, graph)
    local edge_to_target = self:get_neighbors(graph)[target_node]

    if not edge_to_target then
        return nil
    end

    self.total_distance = self.total_distance + edge_to_target.weight
    self.path[#self.path + 1] = target_node
    self.visited[target_node] = true

    return true
end

return Ant
