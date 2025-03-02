-- TODO: Destroy
local clientTextReciver : RemoteEvent = 
	game.ReplicatedStorage:WaitForChild("GlobalEvents"):WaitForChild("StorytellerDialouge")

local indicators = {}
indicators.Coordinator = "H."
indicators.PlayerCharacter = "C."

local notReady : boolean = true
game:GetService("ServerScriptService"):WaitForChild("GameBegin"):WaitForChild("SpawnPlayer").Event
	:Connect(function()
	notReady = false
		local textCollection = {0.1,indicators.Coordinator.."Alright, this mission is quite simple.|"
			,indicators.Coordinator.."Walk up to the lever, flip them, keep them flipped.|"
			,indicators.Coordinator.."Any questions? No? Then lets get to work.|"
	}
	clientTextReciver:FireAllClients(textCollection)
end)

wait(6)
if notReady then
	local textCollection = {0.1,indicators.Coordinator.."Ready up! Everyone is dying in here!.|"
		,indicators.PlayerCharacter.."Relax, this mission is training!|"
		,indicators.Coordinator.."Well I got other stuff after.|"
	}
	clientTextReciver:FireAllClients(textCollection)
end