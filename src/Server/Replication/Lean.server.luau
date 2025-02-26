-- replicates player leaning

local LeanEvent = game:GetService('ReplicatedStorage'):WaitForChild("Replication"):WaitForChild("LeanAngle")

local waistC0 = CFrame.new(0, 0.2, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1);

LeanEvent.OnServerEvent:Connect(function(player,tilt)
	if not player then
		return
	end
	if not player.Character then
		return
	end
	if tilt and tonumber(tilt) then
		local eqlean = -tonumber(tilt)/2
		--local neck = player.Character:WaitForChild("Head"):WaitForChild("Neck")
		local waist = player.Character:WaitForChild("UpperTorso"):WaitForChild("Waist")
		local lowerTorsoUp : number = math.round(player.Character.LowerTorso.CFrame.UpVector.Y)
		--print((1-lowerTorsoUp),lowerTorsoUp)
		waist.C0 = waistC0 * CFrame.fromEulerAnglesYXZ(0,0, lowerTorsoUp*eqlean);
		--neck.C0 = neckC0 * CFrame.Angles(0,0,lowerTorsoUp*(1-eqlean));
		--waist.C0 *= player.Character.LowerTorso.CFrame.Rotation:Inverse()
		--waist.C0 *= player.Character:GetPivot().Rotation

	end
end)