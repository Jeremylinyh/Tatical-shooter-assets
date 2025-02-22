-- I am no longer allergic to making animations

local TS : TweenService = game:GetService("TweenService")

local gunstats = require(game:GetService("ReplicatedStorage"):WaitForChild("Weapon"):WaitForChild("GunStats"))
local helper = require(game:GetService("ReplicatedStorage"):WaitForChild("Helper"))

local currentlyEquipped : Model = {}
local lastEquippedTime = {}
local playerArms = {}
local playerAnimations = {}

local function gunAtSlotStat(player : Player,slot : string) : Model
	if not player then
		return false
	end
	if not player.Character then
		return false
	end
	local gun = player.Character:FindFirstChild(slot)
	if not gun then
		return false
	end
	return gun
end

local function raiseWeapon(player : Player,gun : Model,raise)
	if raise then
		gun:WaitForChild("Holster").Enabled = false
		gun:WaitForChild("Head").Enabled = true
		gun:WaitForChild("Head").Attachment1 = player.Character.Head.FaceCenterAttachment
	else
		gun:WaitForChild("Holster").Enabled = true
		gun:WaitForChild("Head").Enabled = false
	end
end

local function drawWeapon(player : Player,gun : Model,equipping : boolean)
	-- move gun to face
	
	-- play animations
	local animID = gunstats[gun:GetAttribute("Type")].AnimationIDhold
	if not playerAnimations[player] then
		playerAnimations[player] = {}
	end
	if not playerAnimations[player][animID] then
		playerAnimations[player][animID] = helper.loadAnimationFromID(135789080814808,player.Character.Humanoid.Animator,Enum.AnimationPriority.Action4)
	end
	if equipping then
		playerAnimations[player][animID]:Play()
		gun:WaitForChild("Holster").Enabled = false
		gun:WaitForChild("Head").Enabled = true
		gun:WaitForChild("Head").Attachment1 = player.Character:WaitForChild("RightHand"):WaitForChild("RightGripAttachment")
	else
		playerAnimations[player][animID]:Stop()
		gun:WaitForChild("Holster").Enabled = true
		gun:WaitForChild("Head").Enabled = false
	end
	game:GetService("ServerScriptService"):WaitForChild("Replication"):WaitForChild("RotateHead"):WaitForChild("MoveArms"):Fire(equipping)
end

game:GetService("ReplicatedStorage"):WaitForChild("GunEvent"):WaitForChild("ChangeInEquipped").OnServerEvent:Connect(function(player,equipping,slot)
	if not player.Character then
		return
	end
	
	lastEquippedTime[player] = time()
	
	local gunType = gunAtSlotStat(player,slot)
	if not gunType or (not gunstats[gunType:GetAttribute("Type")]) then
		currentlyEquipped[player] = nil
		return
	end
	
	drawWeapon(player,gunType,equipping)
	if equipping then
		--game:GetService("ServerScriptService"):WaitForChild("Replication"):WaitForChild("RotateHead"):WaitForChild("MoveArms"):Fire(equipping)
		wait(gunstats[gunType:GetAttribute("Type")].EquipTime)
		currentlyEquipped[player] = gunType
		
	else
		currentlyEquipped[player] = nil
		wait(gunstats[gunType:GetAttribute("Type")].EquipTime)
		--game:GetService("ServerScriptService"):WaitForChild("Replication"):WaitForChild("RotateHead"):WaitForChild("MoveArms"):Fire(equipping)
		
	end
	--print(currentlyEquipped)
end)

script.Parent.OnInvoke = function(player : Player)
	return currentlyEquipped[player]
end

script.Parent.Parent:WaitForChild("LastEquippedTime").OnInvoke = function(player : Player)
	return lastEquippedTime[player]
end