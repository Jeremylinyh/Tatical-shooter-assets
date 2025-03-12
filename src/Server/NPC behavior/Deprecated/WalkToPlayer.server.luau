-- Go to the target in a tactical manner

-- POV when you have to refactor this script one day after writing it
-- yeah I suck

local PathfindingService : PathfindingService = game:GetService("PathfindingService")
local Players : Players = game:GetService("Players")
local RunService : RunService = game:GetService("RunService")

local gunstats = require(game:GetService("ReplicatedStorage"):WaitForChild("Weapon"):WaitForChild("GunStats"))
local helper = require(game:GetService("ReplicatedStorage"):WaitForChild("Helper"))
local characterStats = require(game:GetService("ReplicatedStorage").Player:WaitForChild("PlayerStats"))

local recomputeWaypointAfter : number = 6

local path = PathfindingService:CreatePath({
	AgentCanJump = false
})
local pathJump = PathfindingService:CreatePath()

local roleEnum = {}
roleEnum.Peeker = 0
roleEnum.Rusher = 1
roleEnum.Rear   = 2

local animations = {}
local currentlyPlaying = {}

local function createPathInternals(start: Vector3,destination : Vector3)

	local waypoints

	-- Compute the path
	local success, errorMessage = pcall(function()
		path:ComputeAsync(start, destination)
	end)

	if success and path.Status == Enum.PathStatus.Success then
		-- Get the path waypoints
		waypoints = path:GetWaypoints()
	else
		local success, errorMessage = pcall(function()
			pathJump:ComputeAsync(start, destination)
		end)
		if success and pathJump.Status == Enum.PathStatus.Success then
			-- Get the path waypoints
			waypoints = pathJump:GetWaypoints()
		end
	end
	return waypoints
end

local function createPath(start: Vector3,destination : Vector3)
	local waypoints = {}
	local newwaypoints = createPathInternals(start,destination)
	if newwaypoints and #newwaypoints > 2 then
		waypoints = newwaypoints
	else
		--newwaypoints = createPathInternals(destination,start)

		--if newwaypoints and #newwaypoints > 2 then
		--	table.clear(waypoints)
		--	for i = #newwaypoints, 1, -1 do

		--		table.insert(waypoints,newwaypoints[i])
		--	end
		--end
	end
	return waypoints
end




function moveToPlayer(NPC: Model,target : Model,waypoints,ignoreCover : boolean) : boolean
	local humanoid : Humanoid = NPC:FindFirstChild("Humanoid")
	if not humanoid then
		return
	end
	local NPCdeath : RBXScriptConnection
	NPCdeath = humanoid.Died:Connect(function()
		NPCdeath:Disconnect()
		game:GetService("ServerScriptService").GameBegin.RagdollCharacter:Fire(NPC)
		return
	end)
	
	local endNumber : number = math.min(#waypoints,recomputeWaypointAfter)
	--print(ignoreCover)
	if ignoreCover then
		--print("rushing")
		--endNumber = 64 -- Rush the player
	end
		
	-- next waypoint loop
	local nextWaypointIndex = 2
	for nextWaypointIndex = 2, endNumber,1 do
		if not waypoints[nextWaypointIndex] then
			--print(nextWaypointIndex,#waypoints)
			break
		end
		if waypoints[nextWaypointIndex].Action == Enum.PathWaypointAction.Jump then 
			humanoid.Jump = true 
		end
		humanoid:MoveTo(waypoints[nextWaypointIndex].Position)
		
		local reached : boolean = humanoid.MoveToFinished:Wait()
		
		local playerSeen,direction = script.Parent.VisualDetermination.SeenPlayer:Invoke(NPC)
		if not ignoreCover and playerSeen then
			return playerSeen,direction
		end
		if not reached then
			break
		end
	end
	return false
end



local function loadAnimations(v : Model)
	local memberAnimation = {}
	memberAnimation.Walk = helper.loadAnimationFromID(characterStats.WalkAnim,v.Humanoid
		:WaitForChild("Animator"))
	memberAnimation.Crouch = helper.loadAnimationFromID(characterStats.CrouchAnim,v.Humanoid.Animator)
	animations[v] = memberAnimation
	currentlyPlaying[v] = memberAnimation.Walk
end

function attackLoop(NPC,target,rush)
	local waypoints = {}
	local playerSeen = false
	local direction = 0
	currentlyPlaying[NPC]:Stop()
	currentlyPlaying[NPC] = animations[NPC].Walk
	currentlyPlaying[NPC]:Play()
	while true do
		if not NPC or not NPC:FindFirstChild("Humanoid") or  NPC.Humanoid.Health <= 0 then
			NPC:Destroy()
			return
		end

		local newwaypoints = createPath(NPC:GetPivot().Position,target:GetPivot().Position)
		if newwaypoints and #newwaypoints > 2 then
			waypoints = newwaypoints
		end


		if not waypoints or #waypoints <= 2 then
			wait(1)
			--print("lost")
			continue
		end
		--print(rush)
		playerSeen,direction = moveToPlayer(NPC,target,waypoints,rush)

		if not playerSeen then
			--print(#waypoints)
			for i = 0, recomputeWaypointAfter,1 do
				table.remove(waypoints,i)
			end
			--print(#waypoints)
		else
			print("seen")
			currentlyPlaying[NPC]:Stop()
			currentlyPlaying[NPC] = animations[NPC].Crouch
			currentlyPlaying[NPC]:Play()
			repeat 
				wait(1)
			until not script.Parent.VisualDetermination.SeenPlayer:Invoke(NPC)
			
			currentlyPlaying[NPC]:Stop()
			currentlyPlaying[NPC] = animations[NPC].Walk
			currentlyPlaying[NPC]:Play()
		end

		--print("incremented")
	end
	
end

local function init(members, player : Player)
	local target = player.Character
	if not target then
		for i,v in pairs(members) do
			v:Destroy()
		end
		return
	end
	--local waypoints = {}
	--local noPlayerSeen = true
	--local playerSeenEvent : BindableEvent = Instance.new("BindableEvent")
	
	for i,v in pairs(members) do
		local deathConnection : RBXScriptConnection
		deathConnection = v.Humanoid.Died:Connect(function()
			deathConnection:Disconnect()
			deathConnection = nil
			table.remove(members,table.find(members,v))
		end)
	end
	
	--while #members > 0 and noPlayerSeen do
		--print(#members)
		--local NPC = members[1]
		
		
		for i,v in pairs(members) do
			
		for j,k in pairs(v:GetChildren()) do
			if k:IsA("BasePart") then
				k:SetNetworkOwner(nil)
			end
		end
		
			if not v:FindFirstChild("Humanoid") then
				v:Destroy()
				table.remove(members,table.find(v))
				continue
			end
			loadAnimations(v)
			local wrapped = coroutine.wrap(attackLoop)
		wrapped(v,player.Character)
			
		end
		
		--wait(1)
	--end
	--print(#members)
end

script.Parent.EnemySquadBehaviorInit.Event:Connect(init)
