-- bind characters to be ragdolled

local CS : CollectionService = game:GetService("CollectionService")

local validTags = {"Player","suspect"}

local function bindCharacterToRagdoll(character : Model)
	local beginRagdoll : RBXScriptConnection = nil
	beginRagdoll = character:FindFirstChildOfClass("Humanoid").Died:Connect(function()
		beginRagdoll:Disconnect()
		for i,tag in ipairs(CS:GetTags(character)) do
			CS:RemoveTag(character, tag)
		end
		script.Parent.RagdollCharacter:Fire(character)
	end)
end

for i,tag in pairs(validTags) do
	for i,char in CS:GetTagged(tag) do
		bindCharacterToRagdoll(char)
	end
	CS:GetInstanceAddedSignal(tag):Connect(function(char)
		bindCharacterToRagdoll(char)
	end)
end
