-- handle input recieved by the Firearm class

local CS : CollectionService = game:GetService("CollectionService")
local TS : TweenService = game:GetService("TweenService")
local Deb: Debris = game:GetService("Debris")

local ActionTag : string = "FirearmInput"

local helperFunctions = require(game:GetService("ReplicatedStorage"):WaitForChild("Helper"))
local gunstats = require(game:GetService("ReplicatedStorage"):WaitForChild("Weapon"):WaitForChild("GunStats"))

local shootButtons = {}
table.insert(shootButtons,Enum.UserInputType.MouseButton1)
local reloadButtons = {}
table.insert(reloadButtons,Enum.KeyCode.R)

local currentBurstStreak : number = 0
local firing : boolean = false

local function ejectShell(weapon : Model)
	coroutine.wrap(function(weapon : Model)
		local shell : Model = game:GetService("ReplicatedStorage"):WaitForChild("Guns").Shell:Clone()
		shell:PivotTo(weapon.Body.ShellSpawn.WorldCFrame)
		shell.Parent = workspace
		local center : Part = shell.PrimaryPart
		shell.PrimaryPart.AssemblyLinearVelocity = game:GetService("Players").LocalPlayer.Character.PrimaryPart.AssemblyLinearVelocity
		center:ApplyImpulse(weapon.Eject.CFrame.RightVector/16)
		Deb:AddItem(shell,1)
	end)(weapon)
	
end

local function cycleChamber(weapon : Model,timeItTakes : number)
	coroutine.wrap(function(weapon : Model,timeItTakes : number)
		local chamber : Weld = weapon.Eject.Weld
		local original = CFrame.new()
		local tweeninfo : TweenInfo = TweenInfo.new(timeItTakes/4)
		
		chamber.C0 = original
		local goal = {}
		goal.C0 = CFrame.new(chamber:GetAttribute("OutPos"))
		local T : Tween = TS:Create(chamber,tweeninfo,goal)
		T:Play()
		T.Completed:Wait()
		wait(timeItTakes/4)
		goal.C0 = original
		local T : Tween = TS:Create(chamber,tweeninfo,goal)
		T:Play()
	end)(weapon,timeItTakes)
end

local function showMuzzleFlash(weaponType : Model)
	coroutine.wrap(function(weaponType : Model)
		local muzzleFlash = game:GetService("ReplicatedStorage").Guns.MuzzleFlash:Clone()
		muzzleFlash.Parent = workspace
		muzzleFlash.RigidConstraint.Attachment0.CFrame *= CFrame.Angles(0,Random.new():NextNumber(),0)
		muzzleFlash.RigidConstraint.Attachment1 = weaponType.Body.FlashPos
		muzzleFlash:ScaleTo(Random.new():NextNumber() + 1)
		currentBurstStreak += 1
		local muzzleFlashTime = 0.03

		wait(muzzleFlashTime)
		muzzleFlash:Destroy()
	end)(weaponType)
end

local function fireWeapon(fireButton : RemoteEvent,weaponType : Model)
	currentBurstStreak = 0
	
	while firing and currentBurstStreak < gunstats[weaponType:GetAttribute("Type")].Burst and weaponType:GetAttribute("Magazine")>0 do
		-- fire
		--print("pew")
		fireButton:FireServer(CFrame.new(workspace.CurrentCamera.CFrame.Position)
			*game:GetService("Players").LocalPlayer.PlayerScripts.Viewmodel.GetCurrentRecoil:Invoke())
		game:GetService("Players").LocalPlayer.PlayerScripts.Viewmodel.Gunfire:Fire(time())
		showMuzzleFlash(weaponType)
		cycleChamber(weaponType,gunstats[weaponType:GetAttribute("Type")].CooldownBetweenShots)
		ejectShell(weaponType,gunstats[weaponType:GetAttribute("Type")].CooldownBetweenShots)
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