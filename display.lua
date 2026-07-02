-- Layer 1 Hardware

local Hardware = {
    speaker = peripheral.find("speaker"),
    display = peripheral.wrap("top")
}

function Hardware.init()
    if not Hardware.speaker then
        error("Khong tim thay loa")
    end
end

function Hardware.playAudioChunk(buffer, volume)
    while not Hardware.speaker.playAudio(buffer, volume) do
        os.pullEvent("speaker_audio_empty")
    end
end

function Hardware.updateDisplay(status, title, artist, elapsedSeconds, totalTimeStr)
    if not Hardware.display then return end
    local w, h = Hardware.display.getSize()

    -- Hàm hỗ trợ xóa dòng và in giữa
    local function drawCentered(y, text)
        local cleanText = string.sub(text, 1, w)
        local x = math.max(1, math.floor((w - #cleanText) / 2) + 1)
        Hardware.display.setCursorPos(1, y)
        Hardware.display.write(string.rep(" ", w))
        Hardware.display.setCursorPos(x, y)
        Hardware.display.write(cleanText)
    end

    -- Hàm vẽ đường kẻ viền
    local function drawBorder(y, leftChar, midChar, rightChar)
        local line = leftChar .. string.rep(midChar, w - 2) .. rightChar
        Hardware.display.setCursorPos(1, y)
        Hardware.display.write(line)
    end


    drawBorder(1, "+", "-", "+")
    
    local statusText = string.upper(status)
    local padding = math.floor((w - 2 - #statusText) / 2)
    local leftPad = string.rep(" ", padding)
    local rightPad = string.rep(" ", w - 2 - #statusText - padding)
    
    Hardware.display.setCursorPos(1, 2)
    Hardware.display.write("|" .. leftPad .. statusText .. rightPad .. "|")
    
    drawBorder(3, "+", "-", "+")


    drawCentered(5, title)
    drawCentered(6, artist)


    local timeDisplay = "--:-- / --:--"
    local progress = 0

    if elapsedSeconds then
        local eM = math.floor(elapsedSeconds / 60)
        local eS = math.floor(elapsedSeconds % 60)
        
        if totalTimeStr and totalTimeStr ~= "--:--" then
            timeDisplay = string.format("%02d:%02d / %s", eM, eS, totalTimeStr)
            
            local tM, tS = string.match(totalTimeStr, "(%d+):(%d+)")
            if tM and tS then
                local totalSecs = tonumber(tM) * 60 + tonumber(tS)
                if totalSecs > 0 then
                    progress = elapsedSeconds / totalSecs
                    if progress > 1 then progress = 1 end
                end
            end
        else
            timeDisplay = string.format("%02d:%02d / --:--", eM, eS)
        end
    end


    drawCentered(8, "[ " .. timeDisplay .. " ]")


    if h >= 10 then
        local barWidth = w - 4
        local fillCount = math.floor(progress * barWidth)
        local emptyCount = barWidth - fillCount
        
        local fillChar = "#"
        local emptyChar = "-"
        
        local bar = "[" .. string.rep(fillChar, fillCount) .. string.rep(emptyChar, emptyCount) .. "]"
        drawCentered(9, bar)
    end


    local vnTime = os.date("%H:%M:%S")
    if vnTime then
        local clockStr = "Time: " .. vnTime
        Hardware.display.setCursorPos(1, h)
        Hardware.display.write(string.rep(" ", w))
        Hardware.display.setCursorPos(math.max(1, w - #clockStr + 1), h)
        Hardware.display.write(clockStr)
    end
end


local API_URL = "https://ipod-2to6magyna-uc.a.run.app/?v=2.1"
local AudioService = {
    decoder = require("cc.audio.dfpwm").make_decoder(),
    volume = 1.5,
    chunkSize = 16 * 1024 - 4
}

function AudioService.parseArtistData(rawArtist)
    local timeStr = string.match(rawArtist, "(%d+:%d+)")
    if timeStr then
        local m, s = string.match(timeStr, "(%d+):(%d+)")
        local formattedTime = string.format("%02d:%02d", tonumber(m), tonumber(s))
        local cleanArtist = string.gsub(rawArtist, timeStr, "")
        cleanArtist = string.match(cleanArtist, "^%s*(.-)%s*$")
        return cleanArtist, formattedTime
    end
    return rawArtist, "--:--"
end

function AudioService.search(query)
    local searchUrl = API_URL .. "&search=" .. textutils.urlEncode(query)
    local response = http.get(searchUrl)
    if response then
        local data = textutils.unserialiseJSON(response.readAll())
        response.close()
        return data
    end
    return nil
end

function AudioService.getStreamHandle(id)
    local url = API_URL .. "&id=" .. textutils.urlEncode(id)
    http.request({url = url, binary = true})
    
    while true do
        local event, reqUrl, handle = os.pullEvent()
        if event == "http_success" and reqUrl == url then
            handle.read(4)
            return handle
        elseif event == "http_failure" and reqUrl == url then
            return nil
        end
    end
end


local function main()
    Hardware.init()
    
    while true do
        term.clear()
        term.setCursorPos(1, 1)
        print("=== SIMPLE TERMINAL PLAYER ===")
        print("Nhap ten bai hat (hoac de trong de thoat):")
        write("> ")
        local query = read()
        
        if query == "" then break end
        
        print("Dang tim kiem...")
        local results = AudioService.search(query)
        
        if not results or #results == 0 then
            print("Khong tim thay ket qua!")
            sleep(1.5)
        else
            print("\nKet qua:")
            local maxLimit = math.min(#results, 5)
            for i = 1, maxLimit do
                print(string.format("[%d] %s - %s", i, results[i].name, results[i].artist))
            end
            
            write("\nChon so (1-" .. maxLimit .. "): ")
            local choice = tonumber(read())
            
            if choice and choice >= 1 and choice <= maxLimit then
                local song = results[choice]
                local cleanArtist, totalTime = AudioService.parseArtistData(song.artist)
                local cleanTitle = song.name
                
                print("Dang tai luong am thanh...")
                if Hardware.display then Hardware.display.clear() end
                Hardware.updateDisplay("Loading...", cleanTitle, cleanArtist, 0, totalTime)
                
                local handle = AudioService.getStreamHandle(song.id)
                if not handle then
                    print("Loi ket noi mang!")
                    Hardware.updateDisplay("Error", cleanTitle, cleanArtist, 0, totalTime)
                    sleep(2)
                else
                    print("Dang phat: " .. cleanTitle)
                    print("Nhan 'Ctrl + T' de dung chuong trinh neu can.")
                    
                    local startTime = os.clock()
                    
                    -- Vòng lặp chỉ kết thúc khi mạng bị ngắt (chunk == nil)
                    while true do
                        local chunk = handle.read(AudioService.chunkSize)
                        if not chunk then break end
                        
                        local elapsedSeconds = os.clock() - startTime
                        local buffer = AudioService.decoder(chunk)
                        
                        Hardware.updateDisplay("Playing", cleanTitle, cleanArtist, elapsedSeconds, totalTime)
                        Hardware.playAudioChunk(buffer, AudioService.volume)
                    end
                    
                    handle.close()
                    Hardware.updateDisplay("Finished", cleanTitle, cleanArtist, os.clock() - startTime, totalTime)
                    print("\nDa phat xong / Mat ket noi luong stream!")
                    sleep(2)
                end
            end
        end
    end
    
    if Hardware.display then Hardware.display.clear() end
    Hardware.updateDisplay("Offline", "Waiting for input", "", nil, nil)
    print("Tam biet!")
end

main()