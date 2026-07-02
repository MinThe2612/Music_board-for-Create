
local CONFIG_FILE = "config.txt"
local myIndex = nil

local function loadIndex()
    if fs.exists(CONFIG_FILE) then
        local file = fs.open(CONFIG_FILE, "r")
        local content = file.readAll()
        file.close()

        return tonumber(content:match("%d+"))
    end
    return nil
end

myIndex = loadIndex()


if not myIndex or myIndex < 1 or myIndex > 15 then
    print("Loi: Khong tim thay index hop le trong " .. CONFIG_FILE)
    print("Vui long tao file '" .. CONFIG_FILE .. "' va ghi vao 1 con so tu 1 den 15.")
    print("Vi du: echo 5 > config.txt")
    return
end

rednet.open("bottom")
redstone.setAnalogOutput("back", 0)

print("=== NODE " .. myIndex .. " ===")
print("San sang nhan tin hieu tu Master...")

while true do
    local senderId, message, protocol = rednet.receive("EQ_DATA")
    
    if type(message) == "table" and message[myIndex] then
        local signal = message[myIndex]
        
        redstone.setAnalogOutput("back", signal)
    end
end
