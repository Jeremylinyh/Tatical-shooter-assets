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
	return animationTrack
end

return module
