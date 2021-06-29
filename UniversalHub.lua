local themes = {
	Background = Color3.fromRGB(24, 24, 24), 
	Glow = Color3.fromRGB(0, 0, 0), 
	Accent = Color3.fromRGB(10, 10, 10), 
	LightContrast = Color3.fromRGB(20, 20, 20), 
	DarkContrast = Color3.fromRGB(14, 14, 14),  
	TextColor = Color3.fromRGB(255, 255, 255)
}

-- Locals
local boxespToggled = false
local boxespTeamCheck = false
local boxespHealthBar = false
local boxespColor = Color3.new(0,0,0)
local boxespOColor = Color3.new(1,1,1)
local boxesphboColor = Color3.new(0,0,0)
local boxesphbColor = Color3.new(0.454901, 0.878431, 0.560784)

-- Flying Variables
local lplr = game.Players.LocalPlayer
local rs = game:GetService("RunService")
local myChar = lplr.Character
local myHRP = myChar:WaitForChild("HumanoidRootPart")
local flying = false
local speed = 0.5
local bp = Instance.new("BodyPosition", myHRP)
bp.MaxForce = Vector3.new()
bp.D = 10
bp.P = 10000
local bg = Instance.new("BodyGyro", myHRP)
bg.MaxTorque = Vector3.new()
bg.D = 10

-- Noclip locals
local noclipToggled = false

-- Aimbot Locals
local UIS = game:GetService("UserInputService")
local aiming = false
local aimbotToggled = false
local aimbotTeamCheck = false
local aimbotLocation = "Head"
local aimbotWallCheck = false

local camera = game:GetService("Workspace").CurrentCamera
local cam = game.Workspace.CurrentCamera
local CurrentCamera = workspace.CurrentCamera
local worldToViewportPoint = CurrentCamera.WorldToViewportPoint

local HeadOff = Vector3.new(0, 0.5, 0)
local LegOff = Vector3.new(0,3,0)

-- Funcs
function fly()
    flying = true
	bp.MaxForce = Vector3.new(400000,400000,400000)
	bg.MaxTorque = Vector3.new(400000,400000,400000)
	while flying do
		rs.RenderStepped:wait()
		bp.Position = myHRP.Position +((myHRP.Position - camera.CFrame.p).unit * speed)
		bg.CFrame = CFrame.new(camera.CFrame.p, myHRP.Position)
	end
end

function endFlying()
	bp.MaxForce = Vector3.new()
	bg.MaxTorque = Vector3.new()
	flying = false
end

isPartVisible = function(Part, PartDescendant)
    local Character = game.Players.LocalPlayer.Character or game.Players.LocalPlayer.CharacterAdded.Wait(game.Players.LocalPlayer.CharacterAdded)
    local Origin = workspace.CurrentCamera.CFrame.p
    local _, OnScreen = workspace.CurrentCamera.WorldToViewportPoint(workspace.CurrentCamera, Part.Position)
    if OnScreen then
        local newRay = Ray.new(Origin, Part.Position - Origin)
        local PartHit, _ = workspace.FindPartOnRayWithIgnoreList(workspace, newRay, {game.Players.LocalPlayer.Character, workspace.CurrentCamera})
        local Visible = (not PartHit or PartHit.IsDescendantOf(PartHit, PartDescendant))
        return true
    end
    return false
end

for i,v in pairs(game.Players:GetChildren()) do
        local BoxOutline = Drawing.new("Square")
        BoxOutline.Visible = false
        BoxOutline.Color = boxespColor
        BoxOutline.Thickness = 3
        BoxOutline.Transparency = 1
        BoxOutline.Filled = false

        local Box = Drawing.new("Square")
        Box.Visible = false
        Box.Color = boxespOColor
        Box.Thickness = 1
        Box.Transparency = 1
        Box.Filled = false

        local HealthBarOutline = Drawing.new("Square")
        HealthBarOutline.Thickness = 3
        HealthBarOutline.Filled = false
        HealthBarOutline.Color = boxesphboColor
        HealthBarOutline.Transparency = 1
        HealthBarOutline.Visible = false

        local HealthBar = Drawing.new("Square")
        HealthBar.Thickness = 1
        HealthBar.Filled = false
        HealthBarOutline.Color = boxesphbColor
        HealthBar.Transparency = 1
        HealthBar.Visible = false

        function boxesp()
            game:GetService("RunService").RenderStepped:Connect(function()
                if v.Character ~= nil and v.Character:FindFirstChild("Humanoid") ~= nil and v.Character:FindFirstChild("HumanoidRootPart") ~= nil and v ~= lplr and v.Character.Humanoid.Health > 0 then
                    local Vector, onScreen = camera:worldToViewportPoint(v.Character.HumanoidRootPart.Position)

                    local RootPart = v.Character.HumanoidRootPart
                    local Head = v.Character.Head
                    local RootPosition, RootVis = worldToViewportPoint(CurrentCamera, RootPart.Position)
                    local HeadPosition = worldToViewportPoint(CurrentCamera, Head.Position + HeadOff)
                    local LegPosition = worldToViewportPoint(CurrentCamera, RootPart.Position - LegOff)

                    if onScreen and boxespToggled then
                        BoxOutline.Size = Vector2.new(1000 / RootPosition.Z, HeadPosition.Y - LegPosition.Y)
                        BoxOutline.Position = Vector2.new(RootPosition.X - BoxOutline.Size.X / 2, RootPosition.Y - BoxOutline.Size.Y / 2)
                        BoxOutline.Visible = true
                        BoxOutline.Color = boxespColor

                        Box.Size = Vector2.new(1000 / RootPosition.Z, HeadPosition.Y - LegPosition.Y)
                        Box.Position = Vector2.new(RootPosition.X - Box.Size.X / 2, RootPosition.Y - Box.Size.Y / 2)
                        Box.Visible = true
                        Box.Color = boxespOColor

                        if boxespHealthBar and game.PlaceId == 286090429 then
                            HealthBarOutline.Size = Vector2.new(2, HeadPosition.Y - LegPosition.Y)
                            HealthBarOutline.Position = BoxOutline.Position - Vector2.new(6,0)
                            HealthBarOutline.Visible = true
                            HealthBarOutline.Color = boxesphboColor

                            HealthBar.Size = Vector2.new(2, (HeadPosition.Y - LegPosition.Y) / (game:GetService("Players")[v.Character.Name].NRPBS["MaxHealth"].Value / math.clamp(game:GetService("Players")[v.Character.Name].NRPBS["Health"].Value, 0, game:GetService("Players")[v.Character.Name].NRPBS:WaitForChild("MaxHealth").Value)))
                            HealthBar.Position = Vector2.new(Box.Position.X - 6, Box.Position.Y + (1/HealthBar.Size.Y))
                            HealthBar.Visible = true
                            HealthBar.Color = boxesphbColor
                        else
                            HealthBar.Visible = false
                            HealthBarOutline.Visible = false
                        end

                        if v.TeamColor == lplr.TeamColor and boxespTeamCheck then
                            BoxOutline.Visible = false
                            Box.Visible = false
                            HealthBarOutline.Visible = false
                            HealthBar.Visible = false
                        else
                            BoxOutline.Visible = true
                            Box.Visible = true
                            if boxespHealthBar then
                                HealthBarOutline.Visible = true
                                HealthBar.Visible = true
                            end
                        end

                    else
                        BoxOutline.Visible = false
                        Box.Visible = false
                        HealthBarOutline.Visible = false
                        HealthBar.Visible = false
                    end
                else
                    BoxOutline.Visible = false
                    Box.Visible = false
                    HealthBarOutline.Visible = false
                    HealthBar.Visible = false
                end
            end)
        end
        coroutine.wrap(boxesp)()
    end

game.Players.PlayerAdded:Connect(function(v)
    local BoxOutline = Drawing.new("Square")
        BoxOutline.Visible = false
        BoxOutline.Color = boxespColor
        BoxOutline.Thickness = 3
        BoxOutline.Transparency = 1
        BoxOutline.Filled = false

        local Box = Drawing.new("Square")
        Box.Visible = false
        Box.Color = boxespOColor
        Box.Thickness = 1
        Box.Transparency = 1
        Box.Filled = false

        local HealthBarOutline = Drawing.new("Square")
        HealthBarOutline.Thickness = 3
        HealthBarOutline.Filled = false
        HealthBarOutline.Color = boxesphboColor
        HealthBarOutline.Transparency = 1
        HealthBarOutline.Visible = false

        local HealthBar = Drawing.new("Square")
        HealthBar.Thickness = 1
        HealthBar.Filled = false
        HealthBarOutline.Color = boxesphbColor
        HealthBar.Transparency = 1
        HealthBar.Visible = false

        function boxesp()
            game:GetService("RunService").RenderStepped:Connect(function()
                if v.Character ~= nil and v.Character:FindFirstChild("Humanoid") ~= nil and v.Character:FindFirstChild("HumanoidRootPart") ~= nil and v ~= lplr and v.Character.Humanoid.Health > 0 then
                    local Vector, onScreen = camera:worldToViewportPoint(v.Character.HumanoidRootPart.Position)

                    local RootPart = v.Character.HumanoidRootPart
                    local Head = v.Character.Head
                    local RootPosition, RootVis = worldToViewportPoint(CurrentCamera, RootPart.Position)
                    local HeadPosition = worldToViewportPoint(CurrentCamera, Head.Position + HeadOff)
                    local LegPosition = worldToViewportPoint(CurrentCamera, RootPart.Position - LegOff)

                    if onScreen and boxespToggled then
                        BoxOutline.Size = Vector2.new(1000 / RootPosition.Z, HeadPosition.Y - LegPosition.Y)
                        BoxOutline.Position = Vector2.new(RootPosition.X - BoxOutline.Size.X / 2, RootPosition.Y - BoxOutline.Size.Y / 2)
                        BoxOutline.Visible = true
                        BoxOutline.Color = boxespColor

                        Box.Size = Vector2.new(1000 / RootPosition.Z, HeadPosition.Y - LegPosition.Y)
                        Box.Position = Vector2.new(RootPosition.X - Box.Size.X / 2, RootPosition.Y - Box.Size.Y / 2)
                        Box.Visible = true
                        Box.Color = boxespOColor

                        if boxespHealthBar and game.PlaceId == 286090429 then
                            HealthBarOutline.Size = Vector2.new(2, HeadPosition.Y - LegPosition.Y)
                            HealthBarOutline.Position = BoxOutline.Position - Vector2.new(6,0)
                            HealthBarOutline.Visible = true

                            HealthBar.Size = Vector2.new(2, (HeadPosition.Y - LegPosition.Y) / (game:GetService("Players")[v.Character.Name].NRPBS["MaxHealth"].Value / math.clamp(game:GetService("Players")[v.Character.Name].NRPBS["Health"].Value, 0, game:GetService("Players")[v.Character.Name].NRPBS:WaitForChild("MaxHealth").Value)))
                            HealthBar.Position = Vector2.new(Box.Position.X - 6, Box.Position.Y + (1/HealthBar.Size.Y))
                            HealthBar.Visible = true
                        end

                        if v.TeamColor == lplr.TeamColor and boxespTeamCheck then
                            BoxOutline.Visible = false
                            Box.Visible = false
                            HealthBarOutline.Visible = false
                            HealthBar.Visible = false
                        else
                            BoxOutline.Visible = true
                            Box.Visible = true
                            if boxespHealthBar then
                                HealthBarOutline.Visible = true
                                HealthBar.Visible = true
                            else
                                HealthBarOutline.Visible = false
                                HealthBar.Visible = false
                            end
                        end

                    else
                        BoxOutline.Visible = false
                        Box.Visible = false
                        HealthBarOutline.Visible = false
                        HealthBar.Visible = false
                    end
                else
                    BoxOutline.Visible = false
                    Box.Visible = false
                    HealthBarOutline.Visible = false
                    HealthBar.Visible = false
                end
            end)
        end
    coroutine.wrap(boxesp)()
end)

game:GetService("RunService").RenderStepped:Connect(function()
    if aiming and isPartVisible(lplr.Character.Head, lplr.Character) then
        cam.CFrame = CFrame.new(cam.CFrame.Position,closestplayer().Character.Head.Position)
    end
end)

game:GetService("RunService").Stepped:Connect(function()
    if noclipToggled then
        lplr.Character.Humanoid:ChangeState(11)
    end    
end)

function CreateMenu()
    local library = loadstring(game:HttpGet("https://raw.githubusercontent.com/GreenDeno/Venyx-UI-Library/main/source.lua"))()
    local Menu = library.new("Azure v0.23", 5013109572)
    
    Menu:Notify("Azure", "Loading Menu Modules!")
    local MainPage = Menu:addPage("Main", 5012544693)
    local mps1 = MainPage:addSection("Support")
    
        mps1:addButton("Copy Discord", function()
            setclipboard("https://discord.gg/qBQd2NRUeH")
        end)
        Menu:Notify("Azure","Clipboard copied!")
    local mps2 = MainPage:addSection("Created by Justice#7607")
    
    local PlayerPage = Menu:addPage("Player", 5012544693)
    local pps1 = PlayerPage:addSection("Player")
        pps1:addToggle("Noclip", false, function(v)
            if v then
                noclipToggled = true
            else
                noclipToggled = false
            end
        end)
        pps1:addToggle("Fly", false, function(v)
            if v then
                fly()
            else
                endFlying()
            end
        end)
    
    local MovementPage = Menu:addPage("Movement", 5012544693)
    local movs1 = MovementPage:addSection("Movement")
        movs1:addSlider("Walkspeed", 16, 16, 250, function(v)
            game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = v
        end)
        movs1:addSlider("Jump Power", 16, 16, 250, function(v)
            game.Players.LocalPlayer.Character.Humanoid.JumpPower = v
        end)
        movs1:addSlider("Gravity", 192.6, 1, 300, function(v)
            game.Workspace.Gravity = v
        end)
    
    local CombatPage = Menu:addPage("Combat", 5012544693)
    local cbs1 = CombatPage:addSection("Aimbot")
        cbs1:addToggle("Aimbot", false, function(v)
            if v then
                aimbotToggled = true
    
                function closestplayer()
                    local dist = math.huge
                    local target = nil
                    for i,v in pairs (game:GetService("Players"):GetPlayers()) do
                        if v ~= lplr then
                            if aimbotLocation == "Head" then
                                if v.Character and v.Character:FindFirstChild("Head") and v.TeamColor ~= lplr.TeamColor and aimbotToggled then
                                    local magnitude = (v.Character.Head.Position - lplr.Character.Head.Position).magnitude
                                    if magnitude < dist then
                                        dist = magnitude
                                        target = v
                                    end
                                end
                            elseif aimbotLocation == "Chest" then
                                if v.Character and v.Character:FindFirstChild("Chest") and v.TeamColor ~= lplr.TeamColor and aimbotToggled then
                                    local magnitude = (v.Character.Chest.Position - lplr.Character.Chest.Position).magnitude
                                    if magnitude < dist then
                                        dist = magnitude
                                        target = v
                                    end
                                end
                            end
                        end
                    end
                    return target
                end
            else
                aimbotToggled = false
            end
        end)
        cbs1:addKeybind("Aimbot Toggle", Enum.KeyCode.KeypadNine, function()
            if aiming and aimbotToggled then
                aiming = false
            elseif not aiming and aimbotToggled then
                aiming = true
            end
        end)
        cbs1:addDropdown("Aim Bone", {"Head", "Chest"}, function(text)
            aimbotLocation = text
        end)

    local VisualsPage = Menu:addPage("Visuals", 5012544693)
    local vps1 = VisualsPage:addSection("ESP")
        vps1:addToggle("Box ESP", false, function(v)
            if v then
                boxespToggled = true
            else
                boxespToggled = false
            end
        end)
        vps1:addColorPicker("Box Color", Color3.new(0,0,0), function(c)
            print("Box esp color updated!")
            boxespColor = c
            print(boxespColor)
        end)
        vps1:addColorPicker("Box Outline Color", Color3.new(1,1,1), function(c)
            print("Box esp color updated!")
            boxespOColor = c
            print(boxespOColor)
        end)
        vps1:addToggle("Teamcheck", false, function(v)
            if v then
                boxespTeamCheck = true
            else
                boxespTeamCheck = false
            end
        end)
        if game.PlaceId == 286090429 then
            vps1:addToggle("Healthbar", false, function(v)
                if v then
                    boxespHealthBar = true
                else
                    boxespHealthBar = false
                end
            end)
            vps1:addColorPicker("Healthbar Color", Color3.new(0.454901, 0.878431, 0.560784), function(c)
                print("Healthbar color updated!")
                boxesphbColor = c
            end)
            vps1:addColorPicker("Healthbar Outline Color", Color3.new(0.454901, 0.878431, 0.560784), function(c)
                print("Healthbar Outline color updated!")
                boxesphboColor = c
            end)
        end
    local OptionsPage = Menu:addPage("Options", 5012544693)
    
    local ops1 = OptionsPage:addSection("Keybinds")
        ops1:addKeybind("Toggle Menu", Enum.KeyCode.H, function()
            Menu:toggle()
            Menu:Notify("Azure", "Menu has been toggled.")
        end)
    
    local ops1 = OptionsPage:addSection("UI Colors")
        ops1:addColorPicker("Text Color", Color3.new(255,255,255), function(c)
            Menu:setTheme("TextColor", c)
        end)
    
        ops1:addColorPicker("Background Color", Color3.new(24, 24, 24), function(c)
            Menu:setTheme("Background", c)
        end)
    
        ops1:addColorPicker("Glow Color", Color3.new(0,0,0), function(c)
            Menu:setTheme("Glow", c)
        end)
    
        ops1:addColorPicker("Accent Color", Color3.new(10,10,10), function(c)
            Menu:setTheme("Accent", c)
        end)
    
        ops1:addColorPicker("Light Contrast", Color3.new(20,20,20), function(c)
            Menu:setTheme("LightContrast", c)
        end)
    
        ops1:addColorPicker("Dark Contrast", Color3.new(14,14,14), function(c)
            Menu:setTheme("DarkContrast", c)
        end)
    
    local ops2 = OptionsPage:addSection("Dangerous")
        ops2:addButton("Close UI", function()
            Menu:toggle()
            Menu:Notify("Azure", "Libray has been closed! Press your keybind to reopen it!")
    end)    
end

wait(5)
CreateMenu()
