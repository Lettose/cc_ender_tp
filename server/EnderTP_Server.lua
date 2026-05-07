local rsget = rs.getAnalogInput
local rsset = rs.setAnalogOutput
local cls = term.clear

comp_label = "tp_host"
protocol = "tp_server"

os.setComputerLabel(comp_label)
peripheral.find("modem",rednet.open)
rednet.host(protocol,comp_label)

rsset("back",15)

function tpServer()
    while true do
        local target_id,message,protocol = rednet.receive()
        print("Recieved Message: ",target_id,message)
        
        if protocol == "tp_request" and message == true then
            print("Message is a Teleport Request")
            print("Triggering Teleport..")

            rsset("back",0)
            os.sleep(2)
            rsset("back",15)
            
            print("Done!")
        else
            print("Invalid Request")
        end
    end
end

cls()
tpServer()
