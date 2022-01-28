---------------------------------------------------------------------
-- SkynetClient (C) CompanyName, All Rights Reserved
-- Created by: AuthorName
-- Date: 2021-07-08 10:18:43
---------------------------------------------------------------------

-- To edit this template in: Data/Config/Template.lua
-- To disable this template, check off menuitem: Options-Enable Template File

---@class MessageController
local MessageController = {}

function MessageController:Init()
	self.messageView = require("Game/Message/MessageView").New()
end

return MessageController