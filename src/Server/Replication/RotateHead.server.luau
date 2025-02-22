--!native
-- show the bodypart rotations to all

local shouldMoveArms : boolean = false

local function rotateJoint(player,jointName : string,original : CFrame,rotation : number,extra : CFrame)
	if not extra then
		extra = CFrame.new()
	end
	local joint : Motor6D = player.Character:WaitForChild(jointName):FindFirstChildOfClass("Motor6D")
	joint.C0 = original * CFrame.Angles(rotation,0,0) * extra
end

local rightArmC0 = CFrame.new(1, 0.651, 0.06,1, 0, 0, 0, 1, 0, 0, 0, 1)
local leftArmC0 = CFrame.new(-1, 0.651, 0.06,1, 0, 0, 0, 1, 0, 0, 0, 1)
local function rotateArms(player,neckRotation : number)
	local antiTorso : CFrame = player.Character.UpperTorso.CFrame.Rotation:Inverse() * player.Character:GetPivot().Rotation
	rotateJoint(player,"RightUpperArm",rightArmC0,neckRotation,antiTorso)
	rotateJoint(player,"LeftUpperArm",leftArmC0,neckRotation,antiTorso)
end

local neckC0 = CFrame.new(0, 0.8, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1);
local function rotateNeck(player,neckRotation : number)
	rotateJoint(player,"Head",neckC0,neckRotation)
end

game:GetService("ReplicatedStorage"):WaitForChild("Replication"):WaitForChild("NeckRot").OnServerEvent:Connect(function(player,neckRotation : number)
	if not player.Character then
		return
	end
	if not (player.Character:WaitForChild("Humanoid").Health > 0) then
		shouldMoveArms = false
		return
	end
	
	neckRotation = math.clamp(neckRotation,-math.rad(90),math.rad(45))
	rotateNeck(player,neckRotation)
	if shouldMoveArms then
		rotateArms(player,neckRotation)
	else
		rotateArms(player,0)
	end
end)

script:WaitForChild("MoveArms").Event:Connect(function(value : boolean)
	shouldMoveArms = value
end)