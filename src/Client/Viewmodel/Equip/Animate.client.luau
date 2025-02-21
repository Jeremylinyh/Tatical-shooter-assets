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

local hipCF = CFrame.new(0.36,-0.1,0)
local cantCF = CFrame.new(-0.36,-0.1,0) * CFrame.Angles(0,0,math.rad(45))
local hipfireCF : CFrameValue = Instance.new("CFrameValue")
hipfireCF.Value = hipCF

local aimValue : CFrameValue = Instance.new("CFrameValue")
aimValue.Value = hipfireCF.Value

local hipPosTween : Tween = nil
local aimTween : Tween = nil

local currentWeapon : Model

local function IsAiming() : string
	if not currentWeapon then
		return false
	end
	if (aimValue.Value == CFrame.new()) then
		return currentWeapon:GetAttribute("Type")
	else
		return false
	end
end
script.Parent.Parent:WaitForChild("IsAiming").OnInvoke = IsAiming

local function process(delta : number)
	if not currentWeapon then
		return
	end
	
	local placeGunAt : CFrame = workspace.CurrentCamera.CFrame
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
	-- forward this to the server
	game:GetService("ReplicatedStorage"):WaitForChild("GunEvent"):WaitForChild("ChangeInEquipped"):FireServer(equip,weapon.Name)
	
	local weaponClass:string = weapon:GetAttribute("Type")
	equipSpeed = gunstats[weaponClass].EquipTime 
	
	if equip and not viewmodelConnection then
		--weapon.Holster.Enabled = false
		viewmodelConnection = RS.PreRender:Connect(process)
		arms.Parent = game.Workspace
		currentWeapon = (weapon)
		
		if currentWeapon:FindFirstChild("Holster") then
			currentWeapon:WaitForChild("Holster"):Destroy()
			currentWeapon:WaitForChild("Head"):Destroy()
		end
		
		weapon.Parent = workspace
		influenza(0)
	elseif viewmodelConnection then
		
		influenza(math.rad(-90))
		currentWeapon = (nil)
		--weapon.Holster.Enabled = true
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
	if target == CFrame.new() then
		-- goal is to aim
		script.Parent.Parent.AimChanged:Fire(currentWeapon:GetAttribute("Type"))
	else
		script.Parent.Parent.AimChanged:Fire(nil)
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

local function changeHip(target : CFrame)
	if not currentWeapon then
		return
	end

	if hipPosTween then
		hipPosTween:Cancel()
	end

	local goal = {}
	goal.Value = target

	local weaponClass:string = currentWeapon:GetAttribute("Type")
	local aimTime : number = gunstats[weaponClass].AimTime

	hipPosTween = TS:Create(hipfireCF,TweenInfo.new(aimTime),goal)
	hipPosTween:Play()
	hipPosTween.Completed:Wait()
	
	if not IsAiming() then
		changeAim(hipfireCF.Value)
	end
end



UIS.InputBegan:Connect(function(input,gp)
	if input.KeyCode == Enum.KeyCode.T or input.UserInputType == Enum.UserInputType.MouseButton2 then
		changeAim(CFrame.new())
	elseif input.KeyCode == Enum.KeyCode.B then
		if hipfireCF.Value == hipCF then
			changeHip(cantCF)
		else
			changeHip(hipCF)
		end
	
	end
end)

UIS.InputEnded:Connect(function(input,gp)
	if input.KeyCode == Enum.KeyCode.T or input.UserInputType == Enum.UserInputType.MouseButton2 then
		changeAim(hipfireCF.Value)
	end
end)

script.Parent.OnInvoke = UnholsterWeapon