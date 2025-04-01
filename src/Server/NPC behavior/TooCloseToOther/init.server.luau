-- determine adjustment if NPC is too close to another NPC

local CS : CollectionService = game:GetService("CollectionService")

local updateFrequency : number = 0.1 -- seconds
local targetTag : string = "Enemy"
local memory = {} -- stores each NPC autoadjust each "frame"

-- TODO: finish implementing

script:WaitForChild("Evaluate").OnInvoke = function(character)
	local optimal : Vector3 = memory[character]
	
	if not optimal or ( optimal.X == 0 and optimal.Z == 0 ) then
		return nil
	--else
	--	if optimal.Magnitude < 3 then
	--		optimal = optimal.Unit * 3
	--	end
	end
	--print(optimal)
	return optimal
end

-- O(n) = n^2
while wait(updateFrequency) do
	local updatedMemory = {}
	
	local allRelevant = CS:GetTagged(targetTag)
	--print(allRelevant)
	for outerI,currentSelf : Model in ipairs(allRelevant) do
		--print(outerI,currentSelf, #allRelevant)
		
		for innerI = outerI + 1, #allRelevant do
			other = allRelevant[innerI]
			--print(innerI)
			local difference : Vector3 = other:GetPivot().Position -currentSelf:GetPivot().Position
			difference *= Vector3.new(1,0,1)
			difference += currentSelf:GetPivot().LookVector * Vector3.new(1,0,1) * 0.1
			--print(currentSelf:GetPivot().LookVector * Vector3.new(1,0,1))
			local distanceInBetween = difference.Magnitude + 0.01
			
			
			if distanceInBetween > 3 then
				continue
			end
			
			difference = difference/distanceInBetween
			--
			--local weight = math.pow(distanceInBetween,2) 
			--weight = math.max(0.3,weight) 
			--weight = 1/weight
			--weight = math.max(1,weight)
			--print(weight)
			difference = difference--*weight
			--print(difference.Magnitude == 0,difference)
			
			if not updatedMemory[currentSelf] then
				updatedMemory[currentSelf] = Vector3.new()
			end
			if not updatedMemory[other] then
				updatedMemory[other] = Vector3.new()
			end
			--print(difference)
			updatedMemory[currentSelf] -= difference
			updatedMemory[other] += difference
		end
	end
	
	memory = updatedMemory
end