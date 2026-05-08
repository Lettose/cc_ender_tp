local rsget = rs.getAnalogInput
local rsset = rs.setAnalogOutput
local cls = term.clear

cls()
term.setCursorPos(1,1)

printRate = 35

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
        textutils.slowWrite("Enter The TP Name: ",printRate)
        server_data.servername = read()

        textutils.slowWrite("Enter Your User: ",printRate)
        server_data.username = read()
        
        saveData(server_data)
        textutils.slowWrite("Saved to ./"..filename.."\n",printRate)
    end
    os.setComputerLabel(server_data.servername)
    rednet.host("tp_request",server_data.servername)
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
    while true do
        textutils.slowWrite("Waiting for TP Request..\n\n",printRate)
        local target_id,message,protocol = rednet.receive()
        textutils.slowWrite("Recieved Message: "..target_id,printRate)
        
        if protocol == "tp_request" and message == comp_label then
            textutils.slowWrite("Message is a TP Request!\n",printRate)

            rsset("front",0)
            os.sleep(2)
            rsset("front",15)
            
            textutils.slowWrite("Done!\n",printRate)
        else
            textutils.slowWrite("Invalid Request\n",printRate)
        end
    end
end


tpServer(init())
