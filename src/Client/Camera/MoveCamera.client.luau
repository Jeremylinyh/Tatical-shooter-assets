-- moves the camer to the position it is told to

local function moveToCFrame(goalCF : CFrame,smooth : boolean)
	local camera = workspace.CurrentCamera
	if smooth then
		local goal = {}
		goal.CFrame = goalCF
		
		local TI :TweenInfo = TweenInfo.new(0.1)
		
		local T : Tween = game:GetService("TweenService"):Create(camera,TI,goal)
		T:Play()
		T.Completed:Wait()
	end
	camera.CFrame = goalCF
end
game:GetService("ReplicatedStorage"):WaitForChild("KeepCameraAt"):WaitForChild("Location").OnClientEvent:Connect(moveToCFrame)