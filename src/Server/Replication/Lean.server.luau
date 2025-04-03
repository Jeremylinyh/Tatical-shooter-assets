-- replicates player leaning

local LeanEvent = game:GetService('ReplicatedStorage'):WaitForChild("Replication"):WaitForChild("LeanAngle")

local waistC0 = CFrame.new(0, 0.2, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1);

local function processLean(character : Model,tilt)
	if not character or not character:FindFirstChild("Humanoid") then
		return
	end
	
	if tilt and tonumber(tilt) then
		local eqlean = -tonumber(tilt)/2
		--local neck = player.Character:WaitForChild("Head"):WaitForChild("Neck")
		if not character:FindFirstChild("UpperTorso") then
			return
		end
		local waist = character.UpperTorso:FindFirstChild("Waist")
		if not waist then
			return
		end
		local lowerTorsoUp : number = math.round(character.LowerTorso.CFrame.UpVector.Y)
		--print((1-lowerTorsoUp),lowerTorsoUp)
		waist.C0 = waistC0 * CFrame.fromEulerAnglesYXZ(0,0, lowerTorsoUp*eqlean);
		--neck.C0 = neckC0 * CFrame.Angles(0,0,lowerTorsoUp*(1-eqlean));
		--waist.C0 *= player.Character.LowerTorso.CFrame.Rotation:Inverse()
		--waist.C0 *= player.Character:GetPivot().Rotation

	end
end

LeanEvent.OnServerEvent:Connect(function(player,tilt)
	if not player then
		return
	end
	if not player.Character then
		return
	end
	processLean(player.Character,tilt)
end)

script.Parent:WaitForChild("SetNPClean").Event:Connect(processLean)