-- Equip/unequip the intended weapon

local UIS : UserInputService = game:GetService("UserInputService")

local connection : RBXScriptConnection = nil
local primaryKeycode : Enum.KeyCode = Enum.KeyCode.One
local secondaryKeycode : Enum.KeyCode = Enum.KeyCode.Two

local Equipped = {} -- Enum
Equipped.None = 0
Equipped.Primary = 1
Equipped.Secondary = 2

local currentlyEquipped : Equipped = Equipped.None

local currentlyProcessing : boolean = false -- disallow input while performing the action

-- This function must wait until weapon is fully done animating before returning!!!
local function equipWeapon(object : Equipped,equipping : boolean)
	if equipping then
		currentlyEquipped = object
	else
		currentlyEquipped = Equipped.None
	end
	-- TODO: implement
	print(equipping,object,currentlyEquipped)
end

local function primaryExist() : boolean
	return true
end

local function secondaryExist() : boolean 
	return false
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

local function EntryPointLogic(mainly : Equipped, secondly : Equipped) -- shameless admiration
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
end

local function processInput(input : InputObject,gp)
	if gp or currentlyProcessing then
		return
	end
	
	currentlyProcessing = true
	
	if input.KeyCode == primaryKeycode then
		EntryPointLogic(Equipped.Primary,Equipped.Secondary)
	elseif input.KeyCode == secondaryKeycode then
		EntryPointLogic(Equipped.Secondary,Equipped.Primary)
	end
	
	currentlyProcessing = false
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