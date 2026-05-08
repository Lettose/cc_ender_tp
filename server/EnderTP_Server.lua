local pos = term.setCursorPos
local getPos = term.getCursorPos
local cls = term.clear
local box = paintutils.drawFilledBox
local outline = paintutils.drawBox
local line = paintutils.drawLine 
local tCol = term.setTextColor
local bCol = term.setBackgroundColor
local rsget = rs.getAnalogInput
local rsset = rs.setAnalogOutput

cls()
term.setCursorPos(1,1)

printRate = 60
tp_protocol = "tp_server"
curr_state = 0
x,y = term.getSize()

peripheral.find("modem",rednet.open)
rsset("front",15)

function init()
    local server_data = {
        username = nil,
        servername = nil
    }
    local filename = "server_data.txt"

    if fs.exists(filename) then
        server_data = loadData()
        textutils.slowWrite("Data Loaded from File.",printRate) 
    else
        tCol(colors.orange)
        textutils.slowWrite("Enter The TP Name: ",printRate)
        tCol(colors.white)
        server_data.servername = read()

        tCol(colors.orange)
        textutils.slowWrite("Enter Your User: ",printRate)
        tCol(colors.white)
        server_data.username = read()
        
        saveData(server_data)
        textutils.slowWrite("Saved to ./"..filename.."\n",printRate)
    end
    os.sleep(0.5)
    cls()
    term.setCursorPos(1,1)

    tp_protocol = tp_protocol .. "_" ..string.lower(server_data.username)
    return
end

function saveData(data)
    local file = fs.open("server_data.txt", "w")
    
    local serializedData = textutils.serialize(data) 
    file.write(serializedData)
    file.close()
end

function loadData()
    if not fs.exists("server_data.txt") then return nil end
    
    local file = fs.open("server_data.txt", "r")
    local content = file.readAll()
    file.close()
    
    return textutils.unserialize(content)
end

function tpServer()
    local server_data = loadData()
    rednet.host(tp_protocol,server_data.servername)
    while true do
        local pos_x,pos_y

        pos(2,3)
        tCol(colors.white)
        bCol(colors.black)
        write("Listening for TP Requests..\n\n")

        local sender_id,message,protocol = rednet.receive()
        if protocol == "tp_request" and message == server_data.username then
            pos_x,pos_y = getPos()
            pos(pos_x+1,pos_y)
            write("Received TP Request From: "..sender_id.."\n")

            rsset("front",0)
            os.sleep(2)
            rsset("front",15)
            
            pos_x,pos_y = getPos()
            pos(pos_x+1,pos_y)
            write("TP Complete!\n")
            
            os.sleep(2)
            drawHomeMenu()
        end
    end
end

function centerPrint(printstr,height,sub_len)
    sub_len = sub_len or 9

    printstr = string.sub(printstr,1,sub_len)
    local str_len = string.len(printstr)

    pos(math.ceil((x-str_len)/2),height)
    write(printstr)
end

function drawHomeMenu()
    local printstr = {
        p1 = nil,
        p2 = nil
    }
    local server_data = loadData()
    pos(1,1)
    box(1,1,x,y,colors.black) -- Background

    outline(1,1,x,y,colors.gray)
    box(1,(y/1.5),x,y,colors.gray)

    box((x/1.3)-5,y/1.2-1,(x/1.3)+5,(y/1.2)+1,colors.red)
    printstr.p1 = "RESET"
    pos((x/1.3)-math.floor((string.len(printstr.p1)/2)),(y/1.2))
    tCol(colors.white)
    bCol(colors.red)
    write(printstr.p1)

    printstr.p1 = "Server Info"
    pos((x/4)-math.floor((string.len(printstr.p1)/2)),(y/1.2)-2)
    tCol(colors.lightGray)
    bCol(colors.gray)
    write(printstr.p1)

    printstr.p1 = "TP Name: "
    printstr.p2 = server_data.servername
    pos((x/4)-math.floor((string.len(printstr.p1..printstr.p2)/2)),(y/1.2))
    tCol(colors.orange)
    bCol(colors.gray)
    write(printstr.p1)
    tCol(colors.white)
    write(printstr.p2)

    printstr.p1 = "User: "
    printstr.p2 = server_data.username
    pos((x/4)-math.floor((string.len(printstr.p1..printstr.p2)/2)),(y/1.2)+1)
    tCol(colors.orange)
    bCol(colors.gray)
    write(printstr.p1)
    tCol(colors.white)
    write(printstr.p2)
end

function drawConfirmMenu()
    pos(1,1)
    box(1,1,x,y,colors.black) -- Background

    box((x/2)-7,(y/2)-2,(x/2)+7,(y/2)+3,colors.gray)
    line((x/2)-7,(y/2)-2,(x/2)+7,(y/2)-2,colors.lightGray)

    tCol(colors.lightGray)    
    bCol(colors.gray)
    centerPrint("Are you sure?",(y/2),20)

    box((x/2)-5,(y/2)+2,(x/2)-3,(y/2)+2,colors.red)
    box((x/2)+3,(y/2)+2,(x/2)+5,(y/2)+2,colors.green)

    pos((x/2)-4,(y/2)+2)
    tCol(colors.white)    
    bCol(colors.red)
    write("x")

    pos((x/2)+4,(y/2)+2)
    tCol(colors.white)    
    bCol(colors.green)
    write("o")
end

function homeMenuLoop(server_data)
    while true do
        local event, button, mx, my = os.pullEvent()
 
        if event == "mouse_click" then 
            if mx >= (x/1.3)-6 and mx <= (x/1.3)+5 and my >= (y/1.2)-2 and my <= (y/1.2)+1 and button == 1 then
               curr_state = 1
               break
            end
        end
    end
end

function confirmMenuLoop()
    drawConfirmMenu()
    while true do
        local event, button, mx, my = os.pullEvent()
 
        if event == "mouse_click" then 
            if mx >= (x/2)-6 and mx <= (x/2)-3 and my == math.floor((y/2)+2) and button == 1 then
               curr_state = 0
               break
            elseif mx >= (x/2)+2 and mx <= (x/2)+5 and my == math.floor((y/2)+2) and button == 1 then
               local filename = "server_data.txt"
               fs.delete(filename)
               os.reboot()
               break
            end
        end
    end
end


function main()
    init()
    while true do
        if curr_state == 0 then
            drawHomeMenu()
            parallel.waitForAny(tpServer,homeMenuLoop)
        elseif curr_state == 1 then
            confirmMenuLoop()
        end
    end
end

main()