-- test the pathfinding algorithm

-- node attachment test
local exampleAgent = workspace:WaitForChild("Test"):WaitForChild("ExampleAgent")

wait(1)

while true do
	wait(0.1)
	local result = 
		script.Parent.TempNode.Attach:Invoke(exampleAgent.Position,workspace.Level.Navigation,exampleAgent)
	
	--wait(100)
end