Message = Message or {}

--container:为飘字所在容器
function Message:Init(  )
	--self.messageController = require("Game/Message/MessageController")
	--self.messageController:Init()
end

function Message:Show( message )
	self.messageController = require("Game/Message/MessageController")
	self.messageController:Init()

	self.messageController.messageView:SetMessage(message)
	self.messageController.messageView:Load()
end

--function Message:Update( )
	
--end