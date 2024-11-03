local File = {}
File.__index = File

local gmatch = string.gmatch

-- конструктор
function File:new(path)
    local instance = setmetatable({}, File)

    instance.path = path

    return instance
end

-- прочитаем граф
function File:read_as_graph()
    local buf = {}

    local file = io.open(self.path, "r")
    if file == nil then
        error(string.format("File '%s' does not exist", self.path))
    end

    local _ = file:read() -- пропустим первую строку с заголовком

    if file == nil then
        error("File contains only 1 line")
    end

    local graph = { nodesCount = 0 }

    for line in file:lines() do
        buf = {}

        for cell in gmatch(line, "[^\t]+") do
            table.insert(buf, cell)
        end

        if graph[buf[1]] == nil then
            graph[buf[1]] = {}
            graph.nodesCount = graph.nodesCount + 1
        end

        graph[buf[1]][buf[2]] = { weight = tonumber(buf[3]), pheromone = 1 }

        -- graph[buf[2]] = graph[buf[2]] or {}
        -- graph[buf[2]][buf[1]] = { weight = tonumber(buf[3]), pheromone = 1 }
    end

    return graph
end

return File
