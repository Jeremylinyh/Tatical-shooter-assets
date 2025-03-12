-- when turned on for a NPC, shoots the player continously.

local attackLoop
local callSelfProxy

local function fireGun(...)
	--print("kaboom")
	-- TODO: implement
end

local function openFire(NPC : Model,target : Model,direction : number,rush : boolean)
	--wait(1)
	local humanoid : Humanoid = NPC:FindFirstChild("Humanoid")
	if not humanoid then
		return
	end
	local deathConnection : RBXScriptConnection
	deathConnection = humanoid.Died:Connect(function()
		deathConnection:Disconnect()
		--engagingUnits -= 1
		return
	end)
	humanoid.AutoRotate = false

	local playerSeen : boolean = true
	local goalLean = 0
	local currentLean = 0

	while playerSeen do


		--if rush then
		--	local runToPlayer = coroutine.wrap(attackLoop)
		--	humanoid.WalkSpeed = 36
		--	runToPlayer(NPC,target,true)
		--end

		local startTime = time()

		local gunType = NPC:GetAttribute("Primary")
		local lastFired = time()
		while (time()-startTime) < 16 * gunstats[gunType].CooldownBetweenShots do
			--wait(gunstats[gunType].CooldownBetweenShots)
			if (time() - startTime ) > gunstats[gunType].CooldownBetweenShots then
				lastFired = time()
				fireGun()
			end
			wait()
			if humanoid.Health <= 0 then
				return
			end
			--goalLean = math.rad(60) * direction
			--currentLean = (currentLean + goalLean)/2
			--game.ServerScriptService.Replication.SetNPClean:Fire(NPC,currentLean)
			local targetPos : Vector3 = target:GetPivot().Position
			local NPCgoalCF : CFrame = (CFrame.lookAt(NPC:GetPivot().Position,Vector3.new(targetPos.X,NPC:GetPivot().Position.Y
				,targetPos.Z)))
			NPC:PivotTo(NPC:GetPivot():Lerp(NPCgoalCF,0.5))
			--playerSeen,direction = script.Parent.VisualDetermination.SeenPlayer:Invoke(NPC)
			--wait(1)



		end
		--wait(1)
		playerSeen,direction = script.Parent.VisualDetermination.SeenPlayer:Invoke(NPC)
	end
	--print("playerLost")
	humanoid.AutoRotate = true
	attackLoop(NPC,target)
end



script.Attack.Event:Connect(function(begin : boolean)
	
end)
