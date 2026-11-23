
local gpu = peripheral.find("directgpu")

if not gpu then
    print("ERROR: Cannot find DirectGPU")
    return
end

print("GPU detected!")

local monitor = gpu.autoDetectMonitor()
print("Detected monitor:", monitor)

local display = gpu.autoDetectAndCreateDisplay()

if not display then
    print("ERROR: Cannot create display")
    return
end

print("Display ID:", display)

local info = gpu.getDisplayInfo(display)

print("Resolution:", info.pixelWidth, "x", info.pixelHeight)

gpu.clear(display, 10, 15, 30)

gpu.drawText(
    display,
    "DIRECTGPU CONNECTED!",
    30, 30,
    0, 255, 255,
    "Arial", 24, "bold"
)

gpu.fillRect(display, 30, 80, 200, 8, 0, 220, 255)

gpu.updateDisplay(display)

print("Test completed!")
