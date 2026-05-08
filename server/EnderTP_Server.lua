local rsget = rs.getAnalogInput
local rsset = rs.setAnalogOutput
local cls = term.clear

cls()
term.setCursorPos(1,1)

printRate = 35

peripheral.find("modem",rednet.open)
rsset("front",15)

function tpServer(comp_label)
    while true do
        textutils.slowWrite("Waiting for TP Request..\n\n",printRate)
        local target_id,message,protocol = rednet.receive()
        textutils.slowWrite("Recieved Message: "..target_id..message.."\n",printRate)
        
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

function init()
    local cname
    local filename = "params.txt"

    if fs.exists(filename) then
        local file = fs.open(filename, "r")
        cname = file.readLine()
        file.close()
        textutils.slowWrite("TP Name Loaded from File: " ..cname.."\n",printRate) 
    else
        textutils.slowWrite("Enter TP Name: ",printRate)
        cname = read()

        local file = fs.open(filename, "w")
        file.writeLine(cname)
        file.close()

        textutils.slowWrite("Saved to ./"..filename.."\n",printRate)
    end

    os.sleep(2)

    cls()
    term.setCursorPos(1,1)
    
    os.setComputerLabel(comp_label)
    rednet.host("tp_request",cname)

    return cname
end


tpServer(init())
