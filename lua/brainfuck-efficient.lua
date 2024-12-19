local program = {}

while true do
    local character = io.read(1)
    if not character then break end
    if string.match(character, "[+%-<>,%.%[%]]") then
        program[#program + 1] = character
    end
end

local optimizedProgram = {}
local depth = 0

for i = 1, #program do
    local command = program[i]
    local last = optimizedProgram[#optimizedProgram]
    local lastTag = last and last[1]

    if command == "+" then
        if lastTag == "change" then
            last[2] = last[2] + 1
            if last[2] == 0 then
                optimizedProgram[#optimizedProgram] = nil
            end
        else
            optimizedProgram[#optimizedProgram + 1] = { "change", 1 }
        end
    elseif command == "-" then
        if lastTag == "change" then
            last[2] = last[2] - 1
            if last[2] == 0 then
                optimizedProgram[#optimizedProgram] = nil
            end
        else
            optimizedProgram[#optimizedProgram + 1] = { "change", -1 }
        end
    elseif command == "<" then
        if lastTag == "shift" then
            last[2] = last[2] - 1
            if last[2] == 0 then
                optimizedProgram[#optimizedProgram] = nil
            end
        else
            optimizedProgram[#optimizedProgram + 1] = { "shift", -1 }
        end
    elseif command == ">" then
        if lastTag == "shift" then
            last[2] = last[2] + 1
            if last[2] == 0 then
                optimizedProgram[#optimizedProgram] = nil
            end
        else
            optimizedProgram[#optimizedProgram + 1] = { "shift", 1 }
        end
    elseif command == "[" then
        optimizedProgram[#optimizedProgram + 1] = { "loop" }
        depth = depth + 1
    elseif command == "]" then
        optimizedProgram[#optimizedProgram + 1] = { "end" }
        if depth > 0 then
            depth = depth - 1
        else
            print("unmatched ']'")
            return nil
        end
    elseif command == "." then
        optimizedProgram[#optimizedProgram + 1] = { "print" }
    elseif command == "," then
        optimizedProgram[#optimizedProgram + 1] = { "read" }
    end
end

if depth > 0 then
    print("unmatched '['")
    return nil
end

local luaProgram = [[local memory = { current = 1 }

for i = 1, 30000 do
    memory[i] = 0
end

]]

for _, command in ipairs(optimizedProgram) do
    if command[1] == "end" then
        depth = depth - 1
    end

    if command[1] == "change" then
        luaProgram = luaProgram ..
            string.rep("\t", depth) .. "memory[memory.current] = (memory[memory.current] + " .. command[2] .. ") % 256\n"
    elseif command[1] == "shift" then
        luaProgram = luaProgram ..
            string.rep("\t", depth) .. "memory.current = (memory.current + " .. command[2] - 1 .. ") % 30000 + 1\n"
    elseif command[1] == "loop" then
        luaProgram = luaProgram .. string.rep("\t", depth) .. "while memory[memory.current] ~= 0 do\n"
    elseif command[1] == "end" then
        luaProgram = luaProgram .. string.rep("\t", depth) .. "end\n"
    elseif command[1] == "print" then
        luaProgram = luaProgram .. string.rep("\t", depth) .. "io.write(string.char(memory[memory.current]))\n"
    elseif command[1] == "read" then
        luaProgram = luaProgram .. string.rep("\t", depth) .. "memory[memory.current] = string.byte(io.read(1))\n"
    end

    if command[1] == "loop" then
        depth = depth + 1
    end
end

load(luaProgram)()
