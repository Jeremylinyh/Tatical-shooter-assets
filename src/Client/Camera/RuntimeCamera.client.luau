-- makes camera follow head, and process camera related input

local UIS : UserInputService = game:GetService("UserInputService")

local castVoteEvent : RemoteEvent = game:GetService("ReplicatedStorage"):WaitForChild("Vote").StartGame
-- gets everything ready on the client side
castVoteEvent.OnClientEvent:Connect(function()
	local player = game:GetService("Players").LocalPlayer
	local camera = workspace.CurrentCamera
	camera.CameraType = Enum.CameraType.Custom
	player.CameraMode = Enum.CameraMode.LockFirstPerson
	UIS.MouseIconEnabled = false
	UIS.MouseBehavior = Enum.MouseBehavior.LockCenter
end)

local neckC0 = CFrame.new(0, 0.8, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1);
local neckRotation : number = 0
game:GetService("RunService").RenderStepped:Connect(function(delta)
	--local player : Player = game:GetService("Players").LocalPlayer
	--workspace.CurrentCamera.CFrame = 
		--game:GetService("Players").LocalPlayer.Character:WaitForChild("Head").CFrame
	--local neck : Motor6D = player.Character:WaitForChild("Head"):WaitForChild("Neck")
	--neck.C0 = neckC0 * CFrame.fromEulerAnglesYXZ(neckRotation, 0, 0)
end)


UIS.InputChanged:Connect(function(input : InputObject,gp)
	if gp then
		return
	end
	local delta : Vector2 = -input.Delta/100
	local player : Player = game:GetService("Players").LocalPlayer
	neckRotation += delta.Y
	neckRotation = math.clamp(neckRotation,math.rad(-75),math.rad(75))
	--player.Character:PivotTo(player.Character:GetPivot() * CFrame.Angles(0,delta.X,0))
	--game:GetService("ReplicatedStorage"):WaitForChild("Replication"):WaitForChild("NeckRot"):FireServer(workspace.CurrentCamera.CFrame.Rotation)--*player.Character:WaitForChild("Head").CFrame:Inverse())
end)