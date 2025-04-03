-- useful functions all script can benefit from

local module = {}

function module.InputInList(input : InputObject,list)
	for i,v in pairs(list) do
		if v == input.KeyCode or v == input.UserInputType then
			return true
		end
	end
	return false
end

function module.loadAnimationFromID(ID : number,animator : Animator,priority : Enum.AnimationPriority,specName : string) : AnimationTrack
	local animation = Instance.new("Animation")
	animation.AnimationId = "rbxassetid://"..ID
	if specName then
		animation.Name = specName
	end
	local animationTrack = animator:LoadAnimation(animation)
	animationTrack.Looped = true
	if priority then
		animationTrack.Priority = priority
		--animationTrack:AdjustWeight(1000000)
	else
		animationTrack.Priority = Enum.AnimationPriority.Idle
		--animationTrack:AdjustWeight(0.0000001)
	end
	
--	print(animationTrack.Priority)
	return animationTrack
end

return module
