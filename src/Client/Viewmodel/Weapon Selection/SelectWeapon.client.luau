-- Equip/unequip the intended weapon

local UIS : UserInputService = game:GetService("UserInputService")

local gunstats = require(game:GetService("ReplicatedStorage"):WaitForChild("Weapon"):WaitForChild("GunStats"))

local connection : RBXScriptConnection = nil
local primaryKeycode : Enum.KeyCode = Enum.KeyCode.One
local secondaryKeycode : Enum.KeyCode = Enum.KeyCode.Two

local Equipped = {} -- Enum
Equipped.None = 0
Equipped.Primary = 1
Equipped.Secondary = 2

local currentlyEquipped : Equipped = Equipped.None

local currentlyProcessing : boolean = false -- disallow input while performing the action

local function weaponClassValid(class : string) : boolean
	return class ~= nil 
end

local primary
local secondary
local function getWeapon(from : Equipped) : string
	local weapon : Model = nil
	local character : Model = game:GetService("Players").LocalPlayer.Character
	if not character then
		return nil
	end
	
	if from == Equipped.Primary then
		weapon = character:FindFirstChild("Primary") or primary
	else
		weapon = character:FindFirstChild("Secondary") or secondary
	end
	
	if from  == Equipped.None or (not weapon) or (not table.find(weapon:GetTags(),"Firearm")) then
		return nil
	end
	
	return weapon
end

-- This function must wait until weapon is fully done animating before returning!!!
local function equipWeapon(slot : Equipped,equipping : boolean)
	local object = getWeapon(slot)
	
	if (not object) or not weaponClassValid(object:GetAttribute("Type")) then
		return
	end
	
	script.Parent.Parent.Equip:Invoke(equipping,object)
	
	if equipping then
		currentlyEquipped = slot
	else
		currentlyEquipped = Equipped.None
	end
	
	
	--print(equipping,object:GetAttribute("Type"),currentlyEquipped)
end

local function primaryExist() : boolean
	return true
end

local function secondaryExist() : boolean 
	return true
end

local function currentOneExist(main : Equipped) : boolean
	if main == Equipped.None then
		return false
	end
	
	if main == Equipped.Primary then
		return primaryExist()
	else
		return secondaryExist()
	end
end

game:GetService("ReplicatedStorage"):WaitForChild("GunEvent"):WaitForChild("CurrentGunChanged").OnClientEvent:Connect(function()
	primary = getWeapon(Equipped.Primary) or primary
	secondary = getWeapon(Equipped.Secondary) or secondary
end)

local function EntryPointLogic(mainly : Equipped, secondly : Equipped) -- shameless admiration
	currentlyProcessing = true
	
	if currentlyEquipped == Equipped.None then
		if currentOneExist(mainly) then
			-- draw primary
			equipWeapon(mainly,true)
		elseif currentOneExist(secondly) then
			-- draw secondary
			equipWeapon(secondly,true)
		end
	elseif currentlyEquipped == mainly and currentOneExist(mainly) then
		-- unequip primary
		equipWeapon(mainly,false)
	elseif currentlyEquipped == secondly then
		if currentOneExist(secondly) then
			equipWeapon(secondly,false)
		end
		if currentOneExist(mainly) then
			-- swap from secondary to primary
			equipWeapon(mainly,true)
		end
	end
	
	currentlyProcessing = false
end

local function processInput(input : InputObject,gp)
	if gp or currentlyProcessing then
		--print("blocked")
		return
	end
	
	if input.KeyCode == primaryKeycode then
		EntryPointLogic(Equipped.Primary,Equipped.Secondary)
		currentlyProcessing = false
		return
	elseif input.KeyCode == secondaryKeycode then
		EntryPointLogic(Equipped.Secondary,Equipped.Primary)
		currentlyProcessing = false
		return
	end
end

script.Parent.OnOffSwitch.Event:Connect(function(turnOn : boolean)
	if connection then
		connection:Disconnect()
	end
	if turnOn then
		connection = UIS.InputBegan:Connect(processInput)
	end
end)

game:GetService("ReplicatedStorage"):WaitForChild("Vote"):WaitForChild("StartGame").OnClientEvent:Connect(function()
	script.Parent.OnOffSwitch:Fire(true)
end)