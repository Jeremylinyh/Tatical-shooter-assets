-- test the pathfinding algorithm

-- node attachment test
local start = workspace:WaitForChild("Test"):WaitForChild("Start")
local finish = workspace:WaitForChild("Test"):WaitForChild("End")

wait(1)

while true do
	wait(1)
	script.Parent.Execute:Invoke(start.CFrame,finish.CFrame)
	--break
end