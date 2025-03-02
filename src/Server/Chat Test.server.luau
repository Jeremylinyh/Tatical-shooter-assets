-- TODO: Destroy
wait(6)
local textCollection = {0.1,"C.How does this work? your guess is as good as mine.|"
	,"C.So yes, this is from entry point, deal with it.|"
	,"E. Cough Cough, text color change (Not sure who this is)|"
}
game.ReplicatedStorage:WaitForChild("GlobalEvents"):WaitForChild("StorytellerDialouge"):FireAllClients(textCollection)
