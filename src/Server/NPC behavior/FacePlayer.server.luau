-- controls NPC firing.
-- this is a standalone system
-- faces the player and depending on how much can be seen, decide whether to crouch

local CS : CollectionService = game:GetService("CollectionService")
local TS : TweenService = game:GetService("TweenService")

local TInfo : TweenInfo = TweenInfo.new(0.3)
local pastDeltas : {Tween} = {}
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
		
		--task.wait()
		--local previousTime = pastDeltas[shooter] or time()
		--pastDeltas[shooter] = time()
		
		local shooterGoalCF : CFrame = CFrame.lookAt(
			shooter:GetPivot().Position * Vector3.new(1,0,1),
			target:GetPivot().Position * Vector3.new(1,0,1),
			Vector3.yAxis
		)

		--local alpha : number = shooter:GetAttribute("TurnSpeed") 
		--if not alpha then
		--	alpha = turnDelay * (time()-previousTime)
		--end
		--shooter:PivotTo(
		--	CFrame.new(shooter:GetPivot().Position)
		--		* shooterGoalCF.Rotation:Lerp(shooter:GetPivot().Rotation,alpha)
		--)
		
		local proxy : CFrameValue = Instance.new("CFrameValue")
		proxy.Value = shooter:GetPivot()
		local proxyChange : RBXScriptConnection
		proxyChange = proxy.Changed:Connect(function(value : CFrame)
			shooter:PivotTo(proxy.Value)
		end)
		local goal = {}
		goal.Value = CFrame.new(proxy.Value.Position) * shooterGoalCF.Rotation
		if pastDeltas[shooter] then
			pastDeltas[shooter]:Cancel()
		end
		local tween : Tween = TS:Create(proxy,TInfo,goal)
		tween:Play()
		pastDeltas[shooter] = tween
		tween.Completed:Connect(function()
			if proxyChange then
				proxyChange:Disconnect()
				proxyChange = nil
			end
			if proxy then
				proxy:Destroy()
			end
		end)

		local currentWeapon : string = shooter:GetAttribute("Weapon")
		if not currentWeapon then
			continue
		end
		-- TODO: add shooting logic here
	end
end

