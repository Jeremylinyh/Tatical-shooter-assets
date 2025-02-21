-- I am no longer allergic to making animations

local TS : TweenService = game:GetService("TweenService")

local gunstats = require(game:GetService("ReplicatedStorage"):WaitForChild("Weapon"):WaitForChild("GunStats"))

local currentlyEquipped : Model = {}
local lastEquippedTime = {}

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

local function setIKweight(thingy : IKControl,target : number)
	coroutine.wrap(function(thingy : IKControl,target : number)
		if not thingy.Enabled then
			thingy.Enabled = true
			thingy.Weight = 0

		end

		local goal = {}
		goal.Weight = target
		local tw : Tween = TS:Create(thingy,TweenInfo.new(0.1),goal)
		tw:Play()
		tw.Completed:Wait()
		wait()
		goal.Weight = target
		if target == 0 then
			--thingy.Enabled = false
		end
	end) (thingy,target)
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

local function drawWeapon(player : Player,gun : Model,goal : number)
	local leftIK : IKControl = player.Character:WaitForChild("Humanoid"):WaitForChild("IKLeft")
	leftIK.Target = gun:WaitForChild("Body"):WaitForChild("LeftHand")
	setIKweight(leftIK,goal)
	
	local rightIK : IKControl = player.Character:WaitForChild("Humanoid"):WaitForChild("IKRight")
	rightIK.Target = gun:WaitForChild("Body"):WaitForChild("RightHand")
	setIKweight(rightIK,goal)
	
	raiseWeapon(player,gun,goal == 1)
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
	if equipping then
		drawWeapon(player,gunType,1)
		wait(gunstats[gunType:GetAttribute("Type")].EquipTime)
		currentlyEquipped[player] = gunType
		
	else
		currentlyEquipped[player] = nil
		drawWeapon(player,gunType,0)
		wait(gunstats[gunType:GetAttribute("Type")].EquipTime)
	end
	--print(currentlyEquipped)
end)

script.Parent.OnInvoke = function(player : Player)
	return currentlyEquipped[player]
end

script.Parent.Parent:WaitForChild("LastEquippedTime").OnInvoke = function(player : Player)
	return lastEquippedTime[player]
end