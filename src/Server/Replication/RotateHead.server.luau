-- show the neck rotation to all
local neckC0 = CFrame.new(0, 0.8, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1);
local neckC1 = CFrame.new(0, -0.5, -0);
game:GetService("ReplicatedStorage"):WaitForChild("Replication"):WaitForChild("NeckRot").OnServerEvent:Connect(function(player,neckRotation : CFrame)
	local neck : Motor6D = player.Character:WaitForChild("Head"):WaitForChild("Neck")
	--neckRotation = math.clamp(neckRotation,math.rad(-75),math.rad(75))
	neck.C0 = neckC0 * neckRotation --* CFrame.fromEulerAnglesYXZ(neckRotation, 0, 0)
	--neck.C1 = neckC1 * neckRotation
end)
