-- the purpose of this script is to for example, the start node, end node, 
-- instead of finding a node on the grid,
-- we add the start node and end node to the grid
	
--local function handleInitialNoClip(lookAtCF : CFrame) : CFrame
	
--end

-- returns a list of attached Nodes
local function addSelfAsNode(position : Vector3,nodesFolder,visual : BasePart)
	--position += Vector3.new(0,1.6,0)

	local boxParams : RaycastParams = RaycastParams.new()
	boxParams.CollisionGroup = "Path"
	local validPoints = {}
	local potentialPoints = {}
	local boxSize = Vector3.new(4,6,0.01)

	for i, node : BasePart in nodesFolder:GetChildren() do
		-- check that an agent can conceivably walk there
		if not node:IsA("BasePart") then
			continue
		end
		local goalPos = node.Position --+ Vector3.new(0,1.6,0)
		local difference = goalPos - position
		local shapeCF = CFrame.lookAt(position,goalPos)
		-- prevent noclip
		--shapeCF = handleInitialNoClip(shapeCF)

		local result = workspace:Blockcast(shapeCF + Vector3.new(0,3,0), boxSize, difference,boxParams)
		local rayResult = workspace:Raycast(shapeCF.Position,difference,boxParams)
		
		if rayResult and rayResult.Instance.Parent ~= nodesFolder then
			-- something in the way
		elseif not table.find(validPoints,node) then
			table.insert(potentialPoints,node)
			
			
			if result and result.Instance.Parent ~= nodesFolder then
				-- this can happen if box is initially in a wall
				continue
			end
			
			table.insert(validPoints,node)
		end

	end

	-- visual
	if visual then
		visual:ClearAllChildren()
		visual.Parent = workspace
		--visual.Position = position - Vector3.new(0,1.6,0)
		Instance.new("Attachment").Parent = visual
		for i,v : BasePart in ipairs(validPoints) do
			local beam = script.Beam:Clone()
			beam.Attachment0 = visual:FindFirstChildOfClass("Attachment")
			beam.Parent = visual
			beam.Attachment1 = v:FindFirstChildOfClass("Attachment")
		end
	end
	-- visual
	if #validPoints <= 0 then
		validPoints = potentialPoints
	end
	return validPoints
end

script:WaitForChild("Attach").OnInvoke = addSelfAsNode