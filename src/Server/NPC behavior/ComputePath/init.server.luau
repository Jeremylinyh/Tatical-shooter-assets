--!native
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

		
		
		--print(finishingNode)
		
		table.insert(traversedNodes,finishingNode)
		finishingNode = NodeInfo[finishingNode.Name].PreviousNode
		
	end
	
	local result = {}
	for i,v in ipairs(traversedNodes) do
		
		result[#traversedNodes-i + 1]=v
	end
	--print(#traversedNodes)
	--for i,v in ipairs(result) do
	--	--wait(1)
	--	--print(i)
	--	local visual = script.Waypoint:Clone()
	--	visual.Parent = workspace
	--	visual.Position = v.Position
	--	game:GetService("Debris"):AddItem(visual,100)
	--end
	--wait(100)
	return result
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
	local startAttachment = Instance.new("Attachment")
	startAttachment.CFrame = startPos
	local originals = {}
	for i,v in ipairs(startConnections) do
		--print(v.Name)
		NodeInfo[v.Name] = {}
		NodeInfo[v.Name].Cost = (v.Position - startPos.Position).Magnitude
		NodeInfo[v.Name].PreviousNode = nil
		
		local duckTypedBeam = {}
		duckTypedBeam.Attachment0 = startAttachment
		duckTypedBeam.Attachment1 = v.Attachment
		
		table.insert(originals,duckTypedBeam)
		--print(duckTypedBeam)
	end
	table.insert(openList,{originals,nil}) --openList[-1] = {originals,nil}
	--print(openList[2147483646],#openList,{originals,nil})
	--print({startConnections,nil})
	local cheapest = {}
	--local previous = nil
	
	-- I commited the function in function. deal with it.
	local function searchOpen(tosearch : {Beam},from : BasePart)
		for i, connection : Beam in ipairs(tosearch) do
			--if cheapest.Node and closedList[cheapest.Node.Name] then
			--	continue
			--end
			--print(connection,from)
			local candidA = connection.Attachment0.Parent
			local candidB = connection.Attachment1.Parent
			--print(candidA,candidB,from)
			if from and (not candidA or not candidB) then
				continue
			end
			local node = candidA
			if candidA == from then
				node = candidB
			end
			--print(node)
			if not node or closedList[node.Name] then
				--print("closed")
				--print(node,from,index)
				continue
			end
			--print(node,node.Parent,from)
			
			
			if not NodeInfo[node.Name] then
				NodeInfo[node.Name] = {}
			end

			--print(NodeInfo[node.Name].PreviousNode)
			local newcost = estimateCost(node,NodeInfo,destination.Position,startPos)
			--print(newcost)
			if (not NodeInfo[node.Name].Cost) or newcost < NodeInfo[node.Name].Cost then
				NodeInfo[node.Name].Cost = newcost
				NodeInfo[node.Name].PreviousNode = from
			end
			if newcost < cheapest.Cost then
				--print(typeof(node))
				cheapest.Node = node
				cheapest.Cost = newcost
				cheapest.Connection = connection
			end
			--print(node.Name,NodeInfo[node.Name])
		end
		--print(cheapest.Node,cheapest.Cost)
	end
	--print(#openList)
	while next(openList) do
		task.wait()
		cheapest.Node = nil
		cheapest.Connection = nil
		cheapest.Cost = math.huge
		
		for i,v in ipairs(openList) do
			--print(i)
			searchOpen(v[1],v[2],i) -- I promise this is not minified code
			-- v[1] is list of beams, v[2] is previous node
			--print(cheapest.Node)
		end
		
		if not cheapest.Node then
			print("No path")
			return
		end
		
		if table.find(finishConnections,cheapest.Node) then
			--print("Path found")
			return retracePath(destination,cheapest.Node,NodeInfo)
		end
		
		--previous = cheapest.Node
		
		--local visual = script.Waypoint:Clone()
		--visual.Parent = workspace
		--visual.Position = cheapest.Node.Position
		
		--print(NodeInfo[previous.Name])
		
		closedList[cheapest.Node.Name] = true
		--openList[cheapest.Index] = nil
		local nodeID = table.find(Nodes,cheapest.Node)
		--print(#openList,graph[nodeID])
		--print(graph[nodeID],nodeID,Nodes[1])
		if graph[nodeID] then
			--local toInsert = {}
			--for i,beam : Beam in graph[nodeID] do
			--	local v = beam.Attachment0.Parent
			--	if not table.find(closedList,v.Name) then
			--		table.insert(openList,v)
			--	end
				
			--	v = beam.Attachment1.Parent
			--	if not table.find(closedList,v.Name) then
			--		table.insert(openList,v)
			--	end
			--end
			table.insert(openList,{graph[nodeID],cheapest.Node}) --openList[nodeID] = {graph[nodeID],cheapest.Node}
			--print({graph[nodeID],cheapest.Node})
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