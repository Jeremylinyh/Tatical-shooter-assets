-- Go to the target in a tactical manner

local PathfindingService : PathfindingService = game:GetService("PathfindingService")
local Players : Players = game:GetService("Players")
local RunService : RunService = game:GetService("RunService")

local recomputeWaypointAfter : number = 16

local path = PathfindingService:CreatePath()

local function createPath(start: Vector3,destination : Vector3)
	local TEST_DESTINATION = Vector3.new(100, 0, 100)

	local waypoints

	-- Compute the path
	local success, errorMessage = pcall(function()
		path:ComputeAsync(start, destination)
	end)

	if success and path.Status == Enum.PathStatus.Success then
		-- Get the path waypoints
		waypoints = path:GetWaypoints()
	end
	return waypoints
end

local function openFire(NPC : Model)
	-- TODO: implement
	while script.Parent.VisualDetermination.SeenPlayer:Invoke(NPC) do
		wait(0.1)
		print("Pew")
	end
end

local function moveToPlayer(NPC: Model,target : Model)
	local alive : boolean = true
	local humanoid : Humanoid = NPC:FindFirstChild("Humanoid")
	if not humanoid then
		return
	end
	local NPCdeath : RBXScriptConnection
	NPCdeath = humanoid.Died:Connect(function()
		NPCdeath:Disconnect()
		return
	end)
	while alive do
		if not target then
			return -- TODO: handle this better
		end
		local waypoints = createPath(NPC:GetPivot().Position,target:GetPivot().Position)
		if not waypoints then
			return -- TODO: handle this better
		end
		for nextWaypointIndex= 1, math.min(#waypoints,recomputeWaypointAfter),1 do
			humanoid:MoveTo(waypoints[nextWaypointIndex].Position)
			local reached : boolean = humanoid.MoveToFinished:Wait()
			if script.Parent.VisualDetermination.SeenPlayer:Invoke(NPC) then
				openFire(NPC)
			end
			if not reached then
				break
			end
		end
	end
end

local function init(members, player : Player)
	if not player.Character then
		return
	end
	for i,v in pairs(members) do
		local wrapped = coroutine.wrap(moveToPlayer)
		wrapped(v,player.Character)
	end
end

script.Parent.EnemySquadBehaviorInit.Event:Connect(init)
