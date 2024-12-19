local program = { ip = 1 }

while true do
    local character = io.read(1)
    if not character then break end
    if string.match(character, "[+%-<>,%.%[%]]") then
        program[#program + 1] = character
    end
end

local memory = { current = 1 }

for i = 1, 30000 do
    memory[i] = 0
end

while program[program.ip] do
    local command = program[program.ip]
    if command == "+" then
        memory[memory.current] = (memory[memory.current] + 1) % 256
        program.ip = program.ip + 1
    elseif command == "-" then
        memory[memory.current] = (memory[memory.current] - 1) % 256
        program.ip = program.ip + 1
    elseif command == "<" then
        memory.current = (memory.current - 1) % 30000
        program.ip = program.ip + 1
    elseif command == ">" then
        memory.current = (memory.current + 1) % 30000
        program.ip = program.ip + 1
    elseif command == "[" then
        if memory[memory.current] == 0 then
            local depth = 1
            while program[program.ip] and depth > 0 do
                program.ip = program.ip + 1
                if program[program.ip] == "[" then
                    depth = depth + 1
                elseif program[program.ip] == "]" then
                    depth = depth - 1
                end
            end
        end
        program.ip = program.ip + 1
    elseif command == "]" then
        local depth = 1
        while program[program.ip] and depth > 0 do
            program.ip = program.ip - 1
            if program[program.ip] == "]" then
                depth = depth + 1
            elseif program[program.ip] == "[" then
                depth = depth - 1
            end
        end
    elseif command == "." then
        io.write(string.char(memory[memory.current]))
        program.ip = program.ip + 1
    elseif command == "," then
        memory[memory.current] = string.byte(io.read(1))
        program.ip = program.ip + 1
    end
end
