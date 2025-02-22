-- handle input recieved by the Firearm class

local CS : CollectionService = game:GetService("CollectionService")

local ActionTag : string = "FirearmInput"

local helperFunctions = require(game:GetService("ReplicatedStorage"):WaitForChild("Helper"))
local gunstats = require(game:GetService("ReplicatedStorage"):WaitForChild("Weapon"):WaitForChild("GunStats"))

local shootButtons = {}
table.insert(shootButtons,Enum.UserInputType.MouseButton1)
local reloadButtons = {}
table.insert(reloadButtons,Enum.KeyCode.R)

local currentBurstStreak : number = 0
local firing : boolean = false

local function fireWeapon(fireButton : RemoteEvent,weaponType : Model)
	currentBurstStreak = 0
	
	while firing and currentBurstStreak < gunstats[weaponType:GetAttribute("Type")].Burst and weaponType:GetAttribute("Magazine")>0 do
		-- fire
		--print("pew")
		fireButton:FireServer(workspace.CurrentCamera.CFrame 
			*game:GetService("Players").LocalPlayer.PlayerScripts.Viewmodel.GetCurrentRecoil:Invoke())
		game:GetService("Players").LocalPlayer.PlayerScripts.Viewmodel.Gunfire:Fire(time())
		currentBurstStreak += 1
		wait(gunstats[weaponType:GetAttribute("Type")].CooldownBetweenShots)
	end
	
	--reciever.FireWeapon:FireServer(workspace.CurrentCamera)
end

local function processInputEvent(reciever : BindableEvent)
	reciever.Event:Connect(function(input : InputObject,began)
		if helperFunctions.InputInList(input,shootButtons) then
			if began then
				-- commence firing
				firing = true
				fireWeapon(reciever:WaitForChild("FireWeapon"),reciever.Parent)
			else
				-- stop firing
				firing = false
			end
		end
	end)
end

for i,v : BindableEvent in CS:GetTagged(ActionTag) do
	processInputEvent(v)
end

CS:GetInstanceAddedSignal(ActionTag):Connect(processInputEvent)