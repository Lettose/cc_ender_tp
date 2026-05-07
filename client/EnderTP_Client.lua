local cls = term.clear

peripheral.find("modem",rednet.open)
tp_server = rednet.lookup("tp_server","tp_host")

function tpClient()
    print("TP Request Sent")
    os.sleep(2)
    rednet.send(tp_server,true,"tp_request")
    
    os.sleep(5)
    cls()
    term.setCursorPos(1,1)
end

cls()
tpClient()
