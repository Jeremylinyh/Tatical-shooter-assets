local defaultHeight : number = 0
local crouchState = {}
crouchState.Stand = defaultHeight
crouchState.Crouch = defaultHeight-1.5
crouchState.Crawl = defaultHeight-3.7
return crouchState