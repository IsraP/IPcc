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

    turtle.select(2)
    turtle.dig()

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
    if BlocksWalked < ChunkSize then
        turtle.forward()
        BlocksWalked = BlocksWalked + 1
    else
        RowsCompleted = RowsCompleted + 1
        if tonumber(RowsCompleted) == tonumber(ChunkSize) then
            DescendToNextLayer()
            Descending = true
        end
        
        BlocksWalked = 0

        if FacingRight then
            turtle.turnRight()
            if turtle.detect() then turtle.dig() end

            if not Descending
            then turtle.forward()
            end

            turtle.turnRight()
            if turtle.detect() then turtle.dig() end
        else
            turtle.turnLeft()
            if turtle.detect() then turtle.dig() end

            if not Descending
            then turtle.forward()
            end

            turtle.turnLeft()
            if turtle.detect() then turtle.dig() end
        end

        FacingRight = not FacingRight
        Descending = false
    end
end

function DescendToNextLayer()
    turtle.digDown()
    turtle.down()

    BlocksWalked = 0
    RowsCompleted = 0
    FacingRight = not FacingRight
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
        BlocksWalked = 0
        RowsCompleted = 0
        FacingRight = true
        ChunkSize = tonumber(size)
        CanKeepGoing = true
        Descending = false

        rednet.broadcast("Understood, boss. Mining a " .. size .. "x" .. size .. " area", "digGreeting")

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