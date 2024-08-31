local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/nexus4rbx/Novoline-custom/main/GuiLibrary.lua", true))()
local entity = loadstring(game:HttpGet("https://raw.githubusercontent.com/7GrandDadPGN/VapeV4ForRoblox/main/Libraries/entityHandler.lua", true))()

local players = game:GetService("Players")
local lplr = players.LocalPlayer
local Lighting = game.Lighting
local LocalPlayer = lplr
local Character = LocalPlayer.Character
local HumanoidRootPart = Character.HumanoidRootPart
local cam = game.Workspace.CurrentCamera
local LightingTime = Lighting.TimeOfDay
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local modules = {}

local function isAlive(plr)
	if plr then
		return plr and plr.Character and plr.Character.Parent ~= nil and plr.Character:FindFirstChild("HumanoidRootPart") and plr.Character:FindFirstChild("Head") and plr.Character:FindFirstChild("Humanoid")
	end
end

local function runcode(func)
	func()
end

local RunLoops = {RenderStepTable = {}, StepTable = {}, HeartTable = {}}
do
	function RunLoops:BindToRenderStep(name, num, func)
		if RunLoops.RenderStepTable[name] == nil then
			RunLoops.RenderStepTable[name] = game:GetService("RunService").RenderStepped:Connect(func)
		end
	end

	function RunLoops:UnbindFromRenderStep(name)
		if RunLoops.RenderStepTable[name] then
			RunLoops.RenderStepTable[name]:Disconnect()
			RunLoops.RenderStepTable[name] = nil
		end
	end

	function RunLoops:BindToStepped(name, num, func)
		if RunLoops.StepTable[name] == nil then
			RunLoops.StepTable[name] = game:GetService("RunService").Stepped:Connect(func)
		end
	end

	function RunLoops:UnbindFromStepped(name)
		if RunLoops.StepTable[name] then
			RunLoops.StepTable[name]:Disconnect()
			RunLoops.StepTable[name] = nil
		end
	end

	function RunLoops:BindToHeartbeat(name, num, func)
		if RunLoops.HeartTable[name] == nil then
			RunLoops.HeartTable[name] = game:GetService("RunService").Heartbeat:Connect(func)
		end
	end

	function RunLoops:UnbindFromHeartbeat(name)
		if RunLoops.HeartTable[name] then
			RunLoops.HeartTable[name]:Disconnect()
			RunLoops.HeartTable[name] = nil
		end
	end
end

local function hashvec(vec)
	return {value = vec}
end

local function getremote(tab)
	for i,v in pairs(tab) do
		if v == "Client" then
			return tab[i + 1]
		end
	end
	return ""
end
runcode(function()
	local KnitClient = debug.getupvalue(require(lplr.PlayerScripts.TS.knit).setup, 6)
	local Client = require(game:GetService("ReplicatedStorage").TS.remotes).default.Client
	local InventoryUtil = require(game:GetService("ReplicatedStorage").TS.inventory["inventory-util"]).InventoryUtil
	modules = {
		AttackRemote = getremote(debug.getconstants(getmetatable(KnitClient.Controllers.SwordController).attackEntity)),
		BlockController = require(game:GetService("ReplicatedStorage")["rbxts_include"]["node_modules"]["@easy-games"]["block-engine"].out).BlockEngine,
		BlockController2 = require(game:GetService("ReplicatedStorage")["rbxts_include"]["node_modules"]["@easy-games"]["block-engine"].out.client.placement["block-placer"]).BlockPlacer,
		BlockEngine = require(lplr.PlayerScripts.TS.lib["block-engine"]["client-block-engine"]).ClientBlockEngine,
		ClientHandler = Client,
		getCurrentInventory = function(plr)
			local plr = plr or lplr
			local suc, result = pcall(function()
				return InventoryUtil.getInventory(plr)
			end)
			return (suc and result or {
				["items"] = {},
				["armor"] = {},
				["hand"] = nil
			})
		end,
		ItemMeta = debug.getupvalue(require(game:GetService("ReplicatedStorage").TS.item["item-meta"]).getItemMeta, 1),
		itemtablefunc = require(ReplicatedStorage.TS.item["item-meta"]).getItemMeta,
		KnockbackUtil = require(game:GetService("ReplicatedStorage").TS.damage["knockback-util"]).KnockbackUtil,
		SprintCont = KnitClient.Controllers.SprintController,
		SwordController = KnitClient.Controllers.SwordController,
		ShopItems = debug.getupvalue(debug.getupvalue(require(ReplicatedStorage.TS.games.bedwars.shop["bedwars-shop"]).BedwarsShop.getShopItem, 1), 2),
		ScytheDash = ReplicatedStorage.rbxts_include.node_modules["@rbxts"].net.out._NetManaged.ScytheDash,
       		FallRemote = ReplicatedStorage.rbxts_include.node_modules["@rbxts"].net.out._NetManaged.GroundHit,

		GuitarController = ReplicatedStorage.rbxts_include.node_modules:FindFirstChild("@rbxts").net.out._NetManaged.PlayGlitchGuitar,
		QueryUtil = require(ReplicatedStorage["rbxts_include"]["node_modules"]["@easy-games"]["game-core"].out).GameQueryUtil
	}
end)

itemtable = debug.getupvalue(modules.itemtablefunc, 1)

local function targetCheck(plr, check)
	return (check and plr.Character.Humanoid.Health > 0 and plr.Character:FindFirstChild("ForceField") == nil or check == false)
end

local function isPlayerTargetable(plr, target)
	return plr.Team ~= lplr.Team and plr and isAlive(plr) and targetCheck(plr, target)
end

local function GetAllNearestHumanoidToPosition(distance, amount)
	local returnedplayer = {}
	local currentamount = 0
	if isAlive(lplr) then -- alive check
		for i,v in pairs(game.Players:GetChildren()) do -- loop through players
			if isPlayerTargetable((v), true, true, v.Character ~= nil) and v.Character:FindFirstChild("HumanoidRootPart") and v.Character:FindFirstChild("Head") and currentamount < amount then -- checks
				local mag = (lplr.Character.HumanoidRootPart.Position - v.Character:FindFirstChild("HumanoidRootPart").Position).magnitude
				if mag <= distance then -- mag check
					table.insert(returnedplayer, v)
					currentamount = currentamount + 1
				end
			end
		end
		for i2,v2 in pairs(game:GetService("CollectionService"):GetTagged("Monster")) do -- monsters
			if v2:FindFirstChild("HumanoidRootPart") and currentamount < amount and v2.Name ~= "Duck" then -- no duck
				local mag = (lplr.Character.HumanoidRootPart.Position - v2.HumanoidRootPart.Position).magnitude
				if mag <= distance then -- magcheck
					table.insert(returnedplayer, {Name = (v2 and v2.Name or "Monster"), UserId = 1443379645, Character = v2}) -- monsters are npcs so I have to create a fake player for target info
					currentamount = currentamount + 1
				end
			end
		end
	end
	return returnedplayer -- table of attackable entities
end

local function getEquipped()
    local typetext = ""
    local obj = (entity.isAlive and LocalPlayer.Character:FindFirstChild("HandInvItem") and LocalPlayer.Character.HandInvItem.Value or nil)
    if obj then
        if obj.Name:find("sword") or obj.Name:find("blade") or obj.Name:find("baguette") or obj.Name:find("scythe") or obj.Name:find("dao") then
            typetext = "sword"
        end
        if obj.Name:find("wool") then
            typetext = "block"
        end
        if obj.Name:find("bow") then
            typetext = "bow"
        end
    end
    return {["Object"] = obj, ["Type"] = typetext}
end

local function playSound(id, volume) 
	local sound = Instance.new("Sound")
	sound.Parent = workspace
	sound.SoundId = id
	sound.PlayOnRemove = true 
	if volume then 
		sound.Volume = volume
	end
	sound:Destroy()
end

local function playAnimation(id) 
	if lplr.Character.Humanoid.Health > 0 then 
		local animation = Instance.new("Animation")
		animation.AnimationId = id
		local animatior = lplr.Character.Humanoid.Animator
		animatior:LoadAnimation(animation):Play()
	end
end

local function getCurrentSword()
	local sword, swordslot, swordrank = nil, nil, 0
	for i5, v5 in pairs(modules.getCurrentInventory().items) do
		if v5.itemType:lower():find("sword") or v5.itemType:lower():find("blade") or v5.itemType:lower():find("dao") then
			if modules.ItemMeta[v5.itemType].sword.damage > swordrank then
				sword = v5
				swordslot = i5
				swordrank = modules.ItemMeta[v5.itemType].sword.damage
			end
		end
	end
	return sword, swordslot
end

local Window = Library.CreateLib("Novoline", theme)

local Tab = Window:NewTab("Combat")

local Section = Tab:NewSection("Combat")

Section:NewToggle("Sprint", "ButtonInfo", function(callback)
    if callback == true then
		task.spawn(function()
			repeat
				task.wait()
				if (not modules.SprintCont.sprinting) then
					modules.SprintCont:startSprinting()
				end
			until (not callback)
		end)
	else
		modules.SprintCont:stopSprinting()
	end
end)

local Section = Tab:NewSection("AutoClicker")

local ACC1
local ACC2
local Waittt = {["Value"] = 2}
local CPS = {Value = 20}
Section:NewToggle("AutoClicker", "ButtonInfo", function(callback)
	if callback == true then
		local holding = false
		ACC1 = UserInputService.InputBegan:connect(function(input, gameProcessed)
			if gameProcessed and input.UserInputType == Enum.UserInputType.MouseButton1 then
				holding = true
			end
		end)
		ACC2 = UserInputService.InputEnded:connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				holding = false
			end
		end)
		spawn(function()
			repeat
				task.wait(1/CPS["Value"])
				if holding then
					if holding == false then return end
					if getEquipped()["Type"] == "sword" then 
						if holding == false then return end
						modules.SwordController:swingSwordAtMouse()
					end
				end
			until (not v)
		end)
	else
		ACC1:Disconnect()
		ACC2:Disconnect()
		return
	end
end)
Section:NewSlider("CPS", "SliderInfo", 20, 0, function(v)
    CPS.Value = v
end)

local Section = Tab:NewSection("Velocity")

local Horizontal = {Value = 0}
local Vertical = {Value = 0}
func = modules.KnockbackUtil.applyKnockbackDirection
func2 = modules.KnockbackUtil.applyKnockback
Section:NewToggle("Velocity", "ButtonInfo", function(callback)
	if callback == true then
		modules.KnockbackUtil.applyKnockbackDirection = Horizontal.Value
		modules.KnockbackUtil.applyKnockback = Vertical.Value
	else
		modules.KnockbackUtil.applyKnockbackDirection = func
		modules.KnockbackUtil.applyKnockback = func2
	end
end)

Section:NewSlider("Horizontal", "SliderInfo", 500, 0, function(v)
    Horizontal.Value = v
end)

Section:NewSlider("Vertical", "SliderInfo", 500, 0, function(v)
    Vertical.Value = v
end)

local CombatConstant = require(ReplicatedStorage.TS.combat["combat-constant"]).CombatConstant

local Section = Tab:NewSection("Reach")

Section:NewToggle("Reach", "ButtonInfo", function(callback)
	getgenv().reachval = callback
	if getgenv().reachval then
		modules.CombatConstant.RAYCAST_SWORD_CHARACTER_DISTANCE = reachvalue["Value"]
	else
		modules.CombatConstant.RAYCAST_SWORD_CHARACTER_DISTANCE = 14.4
	end
end)
Section:NewSlider("Distance", "SliderInfo", 18, 0, function(v)
    reachvalue.Value = v
end)

local Tab = Window:NewTab("Blatant")

local Section = Tab:NewSection("Blatant")

Section:NewSlider("Speed", "SliderInfo", 23, 0, function(v)
	lplr.Character.Humanoid.WalkSpeed = v
end)

local Section = Tab:NewSection("HighJump")

local highjumpforce = {Value = 20}
Section:NewButton("HighJump", "ButtonInfo", function(callback)
print(callback)
        LocalPlayer.Character.Humanoid:ChangeState("Jumping")
        task.wait()
        highjumpforce.Value = highjumpforce.Value * 1.6
        spawn(function()
            for i = 1, highjumpforce.Value / 28 do
                wait()
                LocalPlayer.Character.Humanoid:ChangeState("Jumping")
            end
        end)
        spawn(function()
            for i = 1, highjumpforce.Value / 28 do
                task.wait(0.1)
                LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Freefall)
                task.wait(0.1)
                LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end)
end)

Section:NewSlider("Force", "SliderInfo", 100, 0, function(v)
	highjumpforce.Value = v
end)

local Section = Tab:NewSection("KillAura")

do
    local oldbs
    local conectionkillaura
    local animspeed = {Value = 0.3}
    local AttackSpeed = {Value = 15}
    local AutoRotate = {Value = true}
    local DistVal = {Value = 10}
    local origC0 = game.ReplicatedStorage.Assets.Viewmodel.RightHand.RightWrist.C0
    Section:NewButton("KillAura", "ButtonInfo", function(v)
            if v then
                spawn(function()
                    repeat
                        for i,v in pairs(game.Players:GetChildren()) do
                            wait(0.01)
                            if v.Character and v.Name ~= game.Players.LocalPlayer.Name and v.Character:FindFirstChild("HumanoidRootPart") then
                                local mag = (v.Character.HumanoidRootPart.Position - game.Players.LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
                                if mag <= DistVal.Value and v.Team ~= game.Players.LocalPlayer.Team and v.Character:FindFirstChild("Humanoid") and v.Character.Humanoid.Health > 0 then
                                    task.wait(1/AttackSpeed["Value"])
                                    --local PlayerSword = getEquipped()["Type"]
                                    --if getEquipped()["Type"] == "sword" then 
                                        if AutoRotate.Value == true then
                                            local targetPosition = v.Character.Head.Position
                                            local localPosition = LocalPlayer.Character.HumanoidRootPart.Position
                                            local lookVector = (targetPosition - localPosition).Unit
                                            local newYaw = math.atan2(-lookVector.X, -lookVector.Z)
                                            LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(localPosition) * CFrame.Angles(0, newYaw, 0)
                                        end
                                        modules.SwordController:swingSwordAtMouse()
                                    --end
                                end
                            end
                        end                    
                    until (not v)
                end)
            end
    end)
end
	Section:NewToggle("AutoRotate", "ButtonInfo", function(callback)
		AutoRotate.Value = callback
	end)
	Section:NewSlider("AttackSpeed", "SliderInfo", 20, 0, function(v)
		AttackSpeed.Value = v
	end)
	Section:NewSlider("AttackDistance", "SliderInfo", 15, 1, function(v)
		AttackDistance.Value = v
	end)

local Tab = Window:NewTab("Render")

local Section = Tab:NewSection("Render")

do
local SpawnParts = {}
Section:NewToggle("SpawnESP", "ButtonInfo", function(callback)
	if callback then 
			for i,v2 in pairs(workspace.MapCFrames:GetChildren()) do 
				if v2.Name:find("spawn") and v2.Name ~= "spawn" and v2.Name:find("respawn") == nil then
					local part = Instance.new("Part")
					part.Size = Vector3.new(1, 1000, 1)
					part.Position = v2.Value.p
					part.Anchored = true
					part.Parent = workspace
					part.CanCollide = false
					part.Transparency = 0.5
					part.Material = Enum.Material.Neon
					part.Color = Color3.new(1, 0, 0)
					remotes.QueryUtil:setQueryIgnored(part, true)
					table.insert(SpawnParts, part)
				end
			end
	else
		for i,v in pairs(SpawnParts) do v:Destroy() end
		table.clear(SpawnParts)
	end
end)
end

Section:NewToggle("Night", "ButtonInfo", function(callback)
	if callback then
		Lighting.TimeOfDay = "1:00:00"
	else
		Lighting.TimeOfDay = LightingTime
	end
end)

do
Section:NewToggle("RandomSkinColor", "ButtonInfo", function(callback)
	if callback then
		RainbowSkinVal = true
		while RainbowSkinVal and task.wait(0.1) do
			local player = game.Players.LocalPlayer
			local character = player.Character or player.CharacterAdded:Wait()
			for _,part in pairs(character:GetDescendants()) do
				if part:IsA("BasePart") then
					part.Color = Color3.new(math.random(), math.random(), math.random())
				end
			end
		end
	else
		RainbowSkinVal = false
	end
end)
end

local Section = Tab:NewSection("Fov")

oldFov = game.Workspace.Camera.FieldOfView
NewFov = {Value = 80}
Section:NewToggle("FOVChanger", "ButtonInfo", function(callback)
	if callback == true then
		game.Workspace.Camera.FieldOfView = NewFov.Value
	end
end)

Section:NewSlider("Value", "SliderInfo", 100, 70, function(v)
    NewFov.Value = v
    game.Workspace.Camera.FieldOfView = v
end)

local Tab = Window:NewTab("Utility")

local Section = Tab:NewSection("Utility")

Section:NewToggle("NoFall", "ButtonInfo", function(callback)
	if callback == true then
		task.spawn(function()
			repeat
				task.wait()
				modules.FallRemote:FireServer()
			until (not callback)
		end)
	end
end)

local tiered = {}
local nexttier = {}

for i,v in pairs(modules.ShopItems) do
    if type(v) == "table" then 
        if v.tiered then
            tiered[v.itemType] = v.tiered
        end
        if v.nextTier then
            nexttier[v.itemType] = v.nextTier
        end
    end
end

Section:NewToggle("ShopTierBypass", "ButtonInfo", function(callback)
	if callback == true then
	    for i,v in pairs(modules.ShopItems) do
	        if type(v) == "table" then 
	            v.tiered = nil
	            v.nextTier = nil
	        end
	    end
	else
	    for i,v in pairs(modules.ShopItems) do
	        if type(v) == "table" then 
	            if tiered[v.itemType] then
	                v.tiered = tiered[v.itemType]
	            end
	            if nexttier[v.itemType] then
	                v.nextTier = nexttier[v.itemType]
	            end
	        end
	    end
	 end
end)

Section:NewToggle("ScytheDisabler", "ButtonInfo", function(callback)
	if callback == true then
	    RunService.RenderStepped:Connect(function()
	
	        local args = {
	            [1] = {
	                ["direction"] = HumanoidRootPart.CFrame.LookVector
	            }
	        }
	    
	        if callback == true then
	        	if callback == false then return end
	            modules.ScytheDash:FireServer(unpack(args))
	        end
	
	    end)
	end
end)

Section:NewToggle("AFKFarm", "ButtonInfo", function(callback)
	if v then
		local char = game:GetService("Players").LocalPlayer.Character
		char:FindFirstChild("HumanoidRootPart").CFrame = char:FindFirstChild("HumanoidRootPart").CFrame + Vector3.new(0,99,0)
		char:FindFirstChild("Head").Anchored = true
		char:FindFirstChild("UpperTorso").Anchored = true
		char:FindFirstChild("UpperTorso").Anchored = true
	else
		local char = game:GetService("Players").LocalPlayer.Character
		char:FindFirstChild("HumanoidRootPart").CFrame = char:FindFirstChild("HumanoidRootPart").CFrame + Vector3.new(0,99,0)
		char:FindFirstChild("Head").Anchored = false
		char:FindFirstChild("UpperTorso").Anchored = false
		char:FindFirstChild("UpperTorso").Anchored = false
	end
end)

Section:NewToggle("AutoGuitar", "ButtonInfo", function(callback)
	if v then
		AutoGuitarVal = true
		while AutoGuitarVal and task.wait() do
			modules.GuitarController:FireServer({["targets"] = {}})
		end
	else
		AutoGuitarVal = false
	end
end)

local Tab = Window:NewTab("World")

local Section = Tab:NewSection("World")

local Section = Tab:NewSection("AntiVoid")

local antivoidpart
local antivoidparttransparency = {Value = 0}
--local AntiVoidJumpDelay = {Value = 10}
Section:NewToggle("AntiVoid", "ButtonInfo", function(callback)
	if callback == true then
            local antivoidpart = Instance.new("Part", Workspace)
            antivoidpart.Name = "AntiVoid"
            antivoidpart.Size = Vector3.new(2100, 0.5, 2000)
            antivoidpart.Position = Vector3.new(160.5, 25, 247.5)
            antivoidpart.Transparency = antivoidparttransparency.Value
            antivoidpart.Anchored = true
            antivoidpart.Touched:connect(function(thing)
                if thing.Parent:WaitForChild("Humanoid") and (thing.Parent == lplr.Character or thing.Parent.Parent == lplr.Character) then
                	Workspace.Gravity = 100
                    game.Players.LocalPlayer.Character.Humanoid:ChangeState("Jumping")
                    wait(0.1)
                    game.Players.LocalPlayer.Character.Humanoid:ChangeState("Jumping")
                    wait(0.1)
                    game.Players.LocalPlayer.Character.Humanoid:ChangeState("Jumping")
                    wait(0.1)
                    game.Players.LocalPlayer.Character.Humanoid:ChangeState("Jumping")
                    wait(0.1)
                    game.Players.LocalPlayer.Character.Humanoid:ChangeState("Jumping")
                    Workspace.Gravity = 197
                end
            end)
        else
            game.Workspace.AntiVoid:remove()
        end
end)

Section:NewSlider("Transparency", "SliderInfo", 10, 0, function(v)
	if v == 0 then
		antivoidparttransparency.Value = 0
	elseif v == 1 then
		antivoidparttransparency.Value = 0.1
	elseif v == 2 then
		antivoidparttransparency.Value = 0.2
	elseif v == 3 then
		antivoidparttransparency.Value = 0.3
	elseif v == 4 then
		antivoidparttransparency.Value = 0.4
	elseif v == 5 then
		antivoidparttransparency.Value = 0.5
	elseif v == 6 then
		antivoidparttransparency.Value = 0.6
	elseif v == 7 then
		antivoidparttransparency.Value = 0.7
	elseif v == 8 then
		antivoidparttransparency.Value = 0.8
	elseif v == 9 then
		antivoidparttransparency.Value = 0.9
	elseif v == 10 then
		antivoidparttransparency.Value = 1
	end
end)

local Section = Tab:NewSection("Gravity")

Section:NewToggle("Gravity", "ButtonInfo", function(callback)
	if callback == true then
	    workspace.Gravity = GravityValueBeb["Value"]
	else
	    workspace.Gravity = 196.19999694824
	end
end)
Section:NewSlider("Value", "SliderInfo", 200, 0, function(v)
	GravityValueBeb.Value = v
	workspace.Gravity = v
end)


local Tab = Window:NewTab("Info")

local Section = Tab:NewSection("Update!!")
