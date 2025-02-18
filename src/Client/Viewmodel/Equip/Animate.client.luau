-- Handles and animate the viewmodel

local RS : RunService = game:GetService("RunService")
local TS : TweenService = game:GetService("TweenService")
local viewmodelConnection = nil
local arms : Model = script.Parent.Parent:WaitForChild("Arms")
local LeftIK : IKControl = arms:WaitForChild("Humanoid"):WaitForChild("Left")
local RightIK : IKControl = arms:WaitForChild("Humanoid"):WaitForChild("Right")
local equipSpeed : number = 1 --TODO: gloabalize

local function process(delta : number)
	local camera = workspace.CurrentCamera
	if not camera then
		return
	end
	
	local placeArmAt : CFrame = camera.CFrame
	placeArmAt += camera.CFrame.LookVector * 0.3
	
	arms:PivotTo(placeArmAt)
end

-- increase the influence of the IK
local function influenzahelper(IK : IKControl , finish: number)
	IK.Enabled = true
	local TI : TweenInfo = TweenInfo.new(equipSpeed)
	
	local goal = {}
	goal.Weight = finish
	
	local tween : Tween = TS:Create(IK,TI,goal)
	tween:Play()
	if goal == 0 then
		tween.Completed:Wait()
		IK.Enabled = false
	end
end

local function influenza(goal : number)
	influenzahelper(LeftIK,goal)
	influenzahelper(RightIK,goal)
end

-- true : draw | false : holster
script.Parent.Event:Connect(function(equip : boolean)
	if equip and not viewmodelConnection then
		viewmodelConnection = RS.PreRender:Connect(process)
		arms.Parent = game.Workspace
		influenza(1)
	elseif viewmodelConnection then
		viewmodelConnection:Disconnect()
		arms.Parent = script.Parent.Parent
		influenza(0)
	end
end)

-- TODO: remove
script.Parent.Parent.ClothingDone.Event:Connect(function()
	script.Parent:Fire(true)
end)
