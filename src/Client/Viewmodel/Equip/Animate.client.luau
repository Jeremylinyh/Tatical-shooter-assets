-- Handles and animate the viewmodel

local RS : RunService = game:GetService("RunService")
local TS : TweenService = game:GetService("TweenService")
local UIS : UserInputService = game:GetService("UserInputService")

local viewmodelConnection = nil
local arms : Model = script.Parent.Parent:WaitForChild("Arms")
local equipSpeed : number = 1000 
local gunstats = require(game:GetService("ReplicatedStorage"):WaitForChild("Weapon"):WaitForChild("GunStats"))

local pointingDownward : CFrameValue = Instance.new("CFrameValue")
pointingDownward.Value = CFrame.Angles(math.rad(-90),0,0)

local hipfireCF = CFrame.new(0.36,-0.1,0)
local aimValue : CFrameValue = Instance.new("CFrameValue")
aimValue.Value = hipfireCF

local aimTween : Tween = nil

local currentWeapon : Model

local function process(delta : number)
	if not currentWeapon then
		return
	end
	
	local camera = workspace.CurrentCamera
	if not camera then
		return
	end
	
	local placeGunAt : CFrame = camera.CFrame
	placeGunAt *= pointingDownward.Value
	placeGunAt *= aimValue.Value
	
	currentWeapon:PivotTo(placeGunAt)
end

local function influenza(goal : number)
	local target = {}
	target.Value = CFrame.Angles(goal,0,0)
	
	local tween : Tween = TS:Create(pointingDownward,TweenInfo.new(equipSpeed),target)
	tween:Play()
	tween.Completed:Wait()
end

-- true : draw | false : holster
local function UnholsterWeapon(equip : boolean,weapon : Model)
	local weaponClass:string = weapon:GetAttribute("Type")
	equipSpeed = gunstats[weaponClass].EquipTime 
	
	if equip and not viewmodelConnection then
		weapon.Holster.Enabled = false
		viewmodelConnection = RS.PreRender:Connect(process)
		arms.Parent = game.Workspace
		currentWeapon = (weapon)
		weapon.Parent = workspace
		influenza(0)
	elseif viewmodelConnection then
		
		influenza(math.rad(-90))
		currentWeapon = (nil)
		weapon.Holster.Enabled = true
		if viewmodelConnection then
			viewmodelConnection:Disconnect()
			viewmodelConnection = nil
			
		end
		
		weapon.Parent = script.Parent.Parent
		arms.Parent = script.Parent.Parent
		
	end
	--print("done")
	return
end

local function changeAim(target : CFrame)
	if not currentWeapon then
		return
	end
	
	if aimTween then
		aimTween:Cancel()
	end
	
	local goal = {}
	goal.Value = target
	
	local weaponClass:string = currentWeapon:GetAttribute("Type")
	local aimTime : number = gunstats[weaponClass].AimTime
	
	aimTween = TS:Create(aimValue,TweenInfo.new(aimTime),goal)
	aimTween:Play()
end

UIS.InputBegan:Connect(function(input,gp)
	if input.KeyCode == Enum.KeyCode.T or input.UserInputType == Enum.UserInputType.MouseButton2 then
		changeAim(CFrame.new())
	end
end)

UIS.InputEnded:Connect(function(input,gp)
	if input.KeyCode == Enum.KeyCode.T or input.UserInputType == Enum.UserInputType.MouseButton2 then
		changeAim(hipfireCF)
	end
end)

script.Parent.OnInvoke = UnholsterWeapon