--!native
-- show the bodypart rotations to all

local shouldMoveArms = {}

local function rotateJoint(character,jointName : string,original : CFrame,rotation : number,extra : CFrame)
	if not character then
		return
	end
	if not extra then
		extra = CFrame.new()
	end
	if not character:FindFirstChild(jointName) then
		return
	end
	local joint : Motor6D = character:FindFirstChild(jointName):FindFirstChildOfClass("Motor6D")
	if not joint then
		return
	end
	joint.C0 = original * CFrame.Angles(rotation,0,0) * extra
end

local rightArmC0 = CFrame.new(1, 0.651, 0.06,1, 0, 0, 0, 1, 0, 0, 0, 1)
local leftArmC0 = CFrame.new(-1, 0.651, 0.06,1, 0, 0, 0, 1, 0, 0, 0, 1)
local function rotateArms(character : Model,neckRotation : number)
	local antiTorso : CFrame = CFrame.new()
	if neckRotation ~= 0 then
		antiTorso = character.UpperTorso.CFrame.Rotation:Inverse() * character:GetPivot().Rotation
		if not character:FindFirstChild("UpperTorso") then
			return
		end
		local waist = character:FindFirstChild("UpperTorso"):FindFirstChild("Waist");
		if not waist then
			return
		end
		antiTorso *= waist.C0 
	end
	
	rotateJoint(character,"RightUpperArm",rightArmC0,neckRotation,antiTorso)
	rotateJoint(character,"LeftUpperArm",leftArmC0,neckRotation,antiTorso)
end

local neckC0 = CFrame.new(0, 0.8, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1);
local function rotateNeck(character,neckRotation : number)
	rotateJoint(character,"Head",neckC0,neckRotation)
end

script:WaitForChild("ServerTilt").Event:Connect(function(character,neckRotation)
	neckRotation = math.clamp(neckRotation,-math.rad(90),math.rad(45))
	rotateNeck(character,neckRotation)
	rotateArms(character,neckRotation)
end)

game:GetService("ReplicatedStorage"):WaitForChild("Replication"):WaitForChild("NeckRot").OnServerEvent:Connect(function(player,neckRotation : number)
	if not player.Character then
		return
	end
	if not (player.Character:WaitForChild("Humanoid").Health > 0) then
		shouldMoveArms[player] = false
		return
	end
	
	neckRotation = math.clamp(neckRotation,-math.rad(90),math.rad(45))
	rotateNeck(player.Character,neckRotation)
	if shouldMoveArms[player] then
		rotateArms(player.Character,neckRotation)
	else
		rotateArms(player.Character,0)
	end
end)

script:WaitForChild("MoveArms").Event:Connect(function(player : Player,value : boolean)
	shouldMoveArms[player] = value
end)