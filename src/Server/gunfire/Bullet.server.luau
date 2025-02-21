-- handles bullets being fired

local Debris : Debris = game:GetService("Debris")
local TweenService : TweenService = game:GetService("TweenService")
local CS : CollectionService = game:GetService("CollectionService")
local TweenService : TweenService = game:GetService("TweenService")

local GunTag : string = "Firearm"

local gunstats = require(game:GetService("ReplicatedStorage"):WaitForChild("Weapon"):WaitForChild("GunStats"))

local function getPlayerCurrentGun(player : Player) : Model
	return script.Parent:WaitForChild("GetCurrentGunType"):Invoke(player)
end

local function isReloading(player : Player) : boolean
	return false -- TODO: implement
end

local function lastFiredWithinReasonableTime(player : Player, playerCurrentGun : Model) : boolean
	return playerCurrentGun:GetAttribute("Magazine") > 0
end

local function allowedToFire(player : Player, currentWeapon : Model) : boolean
	return true 
end

local function gunIsFullyDrawn(player : Player,gun : Model) : boolean
	local drawnTime : number = script.Parent:WaitForChild("LastEquippedTime"):Invoke(player)
	local neededTime :number = gunstats[gun:GetAttribute("Type")].EquipTime
	return (time()-drawnTime) > neededTime
end

local function prefireChecksPassed(player : Player, playerCurrentGun : Model) : boolean
	if not playerCurrentGun or (not gunstats[playerCurrentGun:GetAttribute("Type")]) then
		return false
	end
	if not player:IsA("Player") then
		return false
	end

	if isReloading(player) then
		return false
	end

	if not lastFiredWithinReasonableTime(player,playerCurrentGun) then
		return false
	end

	if not allowedToFire(player,playerCurrentGun) then
		return false
	end


	if not gunIsFullyDrawn(player,playerCurrentGun) then
		return false
	end
	
	return true
end

local function thereAreBulletsInMagazine() : boolean
	return true
end
-- false = halt
local function beganReload(began : boolean)
	
end

local function handleWindowHit(raycastResult : RaycastResult)
	--local hitwindow = true
	--local sizex = raycastResult.Instance.Size.X
	--local sizey = raycastResult.Instance.Size.Y

	--local glassdimensions = math.round(((sizex+sizey)/2) /3)

	--for x = -sizex/glassdimensions, sizex/glassdimensions do

	--	for y = -sizey/glassdimensions, sizey/glassdimensions do
	--		--print("shatter")
	--		local glass = raycastResult.Instance:Clone()
	--		glass.Size = Vector3.new(glassdimensions/2,glassdimensions/2,raycastResult.Instance.Size.Z/6) --raycastResult.Instance.Size/(glassdimensions)
	--		glass.Position = raycastResult.Instance.Position + (glassdimensions*x/2)*raycastResult.Instance.CFrame.RightVector + (glassdimensions*y/2) * raycastResult.Instance.CFrame.UpVector
	--		glass.Anchored = false
	--		glass.CanCollide = true
	--		glass.CanQuery = false
	--		glass.CanTouch = false
	--		glass.Parent = workspace
	--		--table.insert(raycastParams.FilterDescendantsInstances,glass)
	--		--glass.CollisionGroup = "Debris"
	--		--glass.Transparency = 0
	--		Debris:AddItem(glass,0.6)
	--	end

	--end

	--raycastResult.Instance.CanQuery = true
	--raycastResult.Instance.CanCollide = false
	--raycastResult.Instance.CanTouch = false
	--raycastResult.Instance.CollisionGroup = "Suspicious"
	--raycastResult.Instance.Transparency = 1
	--raycastResult.Instance.Parent = workspace
	--game:GetService("CollectionService"):RemoveTag(raycastResult.Instance,"window")
	--:Destroy()
end

local function placeBulletHole(raycastResult : RaycastResult)
	coroutine.wrap(function(raycastResult : RaycastResult)
		local cframe = CFrame.lookAt(raycastResult.Position,raycastResult.Position + raycastResult.Normal)

		local bulletHole : Part = game:GetService("ServerStorage"):WaitForChild("VFX"):WaitForChild("Hole"):Clone()
		bulletHole.Parent = workspace
		bulletHole.CFrame = cframe
		bulletHole.Anchored = false

		local attach : WeldConstraint = Instance.new("WeldConstraint")
		attach.Parent = bulletHole
		attach.Part0 = bulletHole
		attach.Part1 = raycastResult.Instance

		local bulletEmitter : ParticleEmitter = bulletHole:WaitForChild("Sparks")
		wait()
		bulletEmitter:Emit(6)
		wait(6)
		local goal = {}
		goal.Transparency = 1
		local T : Tween = TweenService:Create(bulletHole.Decal,TweenInfo.new(1),goal)
		T:Play()
		T.Completed:Wait()
		bulletHole:Destroy()
	end)(raycastResult)
end

local function bullet(player : Player,cam : CFrame)
	local playerCurrentGun : Model = getPlayerCurrentGun(player)
	
	if not prefireChecksPassed(player,playerCurrentGun) then
		return
	end
	
	local currentGunType : string = playerCurrentGun:GetAttribute("Type")
	
	local raycastParams = RaycastParams.new()
	raycastParams.FilterDescendantsInstances = {player.Character}
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	raycastParams.IgnoreWater = true
	raycastParams.CollisionGroup = "Bullets"
	
	local statsgun = gunstats[currentGunType]
	
	if thereAreBulletsInMagazine() then
		playerCurrentGun:SetAttribute("Magazine",playerCurrentGun:GetAttribute("Magazine") -1)
		beganReload(false)
	else
		beganReload(true)
		return
	end
	
	playerCurrentGun:SetAttribute("LastFired",time())

	local statsgun = gunstats[currentGunType]
	local maxdis = statsgun.BulletDestroy
	local currentspeed = statsgun.BulletLength
	local gravity = 0--9.8/currentspeed

	local visual = game.ServerStorage.VFX.BulletIcon:Clone()
	local front = Instance.new("Attachment")
	local back = Instance.new("Attachment")

	visual.Parent = player.Character
	back.Parent = workspace.BulletHolder
	front.Parent = workspace.BulletHolder
	visual.Attachment1 = back
	visual.Attachment0 = front
	--visual.Transparency = NumberSequence.new(1)
	local currentpos = cam
	back.CFrame = cam -- barrelpos
	--back.CFrame = cam--CFrame. new(cam.Position-Vector3.new(0,0.1,0) + 6*cam.LookVector)
	local nextpos = cam+cam.LookVector*currentspeed
	front.CFrame = nextpos
	--local bull = Instance.new("Part")
	--bull.Parent = workspace.BulletHolder
	--bull.Size = Vector3.new(0.1,0.1,0.1)
	--bull.Material = Enum.Material.Neon
	--bull.Color = Color3.new(1, 1, 0)
	--bull.CanTouch = false
	--bull.CanQuery = false
	--bull.CanCollide = false
	--bull.Anchored = true
	--bull.Shape = "Ball"
	--bull.Position = cam.Position + cam.LookVector*6
	--bull.Transparency = 1

	--local raycastParams = RaycastParams.new()
	--raycastParams.FilterDescendantsInstances = {player.Character}
	--raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	--raycastParams.IgnoreWater = true
	--raycastParams.CollisionGroup = "Default"
	--local raycastResult = workspace:Raycast(currentpos.Position, currentpos.LookVector*(handlength-2),raycastParams)
	--if raycastResult then
	--	currentspeed = 0
	--end

	while maxdis > 0 and currentspeed > 0 and (nextpos.Position-currentpos.Position).Magnitude>0 and nextpos.Position.Y > -100 do

		maxdis -= currentspeed
		--print(maxdis,(nextpos.Position-currentpos.Position).Magnitude)
		local raycastResult = workspace:Raycast(currentpos.Position, nextpos.Position-currentpos.Position,raycastParams)
		--print(raycastResult.Instance.Parent:FindFirstChild("Humanoid"))
		if raycastResult then-- and raycastResult.Distance > (handlength-2) then
			placeBulletHole(raycastResult)

			local damagedealt = statsgun.Damage*(currentspeed/statsgun.BulletLength) -- WTF is this (will be refactored)

			if raycastResult.Instance.Parent:FindFirstChild("Humanoid") then
				--print("death")
				if raycastResult.Instance.Name == "Head" then
					raycastResult.Instance.Parent.Humanoid.Health -= damagedealt*16
				else
					raycastResult.Instance.Parent.Humanoid.Health -= damagedealt*4
				end

			elseif raycastResult.Instance:HasTag("window") then
				handleWindowHit(raycastResult)
			end


			local entryvector = (nextpos.Position-currentpos.Position).Unit
			local facevector = raycastResult.Normal
			local entryangle = math.deg(entryvector:Angle(-facevector))
			--print(entryangle)

			--assuming penetration
			local reverseparams = RaycastParams.new()
			reverseparams.FilterDescendantsInstances = {raycastResult.Instance}
			reverseparams.FilterType = Enum.RaycastFilterType.Include
			reverseparams.IgnoreWater = true
			reverseparams.CollisionGroup = "Bullets"
			local reversecast = workspace:Raycast(nextpos.Position, currentpos.Position-nextpos.Position,reverseparams)
			if reversecast then
				--print(reversecast)
				placeBulletHole(reversecast)
				--print( currentspeed)
				--if not hitwindow then

					currentspeed = currentspeed - (raycastResult.Position-reversecast.Position).Magnitude*1*statsgun.Brittleness
					--print(hitwindow, densities[raycastResult.Material],raycastResult.Material)

				--else

				--	raycastResult.Instance.CanQuery = true
				--	raycastResult.Instance.CanCollide = false
				--	raycastResult.Instance.CanTouch = false
				--	raycastResult.Instance.CollisionGroup = "Suspicious"
				--	raycastResult.Instance.Transparency = 1
				--	raycastResult.Instance.Parent = workspace
				--	game:GetService("CollectionService"):RemoveTag(raycastResult.Instance,"window")

				--end
				--print(currentspeed)	
				--print(currentspeed)
				--print((currentspeed-reversecast.Distance),(raycastResult.Position-reversecast.Position).Magnitude)
				--print(raycastResult.Instance == reversecast.Instance)
			end
			--assuming penetration

			--if hitwindow then
			--end

			--break
		end


		local goal = {}
		goal.CFrame = currentpos
		TweenService:Create(back,TweenInfo.new(statsgun.Speed,Enum.EasingStyle.Linear),goal):Play()
		--back.CFrame = currentpos

		local goal = {}
		goal.CFrame = nextpos
		local t = TweenService:Create(front,TweenInfo.new(statsgun.Speed,Enum.EasingStyle.Linear),goal)
		t:Play()

		currentpos = nextpos
		nextpos = nextpos+cam.LookVector*currentspeed-Vector3.yAxis*gravity
		t.Completed:Wait()

		--local goal = {}
		--goal.CFrame = currentpos
		--TweenService:Create(bull,TweenInfo.new(windspeeds[currentgun],Enum.EasingStyle.Linear),goal):Play()


		--currentspeed = currentspeed * drag[currentgun]
		gravity -= statsgun.Gravity --= 0.1/currentspeed
		--print(currentspeed)
		--front.CFrame = nextpos
	end 
	--print("bullet destroyed")
	visual:Destroy()
	front:Destroy()
	back:Destroy()
	--bull:Destroy()
	--end
end

local function processInputEvent(gun : Model)
	gun:WaitForChild("RecieveInput"):WaitForChild("FireWeapon").OnServerEvent:Connect(bullet)
end

for i,v : BindableEvent in CS:GetTagged(GunTag) do
	processInputEvent(v)
end

CS:GetInstanceAddedSignal(GunTag):Connect(processInputEvent)