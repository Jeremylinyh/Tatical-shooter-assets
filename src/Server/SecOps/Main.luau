-- handles security

local playerstats = require(game:GetService("ReplicatedStorage"):WaitForChild("Player"):WaitForChild("PlayerStats"))
local module = {}

function module.PlayerInRange(player : Player,position : Vector3, maxDistance : number) : boolean
	if not maxDistance then
		maxDistance = playerstats.ArmLength + 3 -- give or take
	end
	
	local character : Model? = player.Character
	if not character then
		return false
	end
	local playerPos : Vector3 = character:GetPivot().Position
	local distance : number = (position - playerPos).Magnitude
	return distance < maxDistance
end

return module
