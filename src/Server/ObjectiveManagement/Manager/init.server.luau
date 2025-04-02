-- I load the appoporite script for the level we are currently on.

-- for another level, add another module script.
-- swap level by simply loading that one instead.

local levelWeAreOn: string = "TheBoxes"--please do not rename this. We can change the display name thou
local init = require(script:WaitForChild(levelWeAreOn))
init()
