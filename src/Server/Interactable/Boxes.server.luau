-- The script define what happen when you hold f on powerbox

local CS : CollectionService = game:GetService("CollectionService")
local Security = require(game:GetService("ServerScriptService"):WaitForChild("SecOps"):WaitForChild("Main"))
local classname : string = "BoxInput"
local loud = game.ServerScriptService.GlobalStates.LoudBegin
local dangerous = true
local howmanybox = #(workspace.Level.Objectives.Required:GetChildren())
--print(howmanybox)
local howmanyactivated = 0

local function onInteractSucess(box : Model,player : Player)
	box:SetAttribute("On",true)
	box:FindFirstChild("FullyRewired"):Fire()
	local security = box:FindFirstChild("Security")
	if security then
		if security.Value == true then
			--box.Part.Color = Color3.fromRGB(100,100,100)
			dangerous = false
		end
	end
	local text = box.Left.SurfaceGui.Frame.TextLabel
	box:SetAttribute("Usedby","unusable")
	text.Text = "On"
	local protected = box:FindFirstChild("Protected")
	if protected and dangerous == true then
		loud:Fire()
	end
	
	--objective handler
	if not security then
		howmanyactivated = howmanyactivated + 1
	end
	--print(howmanyactivated)
	if howmanybox == howmanyactivated then
		print("All boxes activated")
	end
end

local function freezePlayer(player : Player, freezing : boolean)
	game:GetService("ReplicatedStorage"):WaitForChild("Player"):WaitForChild("FreezePlayer")
	:FireClient(player,freezing)
	player:SetAttribute("Interacting",freezing)
end

local function setCurrentInteractor(box : Model,interactor : string)
	--print(interactor)
	box:SetAttribute("Usedby",interactor)
end

local function theBox(box : Model)
	local boxIsOn : boolean = false
	local coro
	box:WaitForChild("Use").OnServerEvent:Connect(function(player : Player)
		-- if another player is using, disallow
		if box:GetAttribute("Usedby") ~= "" and box:GetAttribute("Usedby") ~= tostring(player.UserId) then
			local id = tonumber(box:GetAttribute("Usedby"))
			print(box:GetAttribute("Usedby"))
			if not id then
				return
			end
			game.ServerScriptService.GlobalStates.TellPlayerInfo.AlertPlayer:Fire(player,
				"Box is currently rewired by "..game:GetService("Players"):GetPlayerByUserId(id).DisplayName
			)
			return
		end
		
		-- if not in use (indicated by coro == nil), hold f started, else, kill the coroutine
		if coro then
			coroutine.close(coro)
			coro = nil
			--print("F was pressed again")
			freezePlayer(player,false)
			--print(player.UserId,tostring(player.UserId))
			setCurrentInteractor(box,"")
		else
			freezePlayer(player,true)
			coro = coroutine.create(function()
				setCurrentInteractor(box,tostring(player.UserId))
				wait(2)
				--print("2")
				freezePlayer(player,false)
				boxIsOn = true
				onInteractSucess(box,player)
				--print(player.UserId,tostring(player.UserId))
				
			end)
			coroutine.resume(coro)
		end
	end)
	
	-- Enemy has disabled the box
	box:WaitForChild("Use"):FindFirstChildOfClass("BindableEvent").Event:Connect(function()
		boxIsOn = false
	end)
end


-- J: I suggest making this a different script so what boxes do would be more clear.
-- not required but slightly more readable in case we forgot how boxes works in the future.

-- alternatively you can make this one line by doing howmanybox = #CS:GetTagged(classname)
-- thx, I have no idea how to work with collectionservice lol
for i,box : Model in pairs(CS:GetTagged(classname)) do
	theBox(box)
end
-- suggest to change to <= to allow scrs situation: 4 avaliable, only 3 required


CS:GetInstanceAddedSignal(classname):Connect(theBox)
