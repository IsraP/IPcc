rednet.open("back")
local size = arg[1]

if size == nil then
    print("Please input a valid chunk size.")
    return
end

rednet.broadcast(size, "dig")

function ListenForUpdates()
    while true do
        local id, message, protocol = rednet.receive()

        if protocol == "digGreeting" then
            print("Greetings from Turtle " .. id .. ": " .. message)

        elseif protocol == "digStatus" then
            print("Update from Turtle " .. id .. ": " .. message)

            if message == "Chest is full!" or message == "Out of fuel!" or message == "Done with digging!" then
                rednet.close()
                break
            end
        end
    end
end

ListenForUpdates()