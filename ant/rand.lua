-- TODO этот файл для замены стандартной math.random

local rand  = assert(io.open('/dev/random', 'rb'))

local function generate_number(b, m)
    b = 1
    m = 1

    local n, s = 0, rand:read(b)

    for i = 1, s:len() do
        n = m * n + s:byte(i)
    end

    return n
end
