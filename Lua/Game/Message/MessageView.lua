local MessageView = BaseClass(UINode)
function MessageView:Constructor()
	self.viewCfg = {
		prefabPath = "Assets/AssetBundleRes/ui/common/p_message.prefab",
		canvasName = "Top",
		}
end

function MessageView:OnLoad()
	local names = {
		"txt_message",
		}
	UI.GetChildren(self, self.transform, names)
	self.message = self.txt_message:GetComponent("Text");

	self.message.text = self.message_text
end

function MessageView:SetMessage(message)
	message = message or ""
	self.message_text = message

end

return MessageView