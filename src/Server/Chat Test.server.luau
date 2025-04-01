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
			,indicators.Coordinator.."Turn on some powerboxes. You know how to do that right?|"
			,indicators.Coordinator.."Any questions? No? Then lets get to work.|"
	}
	clientTextReciver:FireAllClients(textCollection)
end)

wait(60)
if notReady then
	local textCollection = {0.1,indicators.Coordinator.."Ready up! Everyone is dying in here!.|"
		,indicators.PlayerCharacter.."Relax, this mission is only training.|"
		,indicators.Coordinator.."Well I got stuff after.|"
	}
	clientTextReciver:FireAllClients(textCollection)
end