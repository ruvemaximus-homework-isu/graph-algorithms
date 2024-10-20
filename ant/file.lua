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
    local nodes = {}

    if not self:file_exists(path) then
        return false
    end

    local gm = string.gmatch

    for line in io.lines(path) do
        nodes[#nodes + 1] = {}
        for n in gm(line, "[^\t]+") do
            table.insert(nodes[#nodes], n)
        end
    end

    return nodes
end

return File
