-- returns a fully set up graph in a non optimal way.

local function getNodeID(nodeA : Attachment,graph,Nodes)
	if not table.find(Nodes,nodeA) then
		table.insert(Nodes,nodeA)
	end
	local nodeAID = table.find(Nodes,nodeA)
	--print(nodeA, nodeAID)
	if not graph[nodeAID] then
		graph[nodeAID] = {}
	end
	return nodeAID 
end

local function BakeGraph(beamFolder)
	-- Key: node ID, value: beams connecting nodes
	local graph = {}

	-- list of all the nodes
	local Nodes = {}
	for i,v in ipairs(beamFolder.Parent:GetChildren()) do
		if v:FindFirstChildOfClass("Attachment") then
			table.insert(Nodes,v)
			--print(v,table.find(Nodes,v.Attachment))
		end
	end

	-- list of all connections (beams)
	local connections = {}

	local connections = beamFolder:GetChildren()
	for i,beam : Beam in ipairs(connections) do
		local nodeA = beam.Attachment0
		local nodeB = beam.Attachment1
		
		if not nodeA or not nodeB then
			-- guess who had been negligent
			continue
		end
		--print(beam)
		--wait()
		local AID = getNodeID(nodeA.Parent,graph,Nodes)
		table.insert(graph[AID], beam)
		local BID = getNodeID(nodeB.Parent,graph,Nodes)
		table.insert(graph[BID], beam)

	end
	print(#graph)
	return graph, Nodes --, connections 
end

-- graph is an array which given a node name, returns all the beam attached to it.
script:WaitForChild("Setup").OnInvoke = BakeGraph
