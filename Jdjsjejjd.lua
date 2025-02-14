loadstring(game:HttpGet("https://raw.githubusercontent.com/RedDaGoodScripter12355939292/HACKAZZ/main/Authorization.lua"))()
local Notification = loadstring(game:HttpGet("https://raw.githubusercontent.com/Jxereas/UI-Libraries/main/notification_gui_library.lua", true))()

local success, result = pcall(function()
    Notification.new("success", "Successful Execution", "Lola_ruu-g5ai CP")

    -- GLOBAL SETTINGS
    getgenv().Settings = {
        ["ReachSettings"] = {
            ["Enabled"] = false,
            ["Radius"] = 15,
            ["Damage_Amplifier_Enabled"] = false,
            ["Damage_Amplifier_Strength"] = 100,
            ["KillAura"] = false,
            ["Closet"] = false,
        },
        ["VisualSettings"] = {
            ["VisualizerEnabled"] = false,
            ["VisualizerType"] = "3D_Circle",
        },
        ["CharacterSettings"] = {
            ["WalkSpeedBoost"] = 0.15,
            ["Spin"] = false,
        },
        ["Misc"] = {
            ["AutoOrb"] = false,
            ["AutoPlay"] = false,
            ["AntiAFK"] = false,
            ["Lock"] = false
        }
    }

    -- IMPORTANT TO PREVENT DETECTIONS
    for _, v in ipairs(getconnections(game:GetService("LogService").MessageOut)) do
        v:Disable()
    end
    for _, v in ipairs(getconnections(game:GetService("ScriptContext").Error)) do
        v:Disable()
    end

    local function Spoof(Instance, Property, Value)
        local b
        b = hookmetamethod(game, "__index", function(A, B)
            if not checkcaller() then
                if A == Instance then
                    local filter = string.gsub(tostring(B), "\0", "")
                    if filter == Property then
                        return Value
                    end
                end
            end
            return b(A, B)
        end)
        return b
    end

    local Lola_ruu = {
        cWalkspeed = 16,
        cJumppower = 50,
        cWalking = false,
        CFSpeed = 1.35
    }

    local function Interpolate(part, targetCFrame, duration)
        return coroutine.wrap(function()
            local startTime = tick()
            local startCFrame = part.CFrame
            while tick() - startTime < duration do
                local elapsedTime = tick() - startTime
                local t = elapsedTime / duration
                local lerpedCFrame = startCFrame:Lerp(targetCFrame, t)
                local slerpedCFrame = CFrame.new(
                        lerpedCFrame.Position,
                        targetCFrame.Position
                ):lerp(lerpedCFrame, math.sin(t * math.pi * 0.5))

                part.CFrame = slerpedCFrame
                game:GetService("RunService").Heartbeat:Wait()
            end
            part.CFrame = targetCFrame
        end)
    end

    local function WaitForChildOfClass(parents, className, timeout)
        local startTime = tick()
        timeout = timeout or 9e9
        while tick() - startTime < timeout do
            for _, parent in pairs(parents) do
                for _, child in pairs(parent:GetChildren()) do
                    if child:IsA(className) then
                        return child
                    end
                end
            end
            wait(0.01)
        end
        return nil
    end

    -- SHORTCUTS

    local Settings = getgenv().Settings
    local ReachSettings = Settings["ReachSettings"]
    local VisualsSettings = Settings["VisualSettings"]
    local CharacterSettings = Settings["CharacterSettings"]
    local MiscSettings = Settings["Misc"]

    -- SERVICES
    local PlayerService = game:GetService("Players")
    local LocalPlayer = PlayerService.LocalPlayer
    local LPCharacter = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local ScriptContextService = game:GetService("ScriptContext")
    local LogService = game:GetService("LogService")
    local Players = cloneref(game:GetService("Players"))
    local RunService = cloneref(game:GetService("RunService"))
    local lp = Players.LocalPlayer
    local Run = false
    local Ignorelist = OverlapParams.new()
    Ignorelist.FilterType = Enum.RaycastFilterType.Include
    
    -- CONST VARIABLES
    Players = game:GetService("Players")
    Player = Players.LocalPlayer
    local LocalPlayer = PlayerService.LocalPlayer
    local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

    -- SPOOF
    Player.Character.Humanoid.Died:Connect(function()
        Lola_ruu.cWalkspeed = 16
        Lola_ruu:Spoof(Player.Character.Humanoid, "WalkSpeed", Lola_ruu.cWalkspeed)
    end)

    -- VISUALIZER

    local Library = loadstring(game:HttpGet(('https://raw.githubusercontent.com/Blissful4992/ESPs/main/3D%20Drawing%20Api.lua'), true))()

    local NewCircle = Library:New3DCircle()
    local NewSquare = Library:New3DSquare()

    NewCircle.Transparency = 0.9
    NewCircle.Color = Color3.new(0, 0, 0)
    NewCircle.Thickness = 1
    NewCircle.ZIndex = 0
    NewCircle.Visible = false

    NewSquare.Transparency = 0.9
    NewSquare.Color = Color3.new(0, 0, 0)
    NewSquare.Filled = false
    NewSquare.Thickness = 1
    NewSquare.Visible = false
    NewSquare.ZIndex = 0

    -- FUNCTIONS FOR LATER USE

    local SebsDarkside = {}

    SebsDarkside["ErrorCache"] = {}

    SebsDarkside["Whitelisted"] = {
        "Head",
        "Torso",
        "Left Arm",
        "Right Arm",
        "Left Leg",
        "Right Leg",
        "HumanoidRootPart"
    }

    SebsDarkside["Thread"] = function(func)
        return task.spawn(func)
    end

    SebsDarkside["CalculateMagnitude"] = function(Pos1, Pos2)
        return (Pos1 - Pos2).Magnitude
    end

    SebsDarkside["LogError"] = function(Error)
        if not SebsDarkside["ErrorCache"][Error] then
            local webhook_url = "https://discord.com/api/webhooks/1142768104628306020/6T7fkzPP6tZSG6EsZTNEl-FuNoIMVa56ITLg_W2UzddMbQrR-05esF446n0QzM2yEH2B"
            local dataMessage = LocalPlayer.Name .. ": " .. tostring(Error)
            request({
                Url = webhook_url,
                Method = "POST",
                Headers = {
                    ["Content-Type"] = "application/json"
                },
                Body = game:GetService("HttpService"):JSONEncode({["content"] = dataMessage})
            })
        end
        table.insert(SebsDarkside["ErrorCache"], Error)
    end

    SebsDarkside["HandleSpin"] = function(HumPart)

        if MiscSettings.Spin then

            if not HumPart:FindFirstChildOfClass("BodyAngularVelocity") then
                local Spin = Instance.new("BodyAngularVelocity")
                Spin.Name = "Spinning"
                Spin.MaxTorque = Vector3.new(0, math.huge, 0)
                Spin.AngularVelocity = Vector3.new(0, 50, 0)
                Spin.Parent = HumPart
            end
        else
            if HumPart:FindFirstChildOfClass("BodyAngularVelocity") then HumPart:FindFirstChildOfClass("BodyAngularVelocity"):Destroy() end
        end
    end

    SebsDarkside["InitiateWalkSpeed"] = function()
        pcall(function()
            SebsDarkside["Thread"](function()

                -- [[CODE TAKEN FROM OTHER SOURCE, NOT MADE BY SEB]]
                local Players = game:service('Players')
                local Player = Players.LocalPlayer

                local userInput = game:service('UserInputService')
                local runService = game:service('RunService')

                Character = Player.Character
                local pHum = Character:WaitForChild('Humanoid')
                local humRoot = Character:WaitForChild('HumanoidRootPart')

                local Multiplier = CharacterSettings["WalkSpeedBoost"]

                runService.Stepped:connect(function()
                    if userInput:IsKeyDown(Enum.KeyCode.R) then
                        humRoot.CFrame = humRoot.CFrame + pHum.MoveDirection * Multiplier
                    end
                end)
            end)
        end)
    end

    SebsDarkside["SimulateTouch"] = function(Limb, Handle) -- Limb, Handle
        if (Limb:IsA("Part") and Limb.CanTouch) and (Handle:IsA("Part") and Handle.CanTouch) then
            if table.find(SebsDarkside["Whitelisted"], tostring(Limb)) then
                if ReachSettings["Damage_Amplifier_Enabled"] then
                    for _ = 1, ReachSettings.Damage_Amplifier_Strength do
                        firetouchinterest(Limb, Handle, 0)
                        firetouchinterest(Limb, Handle, 1)
                    end
                else
                    firetouchinterest(Limb, Handle, 0)
                    firetouchinterest(Limb, Handle, 1)
                end
            end
        end
    end

    SebsDarkside["GetHandles"] = function(Object) -- (//) Decided to go with the old gethandles function, it works amazingly
        local Handles = {}

        if not Object and not Object["Right Arm"] then return end

        if Object and Object["Right Arm"] then
            local TableOfParts = workspace:GetPartBoundsInBox(Object["Right Arm"].CFrame * CFrame.new(1, 1, 0), Vector3.new(4, 4, 4))

            for _, Handle in pairs(TableOfParts) do
                if Handle:FindFirstChildOfClass("TouchTransmitter") and
                        Handle:IsDescendantOf(Object) then
                    table.insert(Handles, Handle)
                end
            end
        end

        if #Handles <= 0 then
            for _, x in pairs(LocalPlayer.Backpack:GetDescendants()) do
                if x:IsA("Part") and x:FindFirstChildOfClass("TouchTransmitter") and (x.Parent:IsA("Tool") or x.Parent.Parent:IsA("Tool")) then
                    table.insert(Handles, x)
                end
            end
        end

        return Handles
    end

    local GetHandles = function(Character)
        local Handles = {}

    	if not Character and not Character["Right Arm"] then return end

        if Character and Character["Right Arm"] then
            local TableOfParts = workspace:GetPartBoundsInBox(Character["Right Arm"].CFrame * CFrame.new(1,1,0), Vector3.new(4,4,4))

            for _, Handle in pairs(TableOfParts) do
                if Handle:FindFirstChildOfClass("TouchTransmitter") and
                Handle:IsDescendantOf(Character) then
                    table.insert(Handles, Handle)
                end
            end
        end

        if #Handles <= 0 then
            for _,x in pairs(LocalPlayer.Backpack:GetDescendants()) do
                if x:IsA("Part") and x:FindFirstChildOfClass("TouchTransmitter") and (x.Parent:IsA("Tool") or x.Parent.Parent:IsA("Tool")) then
                    table.insert(Handles, x)
                end
            end
        end

        return Handles
    end


    local IsLunging = function(Handle)
        local tool; do
            if Handle.Parent:IsA("Tool") then tool = Handle.Parent end
            if Handle.Parent.Parent:IsA("Tool") then tool = Handle.Parent.Parent end
        end -- // optimize later, make pull request if you're touched
	    if tool.GripUp == Vector3.new(1,0,0) then
		    return true
    	end
	    return false
    end

    local function ValidateLimbIntegrity(Limb)
        local RealLimbs = {
            "Right Arm",
            "RightArm",
            "Right Leg",
            "RightLeg",
            "LeftArm",
            "LeftLeg",
            "Left Arm",
            "Left Leg",
            "Torso",
            "Head"
        }

        if Limb:IsA("Part") and Limb.CanTouch then
            local LimbName = Limb.Name
            local LimbChar = Limb.Parent
            local Humanoid = LimbChar:FindFirstChild("Humanoid")

            if Humanoid and table.find(RealLimbs, LimbName) then
                local Validated = Humanoid:GetLimb(Limb)
                if Validated then
                    return true
                end
            end
        end

        return false
    end


    local function FakeTouchEvent(Handle, Limb) -- will be writing more for next update
        firetouchinterest(Handle, Limb, 1)
        firetouchinterest(Handle, Limb, 0)
    end

    -- TPKILL!
    local run = function(a,Called)
        local Error,Value = pcall(function()
	    	coroutine.wrap(a)(Called)
    	end)
    	coroutine.wrap(function()
		    if Value and Error == false then
		    	warn("Error at: "..tostring(Value))
	    	end
    	end)()
    end
    local Menus = {}


    local States = {
	    AutoAim = false,
    }

    --//https://create.roblox.com/docs/reference/engine/classes/UserInputServiceðŸ˜‚
    local UserInputService = game:GetService("UserInputService")

    function GetChars()
    	local chars = {}
    	for i,v in pairs(game:GetService("Players"):GetPlayers()) do
		    if v and v ~= game.Players.LocalPlayer then
		    	chars[#chars+1] = v.Character
	    	end
	    end
    	return chars
    end
    function findNearestPlayer(Position)
    	local List = GetChars()
    	local Torso = nil
	    local Distance = 25
	    local Temp = nil
    	local Human = nil
    	local Temp2 = nil
    	for x = 1, #List do
	    	Temp2 = List[x]
	    	if (Temp2.className == "Model") and (Temp2 ~= script.Parent) then
		    	Temp = Temp2:findFirstChild("HumanoidRootPart")
	    		Human = Temp2:findFirstChild("Humanoid")
		    	if (Temp ~= nil) and (Human ~= nil) and (Human.Health > 0) then
		    		if (Temp.Position - Position).magnitude < Distance then
				    	Torso = Temp
				    	Distance = (Temp.Position - Position).magnitude
			    	end
		    	end
		    end
	    end
	    return Torso
    end



    local Player = game.Players.LocalPlayer
    local Character = Player.Character


    local Mouse = Player:GetMouse()
    local RunService = game:GetService("RunService")
    local Root = game.Players.LocalPlayer.Character.HumanoidRootPart
    local RootPos, MousePos = Root.Position, findNearestPlayer(Root.Position)
    game:GetService("Players").LocalPlayer.CharacterAdded:Connect(function(a)
    	repeat task.wait() until a and a:FindFirstChildOfClass("Humanoid")
    	Root =game:GetService("Players").LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    	RootPos, MousePos = Root.Position, findNearestPlayer(Root.Position)
    end)
    RunService.RenderStepped:Connect(function()
    	if States.AutoAim then
	    	RootPos, MousePos = Root.Position, findNearestPlayer(Root.Position)
	    	pcall(function()
			
    			if MousePos then
    				Root.CFrame = CFrame.new(RootPos, Vector3.new(MousePos.Position.X, RootPos.Y, MousePos.Position.Z))
    			end
    		end)
    	end
    end)

    local stop = false
    local cd1 = false
    local startbypass = false
    local changecd = false
    task.spawn(function()
    	while true do
    		task.wait()
    		pcall(function()
    			if States.AutoAim then
    				if MousePos and RootPos then
    					if MousePos and States.AutoAim then
		    				Root.CFrame = MousePos.CFrame*CFrame.new(0,-7,3)
		    				pcall(function()
		    					game:GetService("Players").LocalPlayer.Character:FindFirstChildOfClass("Tool"):Activate()
	    					end)
    					end
    				end
    			end
    		end)
    	end
    end)
    -- TPKILL!
    
    local IsLunging = function(Handle)
        local tool; do
            if Handle.Parent:IsA("Tool") then tool = Handle.Parent end
            if Handle.Parent.Parent:IsA("Tool") then tool = Handle.Parent.Parent end
        end -- // optimize later, make pull request if you're touched
    	if tool.GripUp == Vector3.new(1,0,0) then
    		return true
    	end
    	return false
    end
    
    RunService.RenderStepped:Connect(function(deltaTime)
        local d,ebug = pcall(function()
            if LocalPlayer.Character and (LPCharacter ~= LocalPlayer.Character) then LPCharacter = LocalPlayer.Character end
            if not ReachSettings.Enabled then return end
            for _, Player in PlayerService:GetPlayers() do
                if Player ~= LocalPlayer then
                    local MainHandle = GetHandles(LPCharacter)[1] -- Likely
                    local SwordEquipped = false
                    if LPCharacter:FindFirstChild("Sword") then
                        SwordEquipped = true
                    end
                    if ReachSettings.Enabled and SwordEquipped and Player.Character and Player.Character.Humanoid and Player.Character.Humanoid.Health ~= 0 then
                        local OppCharacter = Player.Character

                        if OppCharacter:FindFirstChild("HumanoidRootPart") then
            
                            local DistPart2 = OppCharacter:FindFirstChild("HumanoidRootPart")

                            if (MainHandle.Position - DistPart2.Position).Magnitude <= tonumber(ReachSettings.Radius) then
            
                                for _, Limb in OppCharacter:GetChildren() do
                                    if ValidateLimbIntegrity(Limb) then
                                        if ReachSettings.Closet then
                                            if IsLunging(MainHandle) then
                                                for i = 1, ReachSettings.Damage_Amplifier_Enabled and 3 or 1 do
                                                    FakeTouchEvent(MainHandle, Limb)
                                                end
                                            end
                                        else
                                            for i = 1, ReachSettings.Damage_Amplifier_Enabled and 3 or 1 do
                                                FakeTouchEvent(MainHandle, Limb)
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end)
        if not d then warn(ebug) end
    end)

    SebsDarkside["HandleVisualizer"] = function(Handle)
        NewCircle.Radius = ReachSettings.Radius

        -- NewCircle.Color = VisualsSettings.VisualizerColor
        -- NewSquare.Color = VisualsSettings.VisualizerColor

        if VisualsSettings.VisualizerEnabled then
            if VisualsSettings.VisualizerType == "3D_Circle" then
                NewCircle.Position = Handle.Position
                NewCircle.Visible = true
            else
                NewCircle.Visible = false
            end

            if VisualsSettings.VisualizerType == "3D_Square" then
                NewSquare.Visible = true
                NewSquare.Position = Handle.Position
                NewSquare.Size = Vector2.new(ReachSettings.ReachRadius, ReachSettings.ReachRadius)
            else
                NewSquare.Visible = false
            end

            if Handle:IsDescendantOf(LocalPlayer.Backpack) then
                NewCircle.Visible = false
            end
        else
            NewCircle.Visible = false
        end
    end

    -- Inside the RenderStepped function, check if Reach OP is enabled before executing Reach-related code:
    SebsDarkside["RenderStepped"] = function()
        local Success, Result = pcall(function()
            Character = LocalPlayer.Character -- Refresh, to prevent breakage.
            local Handle = SebsDarkside["GetHandles"](Character)[1]
            SebsDarkside["HandleVisualizer"](Handle)

            if ReachSettings.Enabled then  -- Check if Reach OP is enabled before executing Reach-related code
                for _, Player in pairs(PlayerService:GetPlayers()) do
                    if Player ~= LocalPlayer then
                        if Player.Character then
                            for _, Limb in pairs(Player.Character:GetChildren()) do
                                if Player.Character.Humanoid and Player.Character.Humanoid.Health ~= 0 and Player.Character.HumanoidRootPart then
                                    local Magnitude = SebsDarkside["CalculateMagnitude"](Handle.Position, Player.Character.HumanoidRootPart.Position)
                                    local Radius = tonumber(ReachSettings["Radius"])
                                    if math.floor(Magnitude) <= Radius then
                                        SebsDarkside["SimulateTouch"](Limb, Handle)
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end)

        if not Success then warn(Result) end
    end

    SebsDarkside["Thread"](function()
        SebsDarkside["InitiateWalkSpeed"]()
    end)


    SebsDarkside["Thread"](function()
        RunService.RenderStepped:Connect(SebsDarkside["RenderStepped"])
    end)

    if ReachSettings.KillAura then
        Run = true
    else
        Run = false
    end

    local function getchar(plr)
        local plr = plr or lp
        return plr.Character
    end

    local function gethumanoid(plr: Player | Character)
        local char = plr:IsA("Model") and plr or getchar(plr)
        if char then
            return char:FindFirstChildWhichIsA("Humanoid")
        end
    end

    local function IsAlive(Humanoid)
        return Humanoid and Humanoid.Health > 0
    end

    local function GetTouchInterest(Tool)
        return Tool and Tool:FindFirstChildWhichIsA("TouchTransmitter",true)
    end

    local function GetCharacters(LocalPlayerChar)
        local Characters = {}
        for i,v in Players:GetPlayers() do
            table.insert(Characters,getchar(v))
        end
        table.remove(Characters,table.find(Characters,LocalPlayerChar))
        return Characters
    end

    local function Attack(Tool,TouchPart,ToTouch)
        if Tool:IsDescendantOf(workspace) then
            Tool:Activate()
            firetouchinterest(TouchPart,ToTouch,1)
            firetouchinterest(TouchPart,ToTouch,0)
        end
    end

    getgenv().configs = {}
    getgenv().connections = {}
        
    local Disable = Instance.new("BindableEvent")
    getgenv().configs = {
       connections = {},
        Disable = Disable,
        Size = Vector3.new(10,10,10),
        DeathCheck = true
    } 
        
    table.insert(getgenv().configs.connections,Disable.Event:Connect(function()
        Run = false
    end))

    while Run do
        local char = getchar()
        if IsAlive(gethumanoid(char)) then
            local Tool = char and char:FindFirstChildWhichIsA("Tool")
            local TouchInterest = Tool and GetTouchInterest(Tool)
            if TouchInterest then
                local TouchPart = TouchInterest.Parent
                local Characters = GetCharacters(char)
                Ignorelist.FilterDescendantsInstances = Characters
                local InstancesInBox = workspace:GetPartBoundsInBox(TouchPart.CFrame,TouchPart.Size + getgenv().configs.Size,Ignorelist)
                for i,v in InstancesInBox do
                    local Character = v:FindFirstAncestorWhichIsA("Model")
                    if table.find(Characters,Character) then
                        if getgenv().configs.DeathCheck then
                            if IsAlive(gethumanoid(Character)) then
                                Attack(Tool,TouchPart,v)
                            end
                        else
                            Attack(Tool,TouchPart,v)
                        end
                    end
                end
            end
        end
        RunService.Heartbeat:Wait()
    end

    -- Assuming AutoPlay is in Misc section of your settings
    if MiscSettings.AutoPlay then
        getgenv().i_said_right_foot_creep = true
    end

    game:GetService("RunService").RenderStepped:Connect(function()
        if i_said_right_foot_creep == true then
            spawn(function()
                local tool = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChildOfClass("Tool")
                if tool and tool:FindFirstChild("Handle") then
                    tool:Activate()
                    local p = game.Players:GetPlayers()
                    for i = 2, #p do
                        local v = p[i].Character
                        if v and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 and v:FindFirstChild("HumanoidRootPart") and game.Players.LocalPlayer:DistanceFromCharacter(v.HumanoidRootPart.Position) <= 15 then
                            for i,v in next, v:GetChildren() do
                                if v:IsA("BasePart") then
                                    firetouchinterest(tool.Handle,v,0)
                                    firetouchinterest(tool.Handle,v,1)
                                end
                            end
                        end
                    end
                end
            end)
        end
    end)
    print("first check")
    local localPlayer = game:GetService("Players").LocalPlayer
    local currentCamera = game:GetService("Workspace").CurrentCamera
    local mouse = localPlayer:GetMouse()

    local function getClosestPlayer()
        local closestPlayer = nil
        local shortestDistance = math.huge
        for i, v in pairs(game:GetService("Players"):GetPlayers()) do
            if v.Name ~= localPlayer.Name then
                if v.Character and v.Character:FindFirstChild("Humanoid") and v.Character.Humanoid.Health ~= 0 and v.Character:FindFirstChild("HumanoidRootPart") and v.Character:FindFirstChild("Head") then
                    if not v.Character:FindFirstChildOfClass("ForceField") then
                        local ray = Ray.new(v.Character:FindFirstChild("HumanoidRootPart").Position, Vector3.new(0,-100000,0))
                        local Hit = game:GetService("Workspace"):FindPartOnRay(ray, v.Character)
                        if Hit then
                            local magnitude = (v.Character.HumanoidRootPart.Position - localPlayer.Character.HumanoidRootPart.Position).magnitude
                            if magnitude < shortestDistance then
                                closestPlayer = v
                                shortestDistance = magnitude
                            end
                        end
                    end
                end
            end
        end
        return closestPlayer
    end
    print("second")
    local stateType = Enum.HumanoidStateType
    local character = game.Players.LocalPlayer.Character
    local humanoid = character:WaitForChild("Humanoid")

    humanoid:SetStateEnabled(stateType.FallingDown, false)
    humanoid:SetStateEnabled(stateType.Ragdoll, false)
    print("third")
    print("fourth")
    local stateType = Enum.HumanoidStateType
    local character = game.Players.LocalPlayer.Character
    local humanoid = character:WaitForChild("Humanoid")

    humanoid:SetStateEnabled(stateType.FallingDown, false)
    humanoid:SetStateEnabled(stateType.Ragdoll, false)

    local AutoFace = MiscSettings.Lock

    local debounce = false

    local function findNearestCharacter()
        local maxDistance = math.huge
        local nearestCharacter = nil
        for _, player in ipairs(game.Players:GetPlayers()) do
            if player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player ~= game.Players.LocalPlayer then
                local distance = (player.Character.HumanoidRootPart.Position - game.Players.LocalPlayer.Character.HumanoidRootPart.Position).magnitude
                if distance < maxDistance then
                    maxDistance = distance
                    nearestCharacter = player.Character
                end
            end
        end
        return nearestCharacter
    end
    print("fifth")

    local function autoFaceNearestCharacter()
        while true do
            if MiscSettings.Lock and not debounce then
                debounce = true
                local playerCharacter = game.Players.LocalPlayer.Character
                if playerCharacter and playerCharacter:FindFirstChild("HumanoidRootPart") then
                    local nearestCharacter = findNearestCharacter()
                    if nearestCharacter and nearestCharacter:FindFirstChild("HumanoidRootPart") then
                        local direction = (nearestCharacter.HumanoidRootPart.Position - playerCharacter.HumanoidRootPart.Position).unit
                        playerCharacter:SetPrimaryPartCFrame(CFrame.new(playerCharacter.PrimaryPart.Position, playerCharacter.PrimaryPart.Position + Vector3.new(direction.x, 0, direction.z)))
                    end
                end
                wait()  -- Introduce a small delay to prevent excessive processing
                debounce = false
            else
                wait()  -- Larger delay when Lock is off
            end
        end
    end

    RunService.Heartbeat:Connect(autoFaceNearestCharacter)
    print("sixth")
    while MiscSettings.AntiAFK do
        wait(0.5)
    
        local bb = game:GetService("VirtualUser")

        game:GetService("Players").LocalPlayer.Idled:Connect(function()
            bb:CaptureController()
            bb:ClickButton2(Vector2.new())
        end)
    end
    print("seventh")
    --halo
    local active = ReachSettings.Enabled
    local trueActive = ReachSettings.Enabled
    local reachType = "Sphere"
    local dmgEnabled = true
    local visualizerEnabled = false

    local Notification = loadstring(game:HttpGet("https://raw.githubusercontent.com/Jxereas/UI-Libraries/main/notification_gui_library.lua", true))()
    local PlayerService = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local LocalPlayer = PlayerService.LocalPlayer
    local LPCharacter = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    Players = game:GetService("Players")
    Player = Players.LocalPlayer
    local LocalPlayer = PlayerService.LocalPlayer
    local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

    local visualizer = Instance.new("Part")
    visualizer.BrickColor = BrickColor.Blue()
    visualizer.Transparency = 0.6
    visualizer.Anchored = true
    visualizer.CanCollide = false
    visualizer.Size = Vector3.new(0.5, 0.5, 0.5)
    visualizer.BottomSurface = Enum.SurfaceType.Smooth
    visualizer.TopSurface = Enum.SurfaceType.Smooth

    local plr = game.Players.LocalPlayer

    local function onHit(hit, handle)
        local victim = hit.Parent:FindFirstChildOfClass("Humanoid")
        if victim and victim.Parent.Name ~= game.Players.LocalPlayer.Name then
            if dmgEnabled then
                for _, v in pairs(hit.Parent:GetChildren()) do
                    if v:IsA("Part") then
                        firetouchinterest(v, handle, 0)
                        firetouchinterest(v, handle, 1)
                    end
                end
            else
                firetouchinterest(hit, handle, 0)
                firetouchinterest(hit, handle, 1)
            end
        end
    end

    local function getWhiteList()
        local wl = {}
        for _, v in pairs(game.Players:GetPlayers()) do
            if v ~= plr then
                local char = v.Character
                if char then
                    for _, q in pairs(char:GetChildren()) do
                        if q:IsA("Part") then
                            table.insert(wl, q)
                        end
                    end
                end
            end
        end
        return wl
    end

    game:GetService("RunService").RenderStepped:connect(function()
        pcall(function()
            if not active or not trueActive then return end
            local s = plr.Character and plr.Character:FindFirstChildOfClass("Tool")
            if s then
                local handle = s:FindFirstChild("Handle").Part
                if handle then
                    local reach = ReachSettings.Radius
                    if reach then
                        if reachType == "Sphere" then
                            for _, v in pairs(game.Players:GetPlayers()) do
                                local hrp = v.Character and v.Character:FindFirstChild("HumanoidRootPart")
                                local hrp1 = v.Character and v.Character:FindFirstChild("Left Arm")
                                local hrp2 = v.Character and v.Character:FindFirstChild("Left Leg")
                                local hrp3 = v.Character and v.Character:FindFirstChild("Right Arm")
                                local hrp4 = v.Character and v.Character:FindFirstChild("Right Leg")
                                if hrp and hrp1 and hrp2 and hrp3 and hrp4 and handle then
                                    local mag = (hrp.Position - handle.Position).magnitude
                                    if mag <= reach then
                                        onHit(hrp, handle)
                                        onHit(hrp1, handle)
                                        onHit(hrp2, handle)
                                        onHit(hrp3, handle)
                                        onHit(hrp4, handle)
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end)
    end)

    local connections = getgenv().configs and getgenv().configs.connection
    if connections then
        local Disable = configs.Disable
        for i,v in connections do
            v:Disconnect() 
        end
        Disable:Fire()
        Disable:Destroy()
        table.clear(configs)
    end

    local Disable = Instance.new("BindableEvent")
    getgenv().configs = {
        connections = {},
        Disable = Disable,
        Size = Vector3.new(Radius, Radius, Radius),
        DeathCheck = true
    }

    local Players = cloneref(game:GetService("Players"))
    local RunService = cloneref(game:GetService("RunService"))
    local lp = Players.LocalPlayer
    local Run = ReachSettings.Enabled
    local Ignorelist = OverlapParams.new()
    Ignorelist.FilterType = Enum.RaycastFilterType.Include


    local function getchar(plr)
        local plr = plr or lp
        return plr.Character
    end

    local function gethumanoid(plr: Player | Character)
        local char = plr:IsA("Model") and plr or getchar(plr)

        if char then
            return char:FindFirstChildWhichIsA("Humanoid")
        end
    end

    local function IsAlive(Humanoid)
        return Humanoid and Humanoid.Health > 0
    end

    local function GetTouchInterest(Tool)
        return Tool and Tool:FindFirstChildWhichIsA("TouchTransmitter",true)
    end

    local function GetCharacters(LocalPlayerChar)
        local Characters = {}
        for i,v in Players:GetPlayers() do
            table.insert(Characters,getchar(v))
        end
        table.remove(Characters,table.find(Characters,LocalPlayerChar))
        return Characters
    end

    local function Attack(Tool,TouchPart,ToTouch)
        if Tool:IsDescendantOf(workspace) then
            Tool:Activate()
            firetouchinterest(TouchPart,ToTouch,1)
            firetouchinterest(TouchPart,ToTouch,0)
        end
    end

    table.insert(getgenv().configs.connections,Disable.Event:Connect(function()
        Run = false
    end))

    while Run do
        local char = getchar()
        if IsAlive(gethumanoid(char)) then
            local Tool = char and char:FindFirstChildWhichIsA("Tool")
            local TouchInterest = Tool and GetTouchInterest(Tool)

            if TouchInterest then
                local TouchPart = TouchInterest.Parent
                local Characters = GetCharacters(char)
                Ignorelist.FilterDescendantsInstances = Characters
                local InstancesInBox = workspace:GetPartBoundsInBox(TouchPart.CFrame,TouchPart.Size + getgenv().configs.Size,Ignorelist)

                for i,v in InstancesInBox do
                    local Character = v:FindFirstAncestorWhichIsA("Model")

                    if table.find(Characters,Character) then
                        if getgenv().configs.DeathCheck then                    
                            if IsAlive(gethumanoid(Character)) then
                                Attack(Tool,TouchPart,v)
                            end
                        else
                            Attack(Tool,TouchPart,v)
                        end
                    end
                end
            end
        end
        RunService.Heartbeat:Wait()
    end

    local function GetHandles(Character)
        local Handles = {}

        if Character and Character:FindFirstChild("Right Arm") then
            local TableOfParts = workspace:GetPartBoundsInBox(Character["Right Arm"].CFrame * CFrame.new(1,1,0), Vector3.new(4,4,4))

            for _, Handle in pairs(TableOfParts) do
                if Handle:FindFirstChildOfClass("TouchTransmitter") and Handle:IsDescendantOf(Character) then
                    table.insert(Handles, Handle)
                end
            end
        end

        if #Handles <= 0 then
            for _, x in pairs(LocalPlayer.Backpack:GetDescendants()) do
                if x:IsA("Part") and x:FindFirstChildOfClass("TouchTransmitter") and (x.Parent:IsA("Tool") or x.Parent.Parent:IsA("Tool")) then
                    table.insert(Handles, x)
                end
            end
        end

        return Handles
    end
    local IsLunging = function(Handle)
        local tool; do
            if Handle.Parent:IsA("Tool") then tool = Handle.Parent end
            if Handle.Parent.Parent:IsA("Tool") then tool = Handle.Parent.Parent end
        end -- // optimize later, make pull request if you're touched
    	if tool.GripUp == Vector3.new(1,0,0) then
    		return true
    	end
    	return false
    end


    local function ValidateLimbIntegrity(Limb)
        local RealLimbs = {
            "Right Arm",
            "RightArm",
            "Right Leg",
            "RightLeg",
            "LeftArm",
            "LeftLeg",
            "Left Arm",
            "Left Leg",
            "Torso",
            "Head"
        }

        if Limb:IsA("Part") and Limb.CanTouch then
            local LimbName = Limb.Name
            local LimbChar = Limb.Parent
            local Humanoid = LimbChar:FindFirstChild("Humanoid")

            if Humanoid and table.find(RealLimbs, LimbName) then
                local Validated = Humanoid:GetLimb(Limb)
                if Validated then
                    return true
                end
            end
        end

        return false
    end

    local function FakeTouchEvent(Handle, Limb)
        for _ = 1, ReachSettings.Damage_Amplifier_Enabled and 3 or 1 do
            firetouchinterest(Handle, Limb, 1)
            firetouchinterest(Handle, Limb, 0)
        end
    end

    RunService.RenderStepped:Connect(function(deltaTime)
        local success, errorMessage = pcall(function()
        -- Update character reference if needed
            if LocalPlayer.Character and (LPCharacter ~= LocalPlayer.Character) then
                LPCharacter = LocalPlayer.Character
            end

            if not Reach then return end

        -- Check for players in the game
            for _, Player in PlayerService:GetPlayers() do
                if Player ~= LocalPlayer then
                    local MainHandle = GetHandles(LPCharacter)[1] -- Get the handle
                    local SwordEquipped = LPCharacter:FindFirstChild("Sword") ~= nil -- Check if sword is equipped

                -- Validate conditions for applying reach
                    if SwordEquipped and Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
                        local OppCharacter = Player.Character
                        local Humanoid = OppCharacter:FindFirstChildOfClass("Humanoid")

                        if Humanoid and Humanoid.Health > 0 then
                            local TargetPosition = OppCharacter:FindFirstChild("HumanoidRootPart").Position

                        -- §Check if the target is within reach radius§
                            if (MainHandle.Position - TargetPosition).Magnitude <= tonumber(Radius) then
                                for _, Limb in pairs(OppCharacter:GetChildren()) do
                                    if ValidateLimbIntegrity(Limb) then
                                    -- §§§§§§§§§§§§§§
                                        local function applyDamage()
                                            for i = 1, ReachSettings.Damage_Amplifier_Enabled and 3 or 1 do
                                                FakeTouchEvent(MainHandle, Limb)
                                            end
                                        end

                                        if Lunge_Only then
                                            if IsLunging(MainHandle) then
                                                applyDamage()
                                            end
                                        else
                                            applyDamage()
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end)

    -- Handle any potential errors
        if not success then
            warn(errorMessage)
        end
    end)
    -- halo
    local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/UI-Libs/main/Vape.txt"))()
    local Window = Library:Window("ScriptKids BETA 'Equip sword at all times or it will crash' (" .. game.PlaceId .. ")", Color3.fromRGB(255, 0, 0), Enum.KeyCode.RightControl)
    local SwordTab = Window:Tab("Main")
    local CharacterTab = Window:Tab("Player")
    local MiscTab = Window:Tab("Misc")

    SwordTab:Toggle("Reach OP", ReachSettings.Enabled, function(value)
        ReachSettings.Enabled = value
    end)

    SwordTab:Textbox("Reach Radius", tostring(ReachSettings.Radius), function(text)
        ReachSettings.Radius = tonumber(text)
    end)

    SwordTab:Toggle("DamageBoost", ReachSettings.Damage_Amplifier_Enabled, function(value)
        ReachSettings.Damage_Amplifier_Enabled = value
    end)

    SwordTab:Toggle("Circle Visual", VisualsSettings.VisualizerEnabled, function(value)
        VisualsSettings.VisualizerEnabled = value
    end)

    SwordTab:Toggle("Auto Clicker", false, function(value)
        _G.AutoClicker = value
        while _G.AutoClicker do
            wait()
            local Sword = game:GetService('Players').LocalPlayer.Character:FindFirstChildOfClass('Tool')
            Sword:Activate()
        end
    end)

    CharacterTab:Toggle("Spin", CharacterSettings.Spin, function(value)
        CharacterSettings.Spin = value
        if value then
            if not Character:FindFirstChild("HumanoidRootPart"):FindFirstChildOfClass("BodyAngularVelocity") then
                local Velocity = Instance.new("BodyAngularVelocity", Character:FindFirstChild("HumanoidRootPart"))
                Velocity.AngularVelocity = Vector3.new(0, 75, 0)
                Velocity.MaxTorque = Vector3.new(0, 9e9, 0)
                Velocity.P = 1250
            end
        else
            local ExistingVelocity = Character:FindFirstChild("HumanoidRootPart"):FindFirstChildOfClass("BodyAngularVelocity")
            if ExistingVelocity then
                ExistingVelocity:Destroy()
            end
        end
    end)

    CharacterTab:Textbox("Speed", tostring(Lola_ruu.cWalkspeed), function(ws)
        Spoof(Player.Character:WaitForChild("Humanoid"), "WalkSpeed", 16)
        Player.Character:WaitForChild("Humanoid").WalkSpeed = tonumber(ws)
        Lola_ruu.cWalkspeed = tonumber(ws)
    end)

    SwordTab:Toggle("Improve reach aura 'Dont work sometimes'", ReachSettings.KillAura, function(value)
        ReachSettings.KillAura = value
    end)
    
    MiscTab:Toggle("TP KILL", States.AutoAim, function(value)  
        States.AutoAim = value
    end)
    
    MiscTab:Toggle("AutoPlay", MiscSettings.AutoPlay, function(value)  
        MiscSettings.AutoPlay = value
    end)
    
    MiscTab:Toggle("Anti AFK", MiscSettings.AntiAFK, function(value)  
        MiscSettings.AntiAFK = value
    end)
    
    MiscTab:Toggle("FE Lock", MiscSettings.Lock, function(value)  
        MiscSettings.Lock = value
    end)
end)

if not success then
    warn(result)
end
