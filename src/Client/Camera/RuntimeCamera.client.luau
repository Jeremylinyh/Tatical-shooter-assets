-- makes camera follow head, and process camera related input

local UIS : UserInputService = game:GetService("UserInputService")

local neckC0 = CFrame.new(0, 0.8, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1);
local neckRotation : number = 0
local replicateNeck : RBXScriptConnection = game:GetService("RunService").PostSimulation:Connect(function(delta)
	local currentY = workspace.CurrentCamera.CFrame.LookVector.Y
	local currentAngle : number = math.asin(currentY)
	game:GetService("ReplicatedStorage"):WaitForChild("Replication"):WaitForChild("NeckRot"):FireServer(currentAngle)
end)

local castVoteEvent : RemoteEvent = game:GetService("ReplicatedStorage"):WaitForChild("Vote").StartGame
-- gets everything ready on the client side
castVoteEvent.OnClientEvent:Connect(function()
	local player = game:GetService("Players").LocalPlayer
	player.Character:WaitForChild("Humanoid").Died:Connect(function()
		replicateNeck:Disconnect()
	end)
	local camera = workspace.CurrentCamera
	camera.CameraType = Enum.CameraType.Custom
	player.CameraMode = Enum.CameraMode.LockFirstPerson
	UIS.MouseIconEnabled = false
	UIS.MouseBehavior = Enum.MouseBehavior.LockCenter
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