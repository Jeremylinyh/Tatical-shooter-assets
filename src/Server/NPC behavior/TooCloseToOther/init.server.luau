-- determine adjustment if NPC is too close to another NPC

local memory = {} -- stores each NPC autoadjust each "frame"

-- TODO: finish implementing

script:WaitForChild("Evaluate").OnInvoke = function(character)
	local optimal : Vector3 = Vector3.new()
	
	if optimal.X == 0 and optimal.Z == 0 then
		optimal = nil
	end
	return optimal
end