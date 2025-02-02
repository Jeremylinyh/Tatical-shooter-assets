-- if all players vote yes, start the game

local players : Players = game:GetService("Players")
local voteEvent : RemoteEvent = game:GetService("ReplicatedStorage"):WaitForChild("Vote"):WaitForChild("StartGame")
local informEvent : RemoteEvent = game:GetService("ReplicatedStorage"):WaitForChild("Vote"):WaitForChild("TeammateInfo")

local tally = {} -- tally[player] --> ready
local allready : boolean = false

local function informClient()
	local sendable = {}
	for i,v in pairs(tally) do
		--print(v)
		sendable[i.Name] = v
	end
	
	informEvent:FireAllClients(sendable)
end

players.PlayerAdded:Connect(function(player)
	player:LoadCharacter()
	local character = player.Character
	if not character then
		player.CharacterAdded:Wait()
		character = player.Character
	end
	character.Parent = game:GetService("ServerStorage")
	
	tally[player] = false
	informClient()
end)

players.PlayerRemoving:Connect(function(player)
	tally[player] = nil -- lua be like
	informClient()
end)

-- determine if everyone voted yes
local function allYesVotes() : boolean
	for i,ready : boolean in pairs(tally) do
		if not ready then
			return false
		end
	end
	return true
end

voteEvent.OnServerEvent:Connect(function(player,value : boolean)
	if not (typeof(value) == "boolean") then
		return
	end
	if not value then
		allready = false
	end
	
	tally[player] = value -- set readiness, player decide
	informClient()
	
	if not allready then
		allready = true
		if not allYesVotes() then
			allready = false
			return
		end
		wait(1) -- continue to be ready for 3 seconds
		if not allYesVotes() then
			allready = false
			return
		end
		if allready then
			--print("all ready")
			script.Parent.SpawnPlayer:Fire()
			voteEvent:FireAllClients()
		end
	end
end)