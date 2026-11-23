
-- MUSIC VISUALIZER - SIMULATION MODE
-- CC:Tweaked + CC:DirectGPU

local gpu = peripheral.find("directgpu")

if not gpu then
    error("DirectGPU peripheral not found!")
end

local display = gpu.autoDetectAndCreateDisplay()
local info = gpu.getDisplayInfo(display)

local W = info.pixelWidth
local H = info.pixelHeight

local BAR_COUNT = 48
local BAR_GAP = 4
local phase = 0

-- Color palette
local BG = {8, 10, 20}
local CYAN = {0, 220, 255}
local PURPLE = {170, 60, 255}
local WHITE = {230, 240, 255}

local function lerp(a, b, t)
    return a + (b - a) * t
end

local function draw()
    gpu.clear(display, BG[1], BG[2], BG[3])

    -- Header
    gpu.drawText(
        display, "NOW PLAYING",
        30, 25, CYAN[1], CYAN[2], CYAN[3],
        "Arial", 18, "bold"
    )

    gpu.drawText(
        display, "SYNTHETIC AUDIO / SIMULATION",
        30, 52, 130, 140, 160,
        "Arial", 12, "plain"
    )

    -- Center audio rings
    local cx = W / 2
    local cy = H * 0.38

    local bass = (math.sin(phase * 1.7) + 1) / 2
    local radius = 35 + bass * 18

    gpu.drawCircle(display, cx, cy, radius + 12,
        PURPLE[1], PURPLE[2], PURPLE[3], false)

    gpu.drawCircle(display, cx, cy, radius,
        CYAN[1], CYAN[2], CYAN[3], false)

    gpu.drawCircle(display, cx, cy, 5 + bass * 8,
        WHITE[1], WHITE[2], WHITE[3], true)

    -- Waveform
    local points = {}
    local waveY = H * 0.68
    local amplitude = H * 0.045

    for i = 1, 100 do
        local x = (i - 1) * (W / 99)

        local y = waveY
            + math.sin(i * 0.18 + phase * 2) * amplitude
            + math.sin(i * 0.43 - phase) * amplitude * 0.3

        table.insert(points, {x, y})
    end

    gpu.drawPolylines(display, points,
        CYAN[1], CYAN[2], CYAN[3])

    -- Spectrum bars
    local totalGap = (BAR_COUNT - 1) * BAR_GAP
    local barWidth = (W - 60 - totalGap) / BAR_COUNT
    local maxHeight = H * 0.18
    local baseY = H - 45

    for i = 1, BAR_COUNT do
        local frequency = i / BAR_COUNT

        -- Simulated Bass / Mid / Treble
        local bassWave = math.sin(phase * 1.7 + i * 0.12)
        local midWave = math.sin(phase * 2.4 + i * 0.35)
        local highWave = math.sin(phase * 3.5 + i * 0.8)

        local value =
            math.abs(bassWave) * (1 - frequency) * 0.7
            + math.abs(midWave) * 0.4
            + math.abs(highWave) * frequency * 0.3

        local height = 8 + value * maxHeight

        local x = 30 + (i - 1) * (barWidth + BAR_GAP)
        local y = baseY - height

        local r = math.floor(lerp(CYAN[1], PURPLE[1], frequency))
        local g = math.floor(lerp(CYAN[2], PURPLE[2], frequency))
        local b = 255

        gpu.fillRect(
            display,
            x, y,
            barWidth, height,
            r, g, b
        )
    end

    -- Footer
    gpu.drawText(
        display, "BASS",
        30, H - 25, CYAN[1], CYAN[2], CYAN[3],
        "Arial", 11, "bold"
    )

    gpu.drawText(
        display, "MID",
        W / 2 - 15, H - 25, 150, 120, 255,
        "Arial", 11, "bold"
    )

    gpu.drawText(
        display, "TREBLE",
        W - 100, H - 25, PURPLE[1], PURPLE[2], PURPLE[3],
        "Arial", 11, "bold"
    )

    gpu.updateDisplay(display)
end

while true do
    phase = phase + 0.12
    draw()
    sleep(0.05)
end
