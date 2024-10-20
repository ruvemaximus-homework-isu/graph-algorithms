local nodes = {}
local File = require("file")

if not File.read_graph("input.txt") then
    print("File input.txt does not exists!")
    os.exit(1)
end

for line = 1,#nodes do
    print(nodes[line][3])
end
