-- help the NPC reload

local gunstats = 
	require(game:GetService("ReplicatedStorage"):WaitForChild("Weapon"):WaitForChild("GunStats"))
local helper = require(game:GetService("ReplicatedStorage"):WaitForChild("Helper"))

local reloadAnime = {}
local currentlyReloading = {}

script:WaitForChild("Begin").Event:Connect(function(shooter : Model)
	if currentlyReloading[shooter] then return end
	local currentWeapon : string = shooter:GetAttribute("Weapon")
	if not currentWeapon then
		return
	end

	local gunModel : Model = shooter:FindFirstChild(currentWeapon)
	if not gunModel then
		print("we lost the gun oops")
		return
	end
	
	local humanoid : Humanoid = shooter:FindFirstChildOfClass("Humanoid")
	if humanoid and humanoid.Health > 0 then
	else
		return
	end
	local animator : Animator = humanoid:FindFirstChildOfClass("Animator")
	if not animator then
		return
	end
	currentlyReloading[shooter] = true
	
	local aimanime : AnimationTrack = nil
	for i,v : AnimationTrack in animator:GetPlayingAnimationTracks() do
		if v.Animation.Name == "Aim" then
			v:Stop()
			aimanime = v
			break
		end
	end
	if not reloadAnime[shooter] then
		reloadAnime[shooter] = helper.loadAnimationFromID(103580467225948,animator,Enum.AnimationPriority.Action4)
		reloadAnime[shooter].Looped = false
		reloadAnime[shooter]:AdjustSpeed(gunstats[gunModel:GetAttribute("Type")].ReloadTime)
	end
	reloadAnime[shooter]:Play()
	
	gunModel:SetAttribute(
		"Magazine",math.ceil(gunModel:GetAttribute("Magazine")/10000)
	)
	reloadAnime[shooter].Stopped:Wait()
	gunModel:SetAttribute(
		"Magazine",
		gunModel:GetAttribute("Magazine")
			+gunstats[gunModel:GetAttribute("Type")].magsize
	)
	aimanime:Play()
	currentlyReloading[shooter] = nil
end)