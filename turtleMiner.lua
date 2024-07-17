turtle.select(1)
turtle.refuel(1)

rednet.open("left")

function Dig()
    if turtle.detect() then
        if not turtle.dig() then
            if turtle.detectDown() then
                local success, data = turtle.inspectDown()
                if success and data.name == "minecraft:bedrock" then
                    return false
                end
            end
        end
    end

    return true
end


function CheckForSpace()
    for i = 1, 16 do
        if turtle.getItemCount(i) == 0 then
            return true
        end
    end

    turtle.select(2)
    turtle.place()

    for slot = 3, 16 do
        turtle.select(slot)

        local result = turtle.drop()

        if result == false
        then return false
        end
    end

    return true
end

function CheckForFuel()
    if turtle.getFuelLevel() == 1
    then
        turtle.select(1)

        if turtle.getItemCount() == 0
        then return false
        end

        turtle.refuel(1)
        return true
    end

    return true
end

function Move()
    turtle.forward()
    BlocksWalked = BlocksWalked + 1

    local mustResetBlocks = false

    if BlocksWalked == ChunkSize - 1
    then
        turtle.turnRight()
        mustResetBlocks = true
    end

    if BlocksWalked == BlocksForDescend
    then
        turtle.digDown()
        turtle.down()
    end

    if mustResetBlocks
    then BlocksWalked = 0
    end
end

function DoDig()
    while turtle.getFuelLevel() ~= 0 and CanKeepGoing do
        if not Dig()
        then
            rednet.broadcast("Done with digging!", "digStatus")
            return false
        end

        if not CheckForSpace()
        then
            rednet.broadcast("Chest is full!", "digStatus")
            return false
        end

        if not CheckForFuel()
        then
            rednet.broadcast("Out of fuel!", "digStatus")
            return false
        end

        Move()
    end
end

while true do
    local senderID, size, protocol = rednet.receive("dig")

    if protocol == "dig" and size then
        ChunkSize = size
        BlocksForDescend = ChunkSize * ChunkSize
        CanKeepGoing = true
        BlocksWalked = 0

        local status = DoDig()

        if not status
        then
            rednet.close()
            break
        end
    else
        print("No valid size received.")
    end
end