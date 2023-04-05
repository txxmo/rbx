-- created by tomo#0069
getgenv().Config = {
    Aimbot = { 
        Enabled = true,
        Keybind = "p",
        Prediction = 0.1172,
        AutoPrediction = true,
        Notifications = true,
    },
    FOV = {
        Visible = true,
        Radius = 20,
    },
    Checks = {
        Death = true,
        Knocked = true,
        NoGroundShots = true,
    },
}

local pingTable = {
    [30] = 0.12588,
    [40] = 0.119,
    [50] = 0.1247,
    [60] = 0.127668,
    [70] = 0.12731,
    [80] = 0.12951,
    [90] = 0.1318,
    [100] = 0.1357,
    [110] = 0.13334,
    [120] = 0.1455,
    [130] = 0.143765,
    [140] = 0.156692,
    [150] = 0.1223333,
    [160] = 0.1521,
    [170] = 0.1626,
    [180] = 0.1923111,
    [190] = 0.19284,
    [200] = 0.166547,
    [210] = 0.16942,
    [260] = 0.1651,
    [310] = 0.1678,
}

-- Notification Lib
Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/vKhonshu/intro2/main/ui2"))()
local NotifyLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/vKhonshu/intro/main/ui"))()

NotifyLib.prompt("Tomoware", "Loading", 3)

-- Aim Parts
getgenv().AimPart = "Head"
getgenv().vAimPart = "Head"

-- Variables
local Prey = nil
local Plr = nil

local Players, Client, Mouse, RS, Camera =
game:GetService("Players"),
game:GetService("Players").LocalPlayer,
game:GetService("Players").LocalPlayer:GetMouse(),
game:GetService("RunService"),
game.Workspace.CurrentCamera

-- FOV Circle
local Circle = Drawing.new("Circle")
Circle.Color = Color3.new(1,1,1)
Circle.Thickness = 1

local UpdateFOV = function ()
if (not Circle) then
    return Circle
end
Circle.Visible = getgenv().Config.FOV["Visible"]
Circle.Radius = getgenv().Config.FOV["Radius"] * 3
Circle.Position = Vector2.new(Mouse.X, Mouse.Y + (game:GetService("GuiService"):GetGuiInset().Y))
return Circle
end

RS.Heartbeat:Connect(UpdateFOV)

NotifyLib.prompt("Tomoware", "Loaded", 2.5)

-- Closest player 

ClosestPlrFromMouse = function()
    local Target, Closest = nil, 1 / 0

    for _, v in pairs(Players:GetPlayers()) do
        if (v.Character and v ~= Client and v.Character:FindFirstChild("HumanoidRootPart")) then
            local Position, OnScreen = Camera:WorldToScreenPoint(v.Character.HumanoidRootPart.Position)
            local Distance = (Vector2.new(Position.X, Position.Y) - Vector2.new(Mouse.X, Mouse.Y)).Magnitude

            if (Circle.Radius > Distance and Distance < Closest and OnScreen) then
                Closest = Distance
                Target = v
            end
        end
    end

    return Target
end

-- World to Screen functions
local WTS = function (Object)
    local ObjectVector = Camera:WorldToScreenPoint(Object.Position)
    return Vector2.new(ObjectVector.X, ObjectVector.Y)
end

local IsOnScreen = function (Object)
    local IsOnScreen = Camera:WorldToScreenPoint(Object.Position)
    return IsOnScreen
end
    
local FilterObjs = function (Object)
    if string.find(Object.Name, "Gun") then
        return
    end

    if table.find({"Part", "MeshPart", "BasePart"}, Object.ClassName) then
        return true
    end
end

-- Get Nearest Bodypart
local GetClosestBodyPart = function (character)
    local ClosestDistance = 1/0
    local BodyPart = nil
    if (character and character:GetChildren()) then
        for _,  x in next, character:GetChildren() do
            if FilterObjs(x) and IsOnScreen(x) then
                local Distance = (WTS(x) - Vector2.new(Mouse.X, Mouse.Y)).Magnitude
                if (Circle.Radius > Distance and Distance < ClosestDistance) then
                    ClosestDistance = Distance
                    BodyPart = x
                end
            end
        end
    end

    return BodyPart
end

local Prey

task.spawn(
    function()
        while task.wait() do
            if Prey then
                if getgenv().Config.Aimbot.Enabled then
                    getgenv().AimPart = tostring(GetClosestBodyPart(Prey.Character))
                end
            end
        end
    end
)

-- Prediction
local grmt = getrawmetatable(game)
local backupindex = grmt.__index
setreadonly(grmt, false)

grmt.__index =
    newcclosure(
    function(self, v)
        if (getgenv().Config.Aimbot.Enabled and Mouse and tostring(v) == "Hit") then
            Prey = ClosestPlrFromMouse()

            if Prey then
                local endpoint =
                    game.Players[tostring(Prey)].Character[getgenv().AimPart].CFrame +
                    (game.Players[tostring(Prey)].Character[getgenv().AimPart].Velocity *
                        getgenv().Config.Aimbot.Prediction)
                return (tostring(v) == "Hit" and endpoint)
            end
        end
        return backupindex(self, v)
    end
)

local CC = game.Workspace.CurrentCamera
local Mouse = game.Players.LocalPlayer:GetMouse()
local Plr

-- On Screen
local function IsOnScreen(Object)
    local IsOnScreen = game.Workspace.CurrentCamera:WorldToScreenPoint(Object.Position)
    return IsOnScreen
end

local function Filter(Object)
    if string.find(Object.Name, "Gun") then
        return
    end
    if Object:IsA("Part") or Object:IsA("MeshPart") then
        return true
    end
end

local function Filter(Object)
    if string.find(Object.Name, "Gun") then
        return
    end
    if Object:IsA("Part") or Object:IsA("MeshPart") then
        return true
    end
end

local function WTS(Object)
    local ObjectVector = game.Workspace.CurrentCamera:WorldToScreenPoint(Object.Position)
    return Vector2.new(ObjectVector.X, ObjectVector.Y)
end

function GetNearestPartToCursorOnCharacter(character)
    local ClosestDistance = math.huge
    local BodyPart = nil

    if (character and character:GetChildren()) then
        for k, x in next, character:GetChildren() do
            if Filter(x) and IsOnScreen(x) then
                local Distance = (WTS(x) - Vector2.new(Mouse.X, Mouse.Y)).Magnitude

                if Distance < ClosestDistance then
                    ClosestDistance = Distance
                    BodyPart = x
                end
            end
        end
    end

    return BodyPart
end


Mouse.KeyDown:Connect(
    function(Key)
        local Keybind = getgenv().Config.Aimbot.Keybind:lower()
        if (Key == Keybind) then
            if getgenv().Config.Aimbot.Enabled == true then
                getgenv().Config.Aimbot.Enabled = false
                if getgenv().Config.Aimbot.Notifications == true then
                    NotifyLib.prompt("Tomoware", "Silent Disabled", 1.5)
                else
                    getgenv().Config.Aimbot.Enabled = true
                    if getgenv().Config.Aimbot.Notifications == true then
                        NotifyLib.prompt("Tomoware", "Silent Enabled", 1.5)
                    end
                end
            end
        end
    end
)

-- checks watcher
RS.RenderStepped:Connect(
    function()
        if
            getgenv().Config.Checks.NoGroundShots == true and
                Prey.Character:FindFirstChild("Humanoid") == Enum.HumanoidStateType.Freefall
         then
            pcall(
                function()
                    local TargetVelv5 = targ.Character[getgenv().AimPart]
                    TargetVelv5.Velocity =
                        Vector3.new(TargetVelv5.Velocity.X, (TargetVelv5.Velocity.Y * 5), TargetVelv5.Velocity.Z)
                    TargetVelv5.AssemblyLinearVelocity =
                        Vector3.new(TargetVelv5.Velocity.X, (TargetVelv5.Velocity.Y * 5), TargetVelv5.Velocity.Z)
                end
            )
        end

        if getgenv().Config.Checks.Death == true and Plr and Plr.Character:FindFirstChild("Humanoid") then
            if Plr.Character.Humanoid.health < 2 then
                Plr = nil
                IsTargetting = false
            end
        end
        if getgenv().Config.Checks.Death == true and Plr and Plr.Character:FindFirstChild("Humanoid") then
            if Client.Character.Humanoid.health < 2 then
                Plr = nil
                IsTargetting = false
            end
        end
        if getgenv().Config.Checks.Knocked == true and Prey and Prey.Character then
            local KOd = Prey.Character:WaitForChild("BodyEffects")["K.O"].Value
            local Grabbed = Prey.Character:FindFirstChild("GRABBING_CONSTRAINT") ~= nil
            if KOd or Grabbed then
                Prey = nil
            end
        end
        if getgenv().Config.Checks.Knocked == true and Plr and Plr.Character then
            local KOd = Plr.Character:WaitForChild("BodyEffects")["K.O"].Value
            local Grabbed = Plr.Character:FindFirstChild("GRABBING_CONSTRAINT") ~= nil
            if KOd or Grabbed then
                Plr = nil
                IsTargetting = false
            end
        end
    end
)

game.RunService.Heartbeat:Connect(
    function()
        -- this stays here because we need it for non silent aimbot
    end
)

task.spawn(
    function()
        while task.wait() do
            -- ditto above
        end
    end
)

while getgenv().Config.Aimbot.AutoPrediction == true do
    local ping = game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValueString()
    local pingNumber = tonumber(string.match(ping, "%d+"))

    for threshold, prediction in pairs(pingTable) do
        if pingNumber < threshold then
            Config.Aimbot.Prediction = prediction
            break
        end
    end

    RunService.Heartbeat:Wait()
end
