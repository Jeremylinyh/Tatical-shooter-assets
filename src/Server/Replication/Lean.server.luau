-- replicates player leaning

local LeanEvent = game:GetService('ReplicatedStorage'):WaitForChild("Replication"):WaitForChild("LeanAngle")

local waistC0 = CFrame.new(0, 0.2, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1);

LeanEvent.OnServerEvent:Connect(function(player,tilt)
	if tilt and tonumber(tilt) then
		local eqlean = -tonumber(tilt)/2
		local neck = player.Character.Head.Neck;
		local waist = player.Character.UpperTorso.Waist;
		waist.C0 = waistC0 * CFrame.fromEulerAnglesYXZ(0, 0, eqlean);

	end
end)