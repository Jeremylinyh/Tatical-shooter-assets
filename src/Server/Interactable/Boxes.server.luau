-- The script define what happen when you hold f on powerbox

local CS : CollectionService = game:GetService("CollectionService")
local Security = require(game:GetService("ServerScriptService"):WaitForChild("SecOps"):WaitForChild("Main"))
local classname : string = "BoxInput"

local function onInteractSucess(box : Model,player : Player)
	box.Part.Color = Color3.fromRGB(100,100,100)
end

local function freezePlayer(player : Player, freezing : boolean)
	game:GetService("ReplicatedStorage"):WaitForChild("Player"):WaitForChild("FreezePlayer")
	:FireClient(player,freezing)
end

local function theBox(box : Model)
	local boxIsOn : boolean = false
	local coro
	box:WaitForChild("Use").OnServerEvent:Connect(function(player : Player)
		-- if not in use (indicated by coro == nil), hold f started, else, kill the coroutine
		 if coro then
			coroutine.close(coro)
			coro = nil
			--print("F was pressed again")
			freezePlayer(player,false)
		 else
			freezePlayer(player,true)
			coro = coroutine.create(function()
				wait(2)
				print("2")
				freezePlayer(player,false)
				boxIsOn = true
				onInteractSucess(box,player)
			end)
			coroutine.resume(coro)
		 end
	end)
	
	-- Enemy has disabled the box
	box:WaitForChild("Use"):FindFirstChildOfClass("BindableEvent").Event:Connect(function()
		boxIsOn = false
		box.Part.Color = Color3.fromRGB(0,0,0)
	end)
end

for i,box : Model in pairs(CS:GetTagged(classname)) do
	theBox(box)
end

CS:GetInstanceAddedSignal(classname):Connect(theBox)