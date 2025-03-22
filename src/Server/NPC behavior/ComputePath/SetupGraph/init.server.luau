-- returns a fully set up graph in a non optimal way.

local function getNodeID(nodeA : Attachment,graph,Nodes)
	if not table.find(Nodes,nodeA) then
		table.insert(Nodes,nodeA)
	end
	local nodeAID = table.find(Nodes,nodeA)
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

	-- list of all connections (beams)
	local connections = {}

	local connections = beamFolder:GetChildren()
	for i,beam : Beam in ipairs(connections) do
		table.insert(connections, beam)
		local nodeA = beam.Attachment0
		local nodeB = beam.Attachment1

		local AID = getNodeID(nodeA,graph,Nodes)
		table.insert(graph[AID], beam)
		local BID = getNodeID(nodeB,graph,Nodes)
		table.insert(graph[BID], beam)

	end
	return graph, Nodes --, connections 
end

-- graph is an array which given a node name, returns all the beam attached to it.
script:WaitForChild("Setup").OnInvoke = BakeGraph
