-- A central script that holds information on player states and computes player movement speed

local TS : TweenService = game:GetService("TweenService")
local players : Players = game:GetService("Players")
local RS : RunService = game:GetService("RunService")
local UIS : UserInputService = game:GetService('UserInputService')

local gunstats = require(game:GetService("ReplicatedStorage"):WaitForChild("Weapon"):WaitForChild("GunStats"))

local playerState = {}
playerState.Walk = 9
playerState.Run = 18
playerState.Crouch = 6
playerState.Crawl = 3

local crouchState = require(script.Parent:WaitForChild("CrouchHeights"))

local leanState = {}
leanState.Right = math.rad(60)
leanState.Left = - leanState.Right
leanState.None = 0

local currentWalkSpeed : playerState = playerState.Walk
local currentCrouchState : crouchState = crouchState.Stand
local currentLeanState : leanState = leanState.None

local previousWalkSpeed : playerState = playerState.Walk
local previousCrouchState : crouchState = crouchState.Stand
local previousLeanState : leanState = leanState.None

local goalWalkSpeed : number = currentWalkSpeed
local goalCameraDownness : number = currentCrouchState
local goalCurrentLeanState : number = currentLeanState

local lastModifiedCrouch : number = 0 -- last time state change happend
local lastModifiedWalk : number = 0 
local lastModifiedLean : number = 0 -- last time state change happend

local function lerpNumber(x : number, y : number, a : number) : number
	a = math.min(a,1)
	-- if desired, a = sin(a*math.PI/2) or smth
	return x*a + y*(1-a)
end 

local function setCurrentCrouchState(goal : crouchState)
	previousCrouchState = goalCameraDownness
	currentCrouchState = goal
	lastModifiedCrouch = time()
	
	script.CrouchStateChanged:Fire(goal)
end

local function setCurrentWalkSpeed(goal : playerState)
	previousWalkSpeed = goalWalkSpeed
	currentWalkSpeed = goal
	lastModifiedWalk = time()
end 

local function setLeanState(goal : leanState)
	previousLeanState = goalCurrentLeanState
	currentLeanState = goal
	lastModifiedLean = time()
end

-- false = released
local function SprintKeyPressed(pressed : boolean)
	if pressed then
		setCurrentCrouchState(crouchState.Stand)
		setCurrentWalkSpeed(playerState.Run)
	elseif currentWalkSpeed == playerState.Run then
		setCurrentWalkSpeed(playerState.Walk)
	end
end

-- if uncrouch is true, uncrouch
local function crouch(uncrouch : boolean)
	if uncrouch then
		if currentCrouchState == crouchState.Crawl then
			setCurrentCrouchState(crouchState.Crouch)
			setCurrentWalkSpeed(playerState.Crouch)
		elseif currentCrouchState == crouchState.Crouch then
			setCurrentCrouchState(crouchState.Stand)
			setCurrentWalkSpeed(playerState.Walk)
		end
		return
	end
	
	if currentCrouchState == crouchState.Crawl then
		-- stand
		setCurrentCrouchState(crouchState.Stand)
		setCurrentWalkSpeed(playerState.Walk)
	elseif currentCrouchState == crouchState.Stand then
		setCurrentCrouchState(crouchState.Crouch)
		setCurrentWalkSpeed(playerState.Crouch)
	else
		setCurrentCrouchState(crouchState.Crawl)
		setCurrentWalkSpeed(playerState.Crawl)
	end 
end 

-- false = left
-- redundancy 100
local currentLean : number = currentLeanState
local function leanRightWhen(right : boolean,center : boolean)
	if center then
		setLeanState(leanState.None)
		return
	end 

	if right then
		setLeanState(leanState.Right)
	else 
		setLeanState(leanState.Left)
	end
end

local function crawl()
	if currentWalkSpeed == playerState.Run then
		-- perform the slide I mean dive
		-- TODO: implement
		-- return
	end
	if currentCrouchState == crouchState.Crawl then
		-- stand
		setCurrentCrouchState(crouchState.Stand)
		setCurrentWalkSpeed(playerState.Walk)
	else
		setCurrentCrouchState(crouchState.Crawl)
		setCurrentWalkSpeed(playerState.Crawl)
	end 
end 

local function getHumanoid() : Humanoid
	local plr : Player = players.LocalPlayer
	if not plr then
		return
	end
	local character = plr.Character
	if not character then
	return 
	end 
	local humanoid : Humanoid = character:WaitForChild("Humanoid")
	return humanoid
end

local EQactivatedBy : Enum.KeyCode = Enum.KeyCode.Unknown 

game:GetService("ReplicatedStorage"):WaitForChild("Vote"):WaitForChild("StartGame").OnClientEvent:Connect(function()
	UIS.InputBegan:Connect(function(input,gp)
		if gp then return end
		if input.KeyCode == Enum.KeyCode.E or input.KeyCode == Enum.KeyCode.Q then
			EQactivatedBy = input.KeyCode
			leanRightWhen(input.KeyCode == Enum.KeyCode.E)
		elseif input.KeyCode == Enum.KeyCode.LeftControl then
			crawl()
		elseif input.KeyCode == Enum.KeyCode.C then
			crouch()
		elseif input.KeyCode == Enum.KeyCode.X then
			crouch(true)
		elseif input.KeyCode == Enum.KeyCode.LeftShift then
			SprintKeyPressed(true)
		end 
	end)

	UIS.InputEnded:Connect(function(input,gp)
		if input.KeyCode == EQactivatedBy and input.KeyCode ~= Enum.KeyCode.Unknown then
			leanRightWhen(false,true)
			EQactivatedBy = Enum.KeyCode.Unknown
			return
		elseif input.KeyCode == Enum.KeyCode.LeftShift then
			SprintKeyPressed(false)
		end
	end)
end)

local timescale : number = 3
local leantimescale : number = 3

local function findTimeDifference(lastMod : number,scale : number) : number
	return(time()-lastMod) * scale
end

local LeanEvent = game:GetService('ReplicatedStorage'):WaitForChild("Replication"):WaitForChild("LeanAngle")
RS.PostSimulation:Connect(function()
	LeanEvent:FireServer(goalCurrentLeanState)
end)

RS.PreRender:Connect(function(delta)
	local humanoid : Humanoid = getHumanoid()
	if not humanoid then
		return
	end
	
	local walkTimeDifference : number = findTimeDifference(lastModifiedWalk,timescale)
	goalWalkSpeed = lerpNumber(currentWalkSpeed,previousWalkSpeed,walkTimeDifference)
	-- TODO: add acceleration to the aim slow down (shouldn't be noticible that much ig)
	local currentlyAiming : string = game:GetService("Players").LocalPlayer.PlayerScripts:WaitForChild("Viewmodel"):WaitForChild("IsAiming"):Invoke()
	if currentlyAiming then
		local currentGun = gunstats[currentlyAiming]
		if currentGun then
			goalWalkSpeed *= currentGun.AimWalkSpeedDecreaseFactor
		end
	end
	humanoid.WalkSpeed = goalWalkSpeed
	
	local downTimeDifference : number = findTimeDifference(lastModifiedCrouch,timescale)
	goalCameraDownness = lerpNumber(currentCrouchState,previousCrouchState,downTimeDifference)
	local goalCameraOffset : Vector3 = Vector3.new(0,goalCameraDownness,humanoid.CameraOffset.Z)
	
	local leanTimeDifference : number = findTimeDifference(lastModifiedLean,timescale)
	goalCurrentLeanState = lerpNumber(currentLeanState,previousLeanState,leanTimeDifference*leantimescale)
	
	workspace.CurrentCamera.CFrame *= CFrame.Angles(0,0,-goalCurrentLeanState/3)
	local leanscale = (1.6+goalCameraDownness/3)
	goalCameraOffset -= Vector3.yAxis * leanscale
	
	goalCameraOffset += Vector3.new(math.sin(goalCurrentLeanState),math.cos(goalCurrentLeanState),0) * leanscale
	-- think that when right is up, cosine is up
	humanoid.CameraOffset = goalCameraOffset
end)

script:WaitForChild("GetLeanAngle").OnInvoke = function()
	return -goalCurrentLeanState/3
end