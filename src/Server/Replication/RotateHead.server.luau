-- show the neck rotation to all
local neckC0 = CFrame.new(0, 0.8, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1);
game:GetService("ReplicatedStorage"):WaitForChild("Replication"):WaitForChild("NeckRot").OnServerEvent:Connect(function(player,neckRotation : number)
	neckRotation = math.clamp(neckRotation,-math.rad(90),math.rad(45))
	if not player.Character then
		return
	end
	local neck : Motor6D = player.Character:WaitForChild("Head"):WaitForChild("Neck")
	neck.C0 = neckC0 * CFrame.Angles(neckRotation,0,0) 
end)
