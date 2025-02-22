local module = {}

function module.InputInList(input : InputObject,list)
	for i,v in pairs(list) do
		if v == input.KeyCode or v == input.UserInputType then
			return true
		end
	end
	return false
end

function module.loadAnimationFromID(ID : number,animator : Animator,priority : Enum.AnimationPriority) : AnimationTrack
	local animation = Instance.new("Animation")
	animation.AnimationId = "rbxassetid://"..ID
	local animationTrack = animator:LoadAnimation(animation)
	animationTrack.Looped = true
	if priority then
		animationTrack.Priority = priority
	else
		animationTrack.Priority = Enum.AnimationPriority.Core
	end
	--print(animationTrack.Priority)
	return animationTrack
end

return module
