local File = {}
File.__index = File

-- проверим, что файл существует
function File:file_exists(path)
    local f = io.open(path, "rb")
    if f then f:close() end
    return f ~= nil
end

-- прочитаем граф
function File:read_graph(path)
    local graph = {}

    if not self:file_exists(path) then
        return false
    end

    local gmatch = string.gmatch

    local buf = {}

    for line in io.lines(path) do
        buf = {}

        for n in gmatch(line, "[^\t]+") do
            table.insert(buf, tonumber(n))
        end
        local edge = { buf[1], buf[2] }

        table.sort(edge)
        graph[edge] = { buf[3], }
    end

    return graph
end

return File
