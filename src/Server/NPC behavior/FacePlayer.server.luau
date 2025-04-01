-- controls NPC firing.
-- this is a standalone system
-- faces the player and depending on how much can be seen, decide whether to crouch

local CS : CollectionService = game:GetService("CollectionService")
local TS : TweenService = game:GetService("TweenService")
local spreadLess : number = 66

local TInfo : TweenInfo = TweenInfo.new(0.3)
local pastDeltas : {Tween} = {}
local turnDelay : number = 0.6 -- default turn delay if not specified in character model

local lastFired = {}
local shooterRandom = Random.new()
local gunstats = require(game:GetService("ReplicatedStorage"):WaitForChild("Weapon"):WaitForChild("GunStats"))

local prevTarget = {}
local lastseen = {}

local function tiltBody(shooter : Model, target:Model)
	local tarPos : Vector3 = target.UpperTorso.Position
	local shooPos : Vector3 = shooter.UpperTorso.Position
	local Rise : number = tarPos.Y - shooPos.Y
	local Run : number = (shooPos * Vector3.new(1,0,1)-tarPos * Vector3.new(1,0,1)).Magnitude
	game:GetService("ServerScriptService").Replication.RotateHead.ServerTilt
		:Fire(shooter,math.atan2(Rise,Run))
end

while task.wait() do
	local allNPC = CS:GetTagged("Enemy")
	for i,shooter : Model in ipairs(allNPC) do
		local humanoid = shooter:FindFirstChild("Humanoid")
		
		if not humanoid then 
			continue
		end
		local attacking : boolean = not humanoid.AutoRotate
		if not attacking then
			continue
		end
		
		if not lastseen[shooter] then
			lastseen[shooter] = 0
		end
		
		local target: Model = -- character model
			script.Parent.CanSeePlayer.SeenPlayer:Invoke(shooter)
		if target then
			lastseen[shooter] = time()
		elseif (time() - lastseen[shooter]) < 6 then
			target = prevTarget[shooter]
		else
			prevTarget[shooter] = nil
		end

		if not target then
			continue
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
		tiltBody(shooter,target)
		-- shooting logic here
		local currentWeapon : string = shooter:GetAttribute("Weapon")
		if not currentWeapon then
			continue
		end
		
		local gunModel : Model = shooter:FindFirstChild(currentWeapon)
		if not gunModel then
			print("we lost the gun oops")
			continue
		end
		
		--print(lastFired[shooter])
		
		if not lastFired[shooter] then
			lastFired[shooter] = time()  + shooterRandom:NextNumber()/10
		end
		
		if gunModel:GetAttribute("Magazine") <= 0 then
			print("outta ammo")
			continue
		end
		
		if not (time()-lastFired[shooter] > gunstats[currentWeapon].CooldownBetweenShots) then
			continue
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
		gunModel:WaitForChild("RecieveInput"):WaitForChild("ServerFire"):Fire(
			shooter,
			shooter.Head.CFrame * CFrame.new(0.75,-1,0) * spread
		)
	end
end

