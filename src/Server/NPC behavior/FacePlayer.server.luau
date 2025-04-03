-- controls NPC firing.
-- this is a standalone system
-- faces the player and depending on how much can be seen, decide whether to crouch

local CS : CollectionService = game:GetService("CollectionService")
local TS : TweenService = game:GetService("TweenService")
local spreadLess : number = 36

local TInfo : TweenInfo = TweenInfo.new(0.3)
local pastDeltas : {Tween} = {}
local turnDelay : number = 0.6 -- default turn delay if not specified in character model

local lastFired = {}
local shooterRandom = Random.new()
local gunstats = require(game:GetService("ReplicatedStorage"):WaitForChild("Weapon"):WaitForChild("GunStats"))

local prevTarget = {}
local lastseen = {}
local gunOffset = CFrame.new(0.75,-0.6,0)

local selfPart : string = "Head"
local bodypart : string = "UpperTorso"

local leanGoal = {}
local currentLean = {}

local function tiltBody(shooter : Model, target:Model) : number
	
	if target:FindFirstChild(bodypart) and shooter:FindFirstChild(selfPart) then
	else
		return 0
	end
	local tarPos : Vector3 = target:FindFirstChild(bodypart).Position
	local shooPos : Vector3 = shooter:FindFirstChild(selfPart).Position
	local Rise : number = tarPos.Y - shooPos.Y
	local Run : number = (shooPos * Vector3.new(1,0,1)-tarPos * Vector3.new(1,0,1)).Magnitude
	local angle = math.atan2(Rise,Run)
	game:GetService("ServerScriptService").Replication.RotateHead.ServerTilt
		:Fire(shooter,angle)
	if not currentLean[shooter] then
		currentLean[shooter] = 0
	end
	if not leanGoal[shooter] then
		leanGoal[shooter] = 0
	end
	currentLean[shooter] = (currentLean[shooter] + leanGoal[shooter])/2
	game.ServerScriptService.Replication.SetNPClean:Fire(
		shooter,currentLean[shooter]
	)
	return angle
end

local function showMuzzleFlash(weaponType : Model)
	coroutine.wrap(function(weaponType : Model)
		local muzzleFlash = game:GetService("ReplicatedStorage").Guns.MuzzleFlash:Clone()
		muzzleFlash.Parent = workspace
		muzzleFlash.RigidConstraint.Attachment0.CFrame *= CFrame.Angles(0,Random.new():NextNumber(),0)
		muzzleFlash.RigidConstraint.Attachment1 = weaponType.Body.FlashPos
		muzzleFlash:ScaleTo(Random.new():NextNumber() + 1)
		local muzzleFlashTime = 0.03

		wait(muzzleFlashTime)
		muzzleFlash:Destroy()
	end)(weaponType)
end

local function lean(shooter : Model,target : Model)
	local targetPos : Vector3 = target:GetPivot().Position
	local right = shooter:GetPivot().RightVector
	local diff = (target:GetPivot().Position - shooter:GetPivot().Position).Unit
	
	--leanGoal[shooter] = math.sign(right:Dot(diff))
	return
end

local function aimAtPlayer(shooter)
	local humanoid = shooter:FindFirstChild("Humanoid")

	if not humanoid or humanoid.Health <= 0 or humanoid.AutoRotate then 
		currentLean[shooter] = 0
		game.ServerScriptService.Replication.SetNPClean:Fire(shooter,0)
		return
	end
	
	if not lastseen[shooter] then
		lastseen[shooter] = 0
	end

	local target: Model,_,headonly = -- character model
		script.Parent.CanSeePlayer.SeenPlayer:Invoke(shooter)
	if target then
		lastseen[shooter] = time()
		leanGoal[shooter] = 0
	elseif (time() - lastseen[shooter]) < 6 then
		
		target = prevTarget[shooter]
		if target then
			lean(shooter,target)
		end
	else
		prevTarget[shooter] = nil
	end

	if not target then
		return
	end
	
	if target:FindFirstChild(bodypart) and shooter:FindFirstChild(selfPart) then
	else
		return 
	end
	
	prevTarget[shooter] = target

	--task.wait()
	--local previousTime = pastDeltas[shooter] or time()
	--pastDeltas[shooter] = time()

	local shooterGoalCF : CFrame = CFrame.lookAt(
		shooter:GetPivot().Position * Vector3.new(1,0,1),
		target:GetPivot().Position * Vector3.new(1,0,1),
		Vector3.yAxis
	)

	--local alpha : number = shooter:GetAttribute("TurnSpeed") 
	--if not alpha then
	--	alpha = turnDelay * (time()-previousTime)
	--end
	--shooter:PivotTo(
	--	CFrame.new(shooter:GetPivot().Position)
	--		* shooterGoalCF.Rotation:Lerp(shooter:GetPivot().Rotation,alpha)
	--)

	local proxy : CFrameValue = Instance.new("CFrameValue")
	proxy.Value = shooter:GetPivot()
	local proxyChange : RBXScriptConnection
	proxyChange = proxy.Changed:Connect(function(value : CFrame)
		shooter:PivotTo(proxy.Value)
	end)
	local goal = {}
	goal.Value = CFrame.new(proxy.Value.Position) * shooterGoalCF.Rotation
	if pastDeltas[shooter] then
		pastDeltas[shooter]:Cancel()
	end
	local tween : Tween = TS:Create(proxy,TInfo,goal)
	tween:Play()
	pastDeltas[shooter] = tween
	tween.Completed:Connect(function()
		if proxyChange then
			proxyChange:Disconnect()
			proxyChange = nil
		end
		if proxy then
			proxy:Destroy()
		end
	end)
	-- tilt body
	local upAngle : number = tiltBody(shooter,target)
	-- shooting logic here
	local currentWeapon : string = shooter:GetAttribute("Weapon")
	if not currentWeapon then
		return
	end

	local gunModel : Model = shooter:FindFirstChild(currentWeapon)
	if not gunModel then
		print("we lost the gun oops")
		return
	end

	--print(lastFired[shooter])

	if not lastFired[shooter] then
		lastFired[shooter] = time()  + shooterRandom:NextNumber()/36
	end
	
	if gunModel:GetAttribute("Magazine") <= 0 then
--		print("outta ammo")
		script.Parent:WaitForChild("Reload"):WaitForChild("Begin"):Fire(shooter)
		return
	end

	if not (time()-lastFired[shooter] > gunstats[currentWeapon].CooldownBetweenShots) then
		return
	end

	lastFired[shooter] = time()

	--print("pew")
	gunModel:SetAttribute("Magazine",gunModel:GetAttribute("Magazine")-1)
	-- fireButton:FireServer(CFrame.new(workspace.CurrentCamera.CFrame.Position)
	--*game:GetService("Players").LocalPlayer.PlayerScripts.Viewmodel.GetCurrentRecoil:Invoke())

	local spreadAngle : number = shooterRandom:NextNumber() * math.pi * 2
	local spreadDirection : Vector2 = Vector2.new(
		math.sin(spreadAngle),
		math.cos(spreadAngle)
	) * shooterRandom:NextNumber()/spreadLess

	local spread = CFrame.Angles(
		spreadDirection.X,
		spreadDirection.Y,
		0
	)
	local goalPos = target.UpperTorso.Position
	if headonly then
		goalPos = target.Head.Position
	end
	gunModel:WaitForChild("RecieveInput"):WaitForChild("ServerFire"):Fire(
		shooter,
		CFrame.lookAt((shooter.Head.CFrame * gunOffset).Position,goalPos)
		 * spread
		-- --
	)
	showMuzzleFlash(gunModel)
end

while task.wait() do
	local allNPC = CS:GetTagged("Enemy")
	for i,shooter : Model in ipairs(allNPC) do
		local wrapped = coroutine.wrap(aimAtPlayer)
		wrapped(shooter)
	end
end

