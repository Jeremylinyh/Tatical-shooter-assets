-- controls NPC firing.
-- this is a standalone system
-- faces the player and depending on how much can be seen, decide whether to crouch

local CS : CollectionService = game:GetService("CollectionService")

local turnDelay : number = 0.6 -- default turn delay if not specified in character model

while task.wait() do
	local allNPC = CS:GetTagged("Enemy")
	for i,shooter : Model in ipairs(allNPC) do
		local humanoid = shooter:FindFirstChild("Humanoid")
		local target: Model = -- character model
			script.Parent.CanSeePlayer.SeenPlayer:Invoke(shooter)

		if not humanoid or not target then 
			continue
		end
		local attacking : boolean = not humanoid.AutoRotate
		if not attacking then
			continue
		end

		local shooterGoalCF : CFrame = CFrame.lookAt(
			shooter:GetPivot().Position,
			target:GetPivot().Position,
			Vector3.yAxis
		)

		local alpha : number = shooter:GetAttribute("TurnSpeed") 
		if not alpha then
			alpha = turnDelay
		end
		shooter:PivotTo(
			CFrame.new(shooter:GetPivot().Position)
				* shooterGoalCF.Rotation:Lerp(shooter:GetPivot().Rotation,alpha)
		)

		local currentWeapon : string = shooter:GetAttribute("Weapon")
		if not currentWeapon then
			continue
		end
		-- TODO: add shooting logic here
	end
end

