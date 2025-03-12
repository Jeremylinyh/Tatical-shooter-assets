-- returns waypoint. may replace with a custom algorithm later

local PathfindingService = game:GetService("PathfindingService")

local path = PathfindingService:CreatePath({
	AgentCanJump = false,
})

local function findPathToCFrame(character,destination : CFrame)
	local success, errorMessage = pcall(function()
		path:ComputeAsync(character.PrimaryPart.Position, destination.Position)
	end)

	if success and path.Status == Enum.PathStatus.Success then
		-- Get the path waypoints
		return path:GetWaypoints()
	else
		print("no path")
	end
	return {}
end

script.Execute.OnInvoke = findPathToCFrame
