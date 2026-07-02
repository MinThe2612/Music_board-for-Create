-- Lấy tham số truyền vào từ dòng lệnh để biết mình là cột đèn số mấy
local args = {...}
local myIndex = tonumber(args[1])

-- Validate đầu vào
if not myIndex or myIndex < 1 or myIndex > 15 then
    print("Loi: Vui long nhap index (1-15).")
    print("Cach chay: node <so_thu_tu>")
    return
end

-- Khởi tạo phần cứng
rednet.open("bottom")
redstone.setAnalogOutput("top", 0)

print("=== NODE " .. myIndex .. " ===")
print("San sang nhan tin hieu tu Master...")

while true do
    -- Lắng nghe gói tin có nhãn "EQ_DATA"
    local senderId, message, protocol = rednet.receive("EQ_DATA")
    
    -- Kiểm tra tính hợp lệ của dữ liệu
    if type(message) == "table" and message[myIndex] then
        local signal = message[myIndex]
        
        -- Xuất tín hiệu cường độ đá đỏ lên mặt top (chỗ gắn đèn Redstone Lamp)
        redstone.setAnalogOutput("top", signal)
    end
end