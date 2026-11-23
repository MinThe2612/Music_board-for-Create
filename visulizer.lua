local gpu = peripheral.find("directgpu")

if not gpu then
    error("GPU not found")
end

print("GPU detected!")

sleep(0.2)

local ok, displayId = pcall(function()
    return gpu.autoDetectAndCreateDisplay()
end)

if not ok then
    print("Display error:", displayId)
    return
end

print("Display created:", displayId)

local info = gpu.getDisplayInfo(displayId)

print("Resolution:", info.pixelWidth, info.pixelHeight)

gpu.clear(displayId, 0, 0, 0)
gpu.drawText(displayId, "GPU ONLINE", 30, 30,
    0, 255, 255, "Arial", 24, "bold")
gpu.updateDisplay(displayId)
