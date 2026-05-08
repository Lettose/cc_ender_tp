local pos = term.setCursorPos
local cls = term.clear
local box = paintutils.drawFilledBox
local outline = paintutils.drawBox
local line = paintutils.drawLine 
local tCol = term.setTextColor
local bCol = term.setBackgroundColor
local rsget = rs.getAnalogInput
local rsset = rs.setAnalogOutput
 
printRate = 60

x,y = term.getSize()
curr_state = 0
tp_state = {
    tp1 = nil,
    tp2 = nil,
    tp3 = nil
}

tp_protocol = "tp_server"
 
peripheral.find("modem",rednet.open)

function init()
    local user_data = {
        username = nil,
        tp1 = nil,
        tp2 = nil,
        tp3 = nil,
    }
    local filename = "user_data.txt"

    if fs.exists(filename) then
        user_data = loadData()
        textutils.slowWrite("User Data Loaded from File.",printRate) 
    else
        textutils.slowWrite("Enter Your User: ",printRate)
        user_data.username = read()
        
        saveData(user_data)
        textutils.slowWrite("Saved to ./"..filename.."\n",printRate)
    end
    os.setComputerLabel(user_data.username)
    os.sleep(1)

    tp_protocol = tp_protocol .. "_" ..string.lower(user_data.username)
end

function checkValidTP()
    while true do
        local user_data = loadData()

        if user_data.tp1 then
            if not rednet.lookup(tp_protocol,user_data.tp1) then
                tp_state.tp1 = "not_avail"
            else
                tp_state.tp1 = "avail"
            end
        else
            tp_state.tp1 = nil
        end

        if user_data.tp2 then
            if not rednet.lookup(tp_protocol,user_data.tp2) then
                tp_state.tp2 = "not_avail"
            else
                tp_state.tp2 = "avail"
            end
        else
            tp_state.tp2 = nil
        end

        if user_data.tp3 then
            if not rednet.lookup(tp_protocol,user_data.tp3) then
                tp_state.tp3 = "not_avail"
            else
                tp_state.tp3 = "avail"
            end
        else
            tp_state.tp3 = nil
        end

        if curr_state == 0 then drawHomeMenu() end
        os.sleep(0.5)
    end
end

function saveData(data)
    local file = fs.open("user_data.txt", "w")
    
    local serializedData = textutils.serialize(data) 
    file.write(serializedData)
    file.close()
end

function loadData()
    if not fs.exists("user_data.txt") then return nil end
    
    local file = fs.open("user_data.txt", "r")
    local content = file.readAll()
    file.close()
    
    return textutils.unserialize(content)
end

function sendRequest(tp_server,user)
    local server_id = rednet.lookup(tp_protocol,tp_server)
    rednet.send(server_id,user,"tp_request")
end
 
function drawEntry(height,bcolor)
    bcolor = bcolor or colors.gray

    box(8,height,x-8,height+3,bcolor)
    line(8,height,x-8,height,colors.lightGray)
    
    pos(x-9,height)
    tCol(colors.gray)
    bCol(colors.lightGray)
    write("x")
end

function drawConfirmMenu(location)
    pos(1,1)
    box(1,1,x,y,colors.black) -- Background

    box(6,(y/2)-3,x-6,(y/2)+3,colors.gray)
    line(6,(y/2)-3,x-6,(y/2)-3,colors.lightGray)

    tCol(colors.orange)    
    bCol(colors.gray)
    centerPrint("TP "..location,(y/2)-1,20)

    tCol(colors.lightGray)    
    bCol(colors.gray)
    centerPrint("Are you sure?",(y/2),20)

    box(9,(y/2)+2,11,(y/2)+2,colors.red)
    box(15,(y/2)+2,17,(y/2)+2,colors.green)

    pos(10,(y/2)+2)
    tCol(colors.white)    
    bCol(colors.red)
    write("x")

    pos(16,(y/2)+2)
    tCol(colors.white)    
    bCol(colors.green)
    write("o")
end

function centerPrint(printstr,height,sub_len)
    sub_len = sub_len or 9

    printstr = string.sub(printstr,1,sub_len)
    local str_len = string.len(printstr)

    pos(math.ceil((x-str_len)/2),height)
    write(printstr)
end

function drawHomeMenu()
    local user_data = loadData()
    local printstr = ""
    local bcolor

    pos(1,1)
    box(1,1,x,y,colors.black) -- Background
 
    tCol(colors.orange)
    bCol(colors.black)
    centerPrint("TP Menu",3)

    if not user_data.tp1 then
        drawEntry(5)
        tCol(colors.lightGray)
        bCol(colors.gray)
        printstr = "[Unset]"
    else
        printstr = user_data.tp1
        if tp_state.tp1 == "not_avail" then
            bcolor = colors.red
            drawEntry(5,bcolor)
            tCol(colors.white)
            bCol(colors.red)
        elseif tp_state.tp1 == "avail" then
            bcolor = colors.green
            drawEntry(5,bcolor)
            tCol(colors.white)
            bCol(colors.green)
        else
            drawEntry(5)
            tCol(colors.lightGray)
            bCol(colors.gray)
        end
    end
    centerPrint(printstr,7)

    if not user_data.tp2 then
        drawEntry(10)
        tCol(colors.lightGray)
        bCol(colors.gray)
        printstr = "[Unset]"
    else
        printstr = user_data.tp2
        if tp_state.tp2 == "not_avail" then
            bcolor = colors.red
            drawEntry(10,bcolor)
            tCol(colors.white)
            bCol(colors.red)
        elseif tp_state.tp2 == "avail" then
            bcolor = colors.green
            drawEntry(10,bcolor)
            tCol(colors.white)
            bCol(colors.green)
        else
            drawEntry(10)
            tCol(colors.lightGray)
            bCol(colors.gray)
        end
    end
    centerPrint(printstr,12)

    if not user_data.tp3 then
        drawEntry(15)
        tCol(colors.lightGray)
        bCol(colors.gray)
        printstr = "[Unset]"
    else
        printstr = user_data.tp3
        if tp_state.tp3 == "not_avail" then
            bcolor = colors.red
            drawEntry(15,bcolor)
            tCol(colors.white)
            bCol(colors.red)
        elseif tp_state.tp3 == "avail" then
            bcolor = colors.green
            drawEntry(15,bcolor)
            tCol(colors.white)
            bCol(colors.green)
        else
            drawEntry(15)
            tCol(colors.lightGray)
            bCol(colors.gray)
        end
    end
    centerPrint(printstr,17)
end

function homeMenuLoop()
    drawHomeMenu()
    while true do 
        local event, button, mx, my = os.pullEvent()
 
        if event == "mouse_click" then 
            curr_state = 1
            if mx >= 8 and mx <= x-8 and my >= 6 and my <= 8 and button == 1 then
                local user_data = loadData()

                if not user_data.tp1 then 

                    box(1,1,x,y,colors.black)
                    pos(1,1)
                    tCol(colors.orange)
                    bCol(colors.black)

                    textutils.slowWrite("Enter TP Name \n[max 9 chars]: ")
                    tCol(colors.white)
                    user_data.tp1 = string.sub(read(),1,9)

                    saveData(user_data)
                elseif tp_state.tp1 == "avail" then
                    if confirmMenuLoop(user_data.tp1) then
                        sendRequest(user_data.tp1,user_data.username)
                    end
                end
            elseif mx >= x-10 and mx <= x-8 and my == 5 and button == 1 then
                local user_data = loadData()
                user_data.tp1 = nil

                saveData(user_data)
            elseif mx >= 8 and mx <= x-8 and my >= 11 and my <= 13 and button == 1 then
                local user_data = loadData()

                if not user_data.tp2 then 

                    box(1,1,x,y,colors.black)
                    pos(1,1)
                    tCol(colors.orange)
                    bCol(colors.black)

                    textutils.slowWrite("Enter TP Name \n[max 9 chars]: ")
                    tCol(colors.white)
                    user_data.tp2 = string.sub(read(),1,9)

                    saveData(user_data)
                elseif tp_state.tp2 == "avail" then
                    if confirmMenuLoop(user_data.tp2) then
                        sendRequest(user_data.tp2,user_data.username)
                    end
                end
            elseif mx >= x-10 and mx <= x-8 and my == 10 and button == 1 then
                local user_data = loadData()
                user_data.tp2 = nil

                saveData(user_data)
            elseif mx >= 8 and mx <= x-8 and my >= 16 and my <= 18 and button == 1 then
                local user_data = loadData()

                if not user_data.tp3 then 

                    box(1,1,x,y,colors.black)
                    pos(1,1)
                    tCol(colors.orange)
                    bCol(colors.black)

                    textutils.slowWrite("Enter TP Name \n[max 9 chars]: ")
                    tCol(colors.white)
                    user_data.tp3 = string.sub(read(),1,9)

                    saveData(user_data)
                elseif tp_state.tp3 == "avail" then
                    if confirmMenuLoop(user_data.tp3) then
                        sendRequest(user_data.tp3,user_data.username)
                    end
                end
            elseif mx >= x-10 and mx <= x-8 and my == 15 and button == 1 then
                local user_data = loadData()
                user_data.tp3 = nil

                saveData(user_data)
            end
            curr_state = 0
            drawHomeMenu()
        end
    end
end

function confirmMenuLoop(location)
    drawConfirmMenu(location)
    while true do 
        local event, button, mx, my = os.pullEvent()
 
        if event == "mouse_click" then 
            if mx >= 9 and mx <= 11 and my == (y/2)+2 and button == 1 then
                return false
            elseif mx >= 15 and mx <= 17 and my == (y/2)+2 and button == 1 then
                box(6,(y/2)-3,x-6,(y/2)+3,colors.gray)
                line(6,(y/2)-3,x-6,(y/2)-3,colors.lightGray)

                tCol(colors.lightGray)    
                bCol(colors.gray)
                centerPrint("Request",(y/2))
                centerPrint("Sent",(y/2)+1)
                os.sleep(2)
                return true
            end
        end
    end
end



function main()
    while true do
        if curr_state == 0 then
            cls()
            homeMenuLoop()
        end
    end
end

cls()
pos(1,1)
init()
parallel.waitForAll(main,checkValidTP)