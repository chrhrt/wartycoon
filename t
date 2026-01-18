local players = game:GetService("Players")
local lp = players.LocalPlayer
local workspace = game:GetService("Workspace")

local colors = {
    background = Color3.fromRGB(25, 25, 35),
    backgroundAlt = Color3.fromRGB(20, 20, 30),
    border = Color3.fromRGB(50, 50, 70),
    text = Color3.fromRGB(255, 255, 255),
    accent = Color3.fromRGB(0, 200, 83),
    success = Color3.fromRGB(0, 200, 83),
    inactive = Color3.fromRGB(150, 150, 150),
    sliderTrack = Color3.fromRGB(40, 40, 40),   
    sliderFill = Color3.fromRGB(255, 255, 255)
}

local hitboxActive = false
local guiVisible = true
local guiX = 50
local guiY = 50
local dragging = false
local dragOffsetX = 0
local dragOffsetY = 0
local protectOwnVehicles = true
local currentTab = "main"
local needsApply = false

local pendingSliderValues = {}

local vehicleCategories = {
    {
        name = "Boat",
        workspaceName = "Boat Workspace",
        size = 150,
        minSize = 4,
        maxSize = 300,
        defaultSize = 150
    },
    {
        name = "Vehicle", 
        workspaceName = "Vehicle Workspace",
        size = 150,
        minSize = 4,
        maxSize = 300,
        defaultSize = 150
    },
    {
        name = "Hovercraft",
        workspaceName = "Hovercraft Workspace",
        size = 150,
        minSize = 4,
        maxSize = 300,
        defaultSize = 150
    },
    {
        name = "Helicopter",
        workspaceName = "Helicopter Workspace",
        size = 150,
        minSize = 4,
        maxSize = 300,
        defaultSize = 150
    },
    {
        name = "Plane",
        workspaceName = "Plane Workspace",
        size = 150,
        minSize = 4,
        maxSize = 300,
        defaultSize = 150
    },
    {
        name = "Submarine",
        workspaceName = "Submarine Workspace",
        size = 150,
        minSize = 4,
        maxSize = 300,
        defaultSize = 150
    },
    {
        name = "Tank",
        workspaceName = "Tank Workspace",
        size = 150,
        minSize = 4,
        maxSize = 300,
        defaultSize = 150
    }
}

for i, category in ipairs(vehicleCategories) do
    pendingSliderValues[i] = category.size
end

local gui = Drawing.new("Square")
gui.Size = Vector2.new(280, 440)
gui.Color = colors.background
gui.Filled = true
gui.Visible = true

local border = Drawing.new("Square")
border.Size = Vector2.new(280, 2)
border.Color = colors.accent
border.Filled = true
border.Visible = true

local title = Drawing.new("Text")
title.Text = "HITBOX EXPANDER"
title.Size = 16
title.Color = colors.text
title.Visible = true
title.Outline = true
title.Font = Drawing.Fonts.UI

local status = Drawing.new("Text")
status.Text = "OFF"
status.Size = 14
status.Color = colors.inactive
status.Visible = true
status.Outline = true
status.Font = Drawing.Fonts.UI

local mainTabBtn = Drawing.new("Square")
mainTabBtn.Size = Vector2.new(125, 25)
mainTabBtn.Color = colors.accent
mainTabBtn.Filled = true
mainTabBtn.Visible = true

local mainTabText = Drawing.new("Text")
mainTabText.Text = "MAIN"
mainTabText.Size = 12
mainTabText.Color = colors.text
mainTabText.Visible = true
mainTabText.Outline = true
mainTabText.Font = Drawing.Fonts.UI

local slidersTabBtn = Drawing.new("Square")
slidersTabBtn.Size = Vector2.new(125, 25)
slidersTabBtn.Color = colors.border
slidersTabBtn.Filled = true
slidersTabBtn.Visible = true

local slidersTabText = Drawing.new("Text")
slidersTabText.Text = "SLIDERS"
slidersTabText.Size = 12
slidersTabText.Color = colors.text
slidersTabText.Visible = true
slidersTabText.Outline = true
slidersTabText.Font = Drawing.Fonts.UI

local toggleBtn = Drawing.new("Square")
toggleBtn.Size = Vector2.new(260, 35)
toggleBtn.Color = colors.inactive
toggleBtn.Filled = true
toggleBtn.Visible = true

local toggleText = Drawing.new("Text")
toggleText.Text = "CLICK TO ACTIVATE"
toggleText.Size = 14
toggleText.Color = colors.text
toggleText.Visible = true
toggleText.Outline = true
toggleText.Font = Drawing.Fonts.UI

local protectBtn = Drawing.new("Square")
protectBtn.Size = Vector2.new(260, 25)
protectBtn.Color = protectOwnVehicles and colors.success or colors.border
protectBtn.Filled = true
protectBtn.Visible = true

local protectText = Drawing.new("Text")
protectText.Text = "PROTECT OWN VEHICLES"
protectText.Size = 14
protectText.Color = colors.text
protectText.Visible = true
protectText.Outline = true
protectText.Font = Drawing.Fonts.UI

local infoText = Drawing.new("Text")
infoText.Text = "ignores your vehicles"
infoText.Size = 12
infoText.Color = colors.inactive
infoText.Visible = true
infoText.Outline = true
infoText.Font = Drawing.Fonts.UI

local stats = Drawing.new("Text")
stats.Text = ""
stats.Size = 14
stats.Color = colors.inactive
stats.Visible = true
stats.Outline = true
stats.Font = Drawing.Fonts.UI

local applyBtn = Drawing.new("Square")
applyBtn.Size = Vector2.new(260, 35)
applyBtn.Color = colors.inactive
applyBtn.Filled = true
applyBtn.Visible = false

local applyText = Drawing.new("Text")
applyText.Text = "APPLY CHANGES"
applyText.Size = 14
applyText.Color = colors.text
applyText.Visible = false
applyText.Outline = true
applyText.Font = Drawing.Fonts.UI

local sliderElements = {}
for i, category in ipairs(vehicleCategories) do
    local elements = {
        nameText = Drawing.new("Text"),
        valueText = Drawing.new("Text"),
        track = Drawing.new("Square"),
        fill = Drawing.new("Square"),
        handle = Drawing.new("Circle"),
        category = category,
        index = i,
        draggingHandle = false,
        lastMouseX = 0
    }
    
    elements.nameText.Text = category.name
    elements.nameText.Size = 12
    elements.nameText.Color = colors.text
    elements.nameText.Visible = false
    elements.nameText.Outline = true
    elements.nameText.Font = Drawing.Fonts.UI
    
    elements.valueText.Text = tostring(category.size)
    elements.valueText.Size = 12
    elements.valueText.Color = colors.text
    elements.valueText.Visible = false
    elements.valueText.Outline = true
    elements.valueText.Font = Drawing.Fonts.UI
    
    elements.track.Size = Vector2.new(150, 6)
    elements.track.Color = colors.sliderTrack
    elements.track.Filled = true
    elements.track.Visible = false
    
    elements.fill.Size = Vector2.new(0, 6)
    elements.fill.Color = colors.sliderFill
    elements.fill.Filled = true
    elements.fill.Visible = false
    
    elements.handle.Radius = 8
    elements.handle.Color = colors.accent
    elements.handle.Filled = true
    elements.handle.Visible = false
    elements.handle.NumSides = 32
    
    table.insert(sliderElements, elements)
end

local resetBtn = Drawing.new("Square")
resetBtn.Size = Vector2.new(260, 25)
resetBtn.Color = colors.border
resetBtn.Filled = true
resetBtn.Visible = false

local resetText = Drawing.new("Text")
resetText.Text = "RESET ALL TO DEFAULT"
resetText.Size = 14
resetText.Color = colors.text
resetText.Visible = false
resetText.Outline = true
resetText.Font = Drawing.Fonts.UI

local function updatePositions()
    gui.Position = Vector2.new(guiX, guiY)
    border.Position = Vector2.new(guiX, guiY)
    
    title.Position = Vector2.new(guiX + 10, guiY + 12)
    status.Position = Vector2.new(guiX + 220, guiY + 12)
    
    mainTabBtn.Position = Vector2.new(guiX + 10, guiY + 50)
    mainTabText.Position = Vector2.new(guiX + 50, guiY + 57)
    
    slidersTabBtn.Position = Vector2.new(guiX + 145, guiY + 50)
    slidersTabText.Position = Vector2.new(guiX + 180, guiY + 57)
    
    if currentTab == "main" then
        toggleBtn.Position = Vector2.new(guiX + 10, guiY + 85)
        toggleText.Position = Vector2.new(guiX + 60, guiY + 93)
        
        protectBtn.Position = Vector2.new(guiX + 10, guiY + 130)
        protectText.Position = Vector2.new(guiX + 45, guiY + 137)
        
        infoText.Position = Vector2.new(guiX + 10, guiY + 165)
        
        stats.Position = Vector2.new(guiX + 10, guiY + 185)
        
        applyBtn.Visible = false
        applyText.Visible = false
    elseif currentTab == "sliders" then
        applyBtn.Position = Vector2.new(guiX + 10, guiY + 85)
        applyText.Position = Vector2.new(guiX + 60, guiY + 93)
        
        for i, elements in ipairs(sliderElements) do
            local yPos = guiY + 130 + ((i-1) * 40)
            
            elements.nameText.Position = Vector2.new(guiX + 15, yPos + 5)
            
            local displayValue = pendingSliderValues[i] or elements.category.size
            elements.valueText.Text = tostring(displayValue)
            elements.valueText.Position = Vector2.new(guiX + 240, yPos + 5)
            
            elements.track.Position = Vector2.new(guiX + 60, yPos + 20)
            
            local currentSize = pendingSliderValues[i] or elements.category.size
            local fillWidth = ((currentSize - elements.category.minSize) / 
                            (elements.category.maxSize - elements.category.minSize)) * 150
            elements.fill.Position = Vector2.new(guiX + 60, yPos + 20)
            elements.fill.Size = Vector2.new(math.max(0, math.min(fillWidth, 150)), 6)
            
            local handleX = guiX + 60 + math.max(0, math.min(fillWidth, 150))
            elements.handle.Position = Vector2.new(handleX, yPos + 20)
        end
        
        resetBtn.Position = Vector2.new(guiX + 10, guiY + 410)
        resetText.Position = Vector2.new(guiX + 55, guiY + 417)
    end
end

local function getVehicleOwner(vehicle)
    local owner = vehicle:GetAttribute("Owner")
    if owner and typeof(owner) == "string" then return owner end
    for _, child in ipairs(vehicle:GetDescendants()) do
        local childOwner = child:GetAttribute("Owner")
        if childOwner and typeof(childOwner) == "string" then return childOwner end
    end
    return nil
end

local function resizeCollisionParts(vehicle, size)
    local resizedCount = 0
    for _, obj in ipairs(vehicle:GetDescendants()) do
        if obj:IsA("BasePart") then
            local nameLower = string.lower(obj.Name)
            if string.find(nameLower, "collision") or 
               string.find(nameLower, "hitbox") or
               obj.Name == "Collision" then
                
                if obj.Transparency == 1 then
                    obj.Size = Vector3.new(size, size, size)
                    resizedCount = resizedCount + 1
                end
            end
        end
        
        if obj:IsA("Folder") and string.lower(obj.Name):find("collision") then
            for _, part in ipairs(obj:GetChildren()) do
                if part:IsA("BasePart") then
                    if part.Transparency == 1 then
                        part.Size = Vector3.new(size, size, size)
                        resizedCount = resizedCount + 1
                    end
                end
            end
        end
    end
    return resizedCount
end

local function scanVehicles()
    local root = game.Workspace:FindFirstChild("Game Systems")
    if not root then return 0, 0 end
    
    local modified, total = 0, 0
    for _, category in ipairs(vehicleCategories) do
        local folder = root:FindFirstChild(category.workspaceName)
        if folder then
            for _, vehicle in ipairs(folder:GetChildren()) do
                total = total + 1
                local owner = getVehicleOwner(vehicle)
                local shouldProtect = protectOwnVehicles and owner == lp.Name
                
                if shouldProtect then
                    resizeCollisionParts(vehicle, 4)
                else
                    local resized = resizeCollisionParts(vehicle, category.size)
                    if resized > 0 and category.size > 4 then
                        modified = modified + 1
                    end
                end
            end
        end
    end
    
    return modified, total
end

local function updateSliderValue(elements, mouseX)
    local trackStartX = guiX + 60
    local trackEndX = trackStartX + 150
    
    local clampedX = math.clamp(mouseX, trackStartX, trackEndX)
    local relativeX = clampedX - trackStartX
    local percentage = relativeX / 150
    
    local newSize = math.floor(elements.category.minSize + 
        percentage * (elements.category.maxSize - elements.category.minSize))
    
    pendingSliderValues[elements.index] = newSize
    
    needsApply = true
    applyBtn.Color = colors.success
    applyText.Text = "APPLY CHANGES ✓"
end

local function applySliderChanges()
    for i, pendingValue in pairs(pendingSliderValues) do
        if vehicleCategories[i] then
            vehicleCategories[i].size = pendingValue
        end
    end
    
    pendingSliderValues = {}
    
    needsApply = false
    applyBtn.Color = colors.inactive
    applyText.Text = "APPLY CHANGES"
    
    if hitboxActive then
        scanVehicles()
    end
end

local function resetAllSliders()
    for i, category in ipairs(vehicleCategories) do
        pendingSliderValues[i] = category.defaultSize
    end
    
    needsApply = true
    applyBtn.Color = colors.success
    applyText.Text = "APPLY CHANGES ✓"
end

local function updateGUI()
    if currentTab == "main" then
        mainTabBtn.Color = colors.accent
        slidersTabBtn.Color = colors.border
    elseif currentTab == "sliders" then
        mainTabBtn.Color = colors.border
        slidersTabBtn.Color = colors.accent
    end
    
    if hitboxActive then
        status.Text = "ACTIVE"
        status.Color = colors.success
        toggleBtn.Color = colors.success
        toggleText.Text = "CLICK TO DEACTIVATE"
    else
        status.Text = "OFF"
        status.Color = colors.inactive
        toggleBtn.Color = colors.inactive
        toggleText.Text = "CLICK TO ACTIVATE"
    end
    
    protectBtn.Color = protectOwnVehicles and colors.success or colors.border
    protectText.Text = protectOwnVehicles and "PROTECT OWN Y" or "PROTECT OWN N"
    
    if currentTab == "sliders" then
        if needsApply then
            applyBtn.Color = colors.success
            applyText.Text = "APPLY CHANGES Done"
        else
            applyBtn.Color = colors.inactive
            applyText.Text = "APPLY CHANGES"
        end
    end
    
    if currentTab == "main" then
        toggleBtn.Visible = guiVisible
        toggleText.Visible = guiVisible
        protectBtn.Visible = guiVisible
        protectText.Visible = guiVisible
        infoText.Visible = guiVisible
        stats.Visible = guiVisible
        
        for _, elements in ipairs(sliderElements) do
            elements.nameText.Visible = false
            elements.valueText.Visible = false
            elements.track.Visible = false
            elements.fill.Visible = false
            elements.handle.Visible = false
        end
        resetBtn.Visible = false
        resetText.Visible = false
        applyBtn.Visible = false
        applyText.Visible = false
    elseif currentTab == "sliders" then
        toggleBtn.Visible = false
        toggleText.Visible = false
        protectBtn.Visible = false
        protectText.Visible = false
        infoText.Visible = false
        stats.Visible = false
        
        for _, elements in ipairs(sliderElements) do
            elements.nameText.Visible = guiVisible
            elements.valueText.Visible = guiVisible
            elements.track.Visible = guiVisible
            elements.fill.Visible = guiVisible
            elements.handle.Visible = guiVisible
        end
        resetBtn.Visible = guiVisible
        resetText.Visible = guiVisible
        applyBtn.Visible = guiVisible
        applyText.Visible = guiVisible
    end
    
    gui.Visible = guiVisible
    border.Visible = guiVisible
    title.Visible = guiVisible
    status.Visible = guiVisible
    mainTabBtn.Visible = guiVisible
    mainTabText.Visible = guiVisible
    slidersTabBtn.Visible = guiVisible
    slidersTabText.Visible = guiVisible
    
    updatePositions()
end

local mouse = lp:GetMouse()

spawn(function()
    while true do
        task.wait()
        local mouseX = mouse.X
        local mouseY = mouse.Y
        
        if guiVisible then
            if mouseX >= guiX + 10 and mouseX <= guiX + 135 and
               mouseY >= guiY + 50 and mouseY <= guiY + 75 then
                if currentTab ~= "main" then
                    mainTabBtn.Color = Color3.fromRGB(0, 170, 83)
                end
            elseif currentTab ~= "main" then
                mainTabBtn.Color = colors.border
            end
            
            if mouseX >= guiX + 145 and mouseX <= guiX + 270 and
               mouseY >= guiY + 50 and mouseY <= guiY + 75 then
                if currentTab ~= "sliders" then
                    slidersTabBtn.Color = Color3.fromRGB(0, 170, 83)
                end
            elseif currentTab ~= "sliders" then
                slidersTabBtn.Color = colors.border
            end
            
            if currentTab == "main" then
                if mouseX >= guiX + 10 and mouseX <= guiX + 270 and
                   mouseY >= guiY + 85 and mouseY <= guiY + 120 then
                    toggleBtn.Color = hitboxActive and Color3.fromRGB(0, 180, 100) or Color3.fromRGB(180, 180, 180)
                else
                    toggleBtn.Color = hitboxActive and colors.success or colors.inactive
                end
                
                if mouseX >= guiX + 10 and mouseX <= guiX + 270 and
                   mouseY >= guiY + 130 and mouseY <= guiY + 155 then
                    protectBtn.Color = protectOwnVehicles and Color3.fromRGB(0, 180, 100) or Color3.fromRGB(100, 100, 120)
                else
                    protectBtn.Color = protectOwnVehicles and colors.success or colors.border
                end
            elseif currentTab == "sliders" then
                if mouseX >= guiX + 10 and mouseX <= guiX + 270 and
                   mouseY >= guiY + 85 and mouseY <= guiY + 120 then
                    applyBtn.Color = needsApply and Color3.fromRGB(0, 180, 100) or Color3.fromRGB(100, 100, 120)
                else
                    applyBtn.Color = needsApply and colors.success or colors.inactive
                end
                
                if mouseX >= guiX + 10 and mouseX <= guiX + 270 and
                   mouseY >= guiY + 430 and mouseY <= guiY + 455 then
                    resetBtn.Color = Color3.fromRGB(80, 80, 100)
                else
                    resetBtn.Color = colors.border
                end
                
                for _, elements in ipairs(sliderElements) do
                    local handlePos = elements.handle.Position
                    local handleRadius = elements.handle.Radius
                    
                    local distanceToHandle = math.sqrt((mouseX - handlePos.X)^2 + (mouseY - handlePos.Y)^2)
                    local trackStartX = guiX + 60
                    local trackEndX = trackStartX + 150
                    local onTrack = mouseX >= trackStartX and mouseX <= trackEndX and 
                                   mouseY >= handlePos.Y - 10 and mouseY <= handlePos.Y + 10
                    
                    if distanceToHandle <= handleRadius or (onTrack and elements.draggingHandle) then
                        elements.handle.Color = Color3.fromRGB(0, 180, 255)
                        if ismouse1pressed() then
                            elements.draggingHandle = true
                            elements.lastMouseX = mouseX
                        end
                    else
                        elements.handle.Color = colors.accent
                    end
                end
            end
            
            for _, elements in ipairs(sliderElements) do
                if elements.draggingHandle then
                    if ismouse1pressed() then
                        updateSliderValue(elements, mouseX)
                        elements.lastMouseX = mouseX
                        updateGUI()
                    else
                        elements.draggingHandle = false
                        elements.lastMouseX = 0
                    end
                end
            end
            
            if ismouse1pressed() then
                local anySliderDragging = false
                for _, elements in ipairs(sliderElements) do
                    if elements.draggingHandle then
                        anySliderDragging = true
                        break
                    end
                end
                
                if not dragging and not anySliderDragging then
                    if mouseX >= guiX and mouseX <= guiX + 280 and
                       mouseY >= guiY and mouseY <= guiY + 30 then
                        dragging = true
                        dragOffsetX = mouseX - guiX
                        dragOffsetY = mouseY - guiY
                    end
                    
                    if mouseX >= guiX + 10 and mouseX <= guiX + 135 and
                       mouseY >= guiY + 50 and mouseY <= guiY + 75 then
                        currentTab = "main"
                        updateGUI()
                        task.wait(0.3)
                    elseif mouseX >= guiX + 145 and mouseX <= guiX + 270 and
                          mouseY >= guiY + 50 and mouseY <= guiY + 75 then
                        currentTab = "sliders"
                        updateGUI()
                        task.wait(0.3)
                    end
                end
                
                if currentTab == "main" and not dragging then
                    if mouseX >= guiX + 10 and mouseX <= guiX + 270 and
                       mouseY >= guiY + 85 and mouseY <= guiY + 120 then
                        hitboxActive = not hitboxActive
                        updateGUI()
                        task.wait(0.3)
                    elseif mouseX >= guiX + 10 and mouseX <= guiX + 270 and
                          mouseY >= guiY + 130 and mouseY <= guiY + 155 then
                        protectOwnVehicles = not protectOwnVehicles
                        updateGUI()
                        if hitboxActive then
                            scanVehicles()
                        end
                        task.wait(0.3)
                    end
                end
                
                if currentTab == "sliders" and not dragging then
                    if mouseX >= guiX + 10 and mouseX <= guiX + 270 and
                       mouseY >= guiY + 85 and mouseY <= guiY + 120 then
                        applySliderChanges()
                        updateGUI()
                        task.wait(0.3)
                    end
                    
                    if mouseX >= guiX + 10 and mouseX <= guiX + 270 and
                       mouseY >= guiY + 430 and mouseY <= guiY + 455 then
                        resetAllSliders()
                        updateGUI()
                        task.wait(0.3)
                    end
                end
            else
                dragging = false
            end
            
            if dragging then
                guiX = mouseX - dragOffsetX
                guiY = mouseY - dragOffsetY
                updatePositions()
            end
        end
    end
end)

spawn(function()
    while true do
        if hitboxActive then
            local modified, total = scanVehicles()
            stats.Text = string.format("Vehicles: %d | Modified: %d", total, modified)
        else
            stats.Text = "Click activate to expand vehicle hb"
        end
        
        wait()
    end
end)

spawn(function()
    while true do
        task.wait(0.1)
        if iskeypressed(0x70) then
            hitboxActive = not hitboxActive
            updateGUI()
            task.wait(0.3)
        end
        if iskeypressed(0xA1) then
            guiVisible = not guiVisible
            updateGUI()
            task.wait(0.3)
        end
    end
end)

updateGUI()

print("f1 - expand ")
print("rshift hide gui")
