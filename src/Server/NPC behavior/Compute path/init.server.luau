-- returns waypoint. may replace with a custom algorithm later

local nodes = workspace.Level.Navigation

local function lastResort(character,destination : CFrame)
	local PathfindingService = game:GetService("PathfindingService")

	local path = PathfindingService:CreatePath({
		AgentCanJump = false,
	})
	
	local success, errorMessage = pcall(function()
		path:ComputeAsync(character.PrimaryPart.Position, destination.Position)
	end)

	if success and path.Status == Enum.PathStatus.Success then
		-- Get the path waypoints
		return path:GetWaypoints()
	else
		
	end
	return false
end

local function findPathToCFrame(character : Model,destination : CFrame)
	local startConnections = script.TempNode.Attach:Invoke(character:GetPivot().Position,nodes)
	
	local finishConnections = script.TempNode.Attach:Invoke(destination.Position,nodes)
	
	if #startConnections <= 0 or #finishConnections <= 0 then
		local default = lastResort(character,destination)
		if default then
			return default
		else
			character.Humanoid.Health = 0
			return default
		end
	end
	
	-- the A* algorithm
end

script.Execute.OnInvoke = findPathToCFrame
