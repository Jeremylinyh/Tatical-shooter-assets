-- returns waypoint. may replace with a custom algorithm later

-- to future maintainers, I was small brain, beware which tables use .Name and which use instance...

local NodeFolder = workspace.Level.Navigation

local graph = {}
local Nodes = {}

local function estimateCost(CurrentNode : BasePart,NodeInfo,goal : Vector3,startPos : CFrame) : number
	local prevNode = NodeInfo[CurrentNode.Name].PreviousNode
	local distanceToStart = 0
	
	if prevNode and #NodeInfo[prevNode.Name] > 0 then
		--print(NodeInfo[prevNode.Name])
		distanceToStart += NodeInfo[prevNode.Name].Cost
		distanceToStart += (prevNode.Position - CurrentNode.Position).Magnitude
	else
		distanceToStart += (startPos.Position - CurrentNode.Position).Magnitude
	end
	
	return distanceToStart + (CurrentNode.Position-goal).Magnitude
end

local function retracePath(finish : CFrame,finishingNode : BasePart,NodeInfo)
	local traversedNodes = {}
	
	while finishingNode and NodeInfo[finishingNode.Name] do

		local visual = script.Waypoint:Clone()
		visual.Parent = workspace
		visual.Position = finishingNode.Position
		game:GetService("Debris"):AddItem(visual,1)
		
		--print(finishingNode)
		
		table.insert(traversedNodes,finishingNode)
		finishingNode = NodeInfo[finishingNode.Name].PreviousNode
		
	end
	
	return traversedNodes
end

local function findPathToCFrame(startPos : CFrame,destination : CFrame)
	local startConnections = script.TempNode.Attach:Invoke(startPos.Position,NodeFolder)
	
	local finishConnections = script.TempNode.Attach:Invoke(destination.Position,NodeFolder)
	
	if #startConnections <= 0 or #finishConnections <= 0 then
		print("undefined start or finish")
		return
	end
	
	-- the A* algorithm
	
	local openList = {}
	local closedList = {}
	local NodeInfo = {}
	
	-- distance from start to start is 0
	for i,v in ipairs(startConnections) do
		--print(v.Name)
		NodeInfo[v.Name] = {}
		NodeInfo[v.Name].Cost = (v.Position - startPos.Position).Magnitude
		NodeInfo[v.Name].PreviousNode = nil
		table.insert(openList,v)
	end
	
	local cheapest = {}
	local previous = nil
	while #openList > 0 do
		task.wait()
		cheapest.Node = nil
		cheapest.Cost = math.huge
		for i, node in ipairs(openList) do
			if not NodeInfo[node.Name] then
				NodeInfo[node.Name] = {}
			end
			
			--print(NodeInfo[node.Name].PreviousNode)
			local newcost = estimateCost(node,NodeInfo,destination.Position,startPos)
			--print(newcost)
			if (not NodeInfo[node.Name].Cost) or newcost < NodeInfo[node.Name].Cost then
				NodeInfo[node.Name].Cost = newcost
				NodeInfo[node.Name].PreviousNode = previous
			end
			if newcost < cheapest.Cost then
				--print(typeof(node))
				cheapest.Node = node
				cheapest.Cost = newcost
			end
			--print(node.Name,NodeInfo[node.Name])
		end
		
		if not cheapest.Node then
			print("No path")
			return
		end
		
		if table.find(finishConnections,cheapest.Node) then
			print("Path found")
			return retracePath(destination,cheapest.Node,NodeInfo)
		end
		
		previous = cheapest.Node
		
		--local visual = script.Waypoint:Clone()
		--visual.Parent = workspace
		--visual.Position = cheapest.Node.Position
		
		--print(NodeInfo[previous.Name])
		table.remove(openList,table.find(openList,cheapest.Node))
		table.insert(closedList,cheapest.Node.Name)
		local nodeID = table.find(Nodes,previous)
		--print(graph[nodeID],nodeID,Nodes[1])
		if graph[nodeID] then
			for i,beam : Beam in graph[nodeID] do
				local v = beam.Attachment0.Parent
				if not table.find(closedList,v.Name) then
					table.insert(openList,v)
				end
				
				v = beam.Attachment1.Parent
				if not table.find(closedList,v.Name) then
					table.insert(openList,v)
				end
			end
		end
		
	end
	print("ran out of moves lol")
	return
end

script.Execute.OnInvoke = findPathToCFrame

-- wait until the entire graph is loaded in
wait(1)
graph,Nodes = script:WaitForChild("SetupGraph"):WaitForChild("Setup"):Invoke(
	NodeFolder:WaitForChild("Connections")
)