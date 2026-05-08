local rsget = rs.getAnalogInput
local rsset = rs.setAnalogOutput
local tCol = term.setTextColor
local bCol = term.setBackgroundColor
local cls = term.clear

cls()
term.setCursorPos(1,1)

printRate = 60

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
    os.sleep(2)
    cls()
    term.setCursorPos(1,1)

    return server_data.servername,server_data.username
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

function tpServer(comp_label,user)
    rednet.host("tp_server",comp_label)
    print("Waiting for TP Request..")
    while true do
        local target_id,message,protocol = rednet.receive()
        
        if protocol == "tp_request" and target_id == os.getComputerID() and message == user then
            print("\nReceived TP Request.")

            rsset("front",0)
            os.sleep(2)
            rsset("front",15)
            
            print("TP Complete!")
        end
    end
end


tpServer(init())
