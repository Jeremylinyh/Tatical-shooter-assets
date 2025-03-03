-- The script that controls NPC behavior

local CS: CollectionService = game:GetService("CollectionService")
local yellDistance : number = 60
local npcTag : string = "suspect"

local helper = require(game:GetService("ReplicatedStorage"):WaitForChild("Helper"))
local npcRandom = Random.new()

local function openFire(NPC : Model,target : Model)
	NPC:SetAttribute("indecisive",false)
	print("shoot")
	local animation = helper.loadAnimationFromID(913402848,NPC.Humanoid:WaitForChild("Animator")
		,Enum.AnimationPriority.Action4)
	animation:Play()
end
local function surrender(NPC : Model)
	--913402848
	local animation = helper.loadAnimationFromID(913402848,NPC.Humanoid:WaitForChild("Animator")
		,Enum.AnimationPriority.Action4)
	NPC:SetAttribute("indecisive",false)
	animation:Play()
	print("surrender")
end

local function reactToSeeingPlayer(NPC:Model,character : Model)
	wait(0.3)
	if not NPC:GetAttribute("indecisive") then
		return
	end
	-- TODO: complicate this
	local surrenderChance = NPC:GetAttribute("ChanceOfSurrender")
	local deciding : boolean = true
	
	if not NPC:GetAttribute("Armed") then
		surrender(NPC)
		return
	else
		openFire(NPC,character)
		return -- TODO : remove
	end
	
	--while deciding and NPC:GetAttribute("Responsive") do
	--	local decision = npcRandom:NextNumber() < surrenderChance
	--	if decision and not NPC:GetAttribute("Armed") then
	--		surrender(NPC)
	--		return
	--	elseif not decision then
	--		openFire(NPC,character)
	--		return
	--	end
	--	print("deciding")
	--	wait(npcRandom:NextNumber() + 1)
	--end
end

local function faceSoundPosition(NPC : Model, soundPos : Vector3)
	if not NPC:GetAttribute("indecisive") then
		return
	end
	
	local NPCpos : Vector3 = NPC:GetPivot().Position
	local toPlayer : Vector3 = soundPos - NPCpos
	if soundPos.Magnitude < yellDistance then
		local playerPos : Vector3 = Vector3.new(soundPos.X,NPCpos.Y,soundPos.Z)
		local original = NPC:GetPivot()
		local NPCCFrame = CFrame.lookAt(NPC:GetPivot().Position,playerPos)
		NPC:PivotTo(NPCCFrame)
		
		local threat : Model = script.Parent:WaitForChild("VisualDetermination"):WaitForChild("SeenPlayer"):Invoke(NPC)
		NPC:PivotTo(original)
		if threat then
			local surrenderChance = NPC:GetAttribute("ChanceOfSurrender")
			local decision = npcRandom:NextNumber() < surrenderChance
			decision = (original.LookVector:Dot(NPCCFrame.LookVector)<0) -- facing away -- TODO: remove
			if decision then
				surrender(NPC)
			else
				reactToSeeingPlayer(NPC,threat)
			end
			
		end
	end
end

-- The entry point to this script
local function Behavior(NPC : Model)
	-- turn to face the direction of sound
	game:GetService("ReplicatedStorage"):WaitForChild("Sounds"):WaitForChild("Yell").OnServerEvent:Connect(function(player)
		if not player or not player.Character then
			return
		end
		
		faceSoundPosition(NPC,player.Character:GetPivot().Position)
	end)
	
	NPC:WaitForChild("Humanoid").Died:Connect(function()
		NPC:SetAttribute("Responsive",false)
	end)
	
	while not NPC:GetAttribute("Alerted") and NPC:GetAttribute("Responsive") do
		wait(1)
		local characterSeen : Model = script.Parent:WaitForChild("VisualDetermination"):WaitForChild("SeenPlayer"):Invoke(NPC)
		--print(characterSeen)
		if characterSeen then
			reactToSeeingPlayer(NPC,characterSeen)
		end
	end
end

for i,v in CS:GetTagged(npcTag) do
	coroutine.wrap(Behavior)(v)
	wait(0.1)
end

CS:GetInstanceAddedSignal(npcTag):Connect(function(a)
	print(a)
	coroutine.wrap(Behavior)(a)
end)

CS:GetInstanceRemovedSignal(npcTag):Connect(function()
	
end)

