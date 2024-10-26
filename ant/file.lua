local File = {}
File.__index = File

-- конструктор
function File:new(path)
    local instance = setmetatable({}, File)

    instance.path = path

    return instance
end

-- прочитаем граф
function File:read_as_graph()
    local gmatch = string.gmatch

    local buf = {}

    local file = io.open(self.path, "r")
    if file == nil then
        error("File '" .. self.path .. "' does not exist")
    end

    local _ = file:read() -- пропустим первую строку с заголовком

    if file == nil then
        error("File contains only 1 line")
    end

    local graph = {}

    for line in file:lines() do
        buf = {}

        for cell in gmatch(line, "[^\t]+") do
            table.insert(buf, cell)
        end

        graph[buf[1]] = graph[buf[1]] or {}
        graph[buf[1]][buf[2]] = { weight = tonumber(buf[3]), pheromone = 1 }
    end

    return graph
end

return File
