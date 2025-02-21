-- ragdolls any character sent it's way

local constraintType : string = "BallSocketConstraint" --"HingeConstraint"

local function addBallSocketTo(character : model)
	local humanoid : Humanoid = character:WaitForChild("Humanoid")
	humanoid:ChangeState(Enum.HumanoidStateType.Physics)
	
	for i, bodypart in pairs(character:GetChildren()) do
		local weld : Motor6D = bodypart:FindFirstChildOfClass("Motor6D")
		--print(weld)
		for i,v in pairs(bodypart:GetChildren()) do
			if v:IsA("Attachment") then
				--print(v.CFrame.Rotation)
				v.CFrame = CFrame.new(v.CFrame.Position)
				--print(v,v.CFrame.Rotation)
			end
		end
		if weld and not bodypart:FindFirstChildOfClass(constraintType) then
			if not bodypart:FindFirstChildOfClass("HingeConstraint") then
				local firstatt = Instance.new("Attachment")
				firstatt.Parent = weld.Part0
				firstatt.CFrame = weld.C0

				local secatt = Instance.new("Attachment")
				secatt.Parent = weld.Part1
				secatt.CFrame = weld.C1

				local ball = Instance.new(constraintType)
				ball.Attachment0 = firstatt
				ball.Attachment1 = secatt

				bodypart.CanCollide = true
				bodypart.CanTouch = false
				bodypart.CanQuery = true
				bodypart.CollisionGroup = "Debris"
				--ball.Active = true
				ball.Parent = bodypart
				ball.Enabled = true
			end
			
			
			--bodypart.CollisionGroup = "Default"

			--bodypart:SetNetworkOwnershipAuto()
			--bodypart:SetNetworkOwner(nil)
			weld.Enabled = false
		end
	end
end

-- anchors everything
local function anchorAll(character : Model)
	--print(character)
	for i, bodypart in pairs(character:GetChildren()) do
		if bodypart:IsA("MeshPart") or bodypart:IsA("BasePart") then
			bodypart.Anchored = true
		end
	end
end

-- assumes ragdoll happend
local function unRagdoll(character : Model,original : string)
	local humanoid : Humanoid = character:WaitForChild("Humanoid")
	humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
	
	for i, bodypart in pairs(character:GetChildren()) do
		local weld : Motor6D = bodypart:FindFirstChildOfClass("Motor6D")
		local custom = bodypart:FindFirstChildOfClass(constraintType)
		if custom then
			weld.Enabled = true
			custom.Attachment0:Destroy()
			custom.Attachment1:Destroy()
			custom:Destroy()
			bodypart.CollisionGroup = original
		end
	end
end

script.Parent:WaitForChild("RagdollCharacter").Event:Connect(function(character : Model,undo : number)
	local original = character:FindFirstChildOfClass("MeshPart").CollisionGroup
	
	
	addBallSocketTo(character)
	
	if undo and undo > 0 then
		if original == "Debris" then
			return
		end
		wait(undo)
		unRagdoll(character,original)
	else
		wait(30)
		anchorAll(character)
		return
	end
end)
