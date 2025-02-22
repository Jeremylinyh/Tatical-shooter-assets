-- Handles and animate the viewmodel

local RS : RunService = game:GetService("RunService")
local TS : TweenService = game:GetService("TweenService")
local UIS : UserInputService = game:GetService("UserInputService")

local viewmodelConnection = nil
local arms : Model = nil
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
--local recoilVelocity : number = 0
--local recoilAmount : number = 0

local recoil : number = 0
local spread : number = 0

local shotTimes = {}
local previousCFrame = CFrame.new()

local bulletRandom = Random.new() -- set seed for spread pattern?
local function applyRecoil() : number
	--recoilAmount += recoilVelocity
	--recoilVelocity -= recoilAmount
	local recoilAmount = 0
	local weaponStats = gunstats[currentWeapon:GetAttribute("Type")]
	for i,v in pairs(shotTimes) do
		local delta : number = time() - v
		delta *= weaponStats.RecoilTimeScale
			
		local base : number = weaponStats.RecoilBase
		local scale : number = math.pow(base,-delta)
		
		local trig : number = -math.cos(delta * weaponStats.RecoilCosinePeriod) + 1
		recoilAmount = math.max(trig*scale,recoilAmount)
	end
	return recoilAmount*math.lerp(weaponStats.RecoilMinScale,weaponStats.RecoilMaxScale,bulletRandom:NextNumber())
end

local function applySpread() : number
	return spread/2
end

local function process(delta : number)
	if not currentWeapon then
		return
	end
	
	local placeGunAt : CFrame = workspace.CurrentCamera.CFrame
	arms:PivotTo(placeGunAt)
	
	local newRecoil : number = applyRecoil()
	local newSpread : number = applySpread()
	workspace.CurrentCamera.CFrame *= CFrame.Angles((newRecoil-recoil)/3,newSpread-spread,0)
	spread = newSpread
	recoil = newRecoil
	placeGunAt *= CFrame.Angles(recoil,spread,0) * CFrame.new(0,0,recoil*1.6)
	--workspace.CurrentCamera.CFrame *= recoil
	
	placeGunAt *= pointingDownward.Value
	placeGunAt *= aimValue.Value
	placeGunAt *= CFrame.Angles(0,0,game:GetService("Players").LocalPlayer.PlayerScripts.Movement["EQ&sprint"].GetLeanAngle:Invoke()/2)
	
	previousCFrame = previousCFrame:Lerp(placeGunAt.Rotation,gunstats[currentWeapon:GetAttribute("Type")].WeaponSwayForce)
	currentWeapon:PivotTo(CFrame.new(placeGunAt.Position) * previousCFrame.Rotation)
end

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
		
		previousCFrame = workspace.CurrentCamera.CFrame
		
		if weapon:FindFirstChild("Holster") then
			weapon.Holster:Destroy()
		end
		if weapon:FindFirstChild("Head") then
			weapon.Head:Destroy()
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
		table.clear(shotTimes)
		--recoilVelocity = 0
		--recoilAmount = 0
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

script.Parent.Parent:WaitForChild("SetCurrentArm").Event:Connect(function(a)
	arms = a
end)

script.Parent.Parent:WaitForChild("Gunfire").Event:Connect(function(timeOfFire)
	table.insert(shotTimes,timeOfFire)
	spread = 0-- 1 *(bulletRandom:NextNumber()-0.5)/3
	wait(1)
	table.remove(shotTimes,table.find(shotTimes,timeOfFire))
end)

script.Parent.Parent:WaitForChild("GetCurrentRecoil").OnInvoke = function()
	return previousCFrame.Rotation
end

script.Parent.OnInvoke = UnholsterWeapon