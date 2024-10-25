local input_file = arg[1]

local File       = require("file")

local ALPHA      = 1    -- важность феромонов
local BETA       = 1    -- важность весов
local Q          = 4
local P          = 0.64 -- процент остающихся феромонов

if not input_file then
    print("Usage: lua main.lua <input_file>")
    os.exit(1)
end

-- Создаём экземпляр класса File
local file = setmetatable({}, File)

if not file:file_exists(input_file) then
    print("File '" .. input_file .. "' does not exist!")
    os.exit(1)
end

local graph = file:read_graph(input_file)
