local module = {}

function module.InputInList(input : InputObject,list)
	for i,v in pairs(list) do
		if v == input.KeyCode or v == input.UserInputType then
			return true
		end
	end
	return false
end

return module
