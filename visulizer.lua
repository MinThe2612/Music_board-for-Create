-- Khởi tạo modem ở mặt bottom
rednet.open("bottom")
print("=== MASTER VISUALIZER ===")
print("Dang phat tin hieu Mock Data...")

local step = 0

while true do
    local spectrum = {}
    step = step + 0.3 -- Tốc độ trôi của dải sóng
    
    for i = 1, 15 do
        -- Thuật toán Mock Data: Kết hợp sóng Sine (mượt) + Noise (nảy)
        -- i * 0.5 giúp sóng lệch pha nhau tạo hiệu ứng gợn
        local baseWave = (math.sin(step + (i * 0.5)) + 1) * 5 
        local noise = math.random(0, 5) 
        
        local amplitude = math.floor(baseWave + noise)
        
        -- Clamp giá trị trong dải an toàn của Redstone (0 - 15)
        if amplitude > 15 then amplitude = 15 end
        if amplitude < 0 then amplitude = 0 end
        
        table.insert(spectrum, amplitude)
    end
    
    -- Gửi mảng 15 giá trị tới toàn bộ mạng với nhãn "EQ_DATA"
    rednet.broadcast(spectrum, "EQ_DATA")
    
    -- Tốc độ làm tươi (Refresh Rate) ~ 10Hz (0.1s)
    sleep(0.1) 
end