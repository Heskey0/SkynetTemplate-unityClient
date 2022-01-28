local LoginView = BaseClass(UINode)

function LoginView:Constructor( )
	self.viewCfg = {
		prefabPath = "Assets/AssetBundleRes/ui/login/p_login.prefab",
		canvasName = "Normal",
	}
end

function LoginView:OnLoad(  )
	local names = {
		"if_account",
		"if_password",
		"if_login_server_ip",
		"if_login_server_port",
		"if_game_server_ip",
		"if_game_server_port",
		"btn_login",
		"btn_exit",
	}
	UI.GetChildren(self, self.transform, names)
    self.account = self.if_account:GetComponent("InputField")
    self.password = self.if_password:GetComponent("InputField")
	self.login_server_ip = self.if_login_server_ip:GetComponent("InputField")
	self.login_server_port = self.if_login_server_port:GetComponent("InputField")
	self.game_server_ip = self.if_game_server_ip:GetComponent("InputField")
	self.game_server_port = self.if_game_server_port:GetComponent("InputField")
	self.login = self.btn_login.gameObject
	self.exit = self.btn_exit.gameObject
    self.transform.sizeDelta = Vector2.New(0, 0)
	self:AddEvents()
	self:UpdateView()
end

function LoginView:AddEvents(  )
	local on_click = function ( click_obj )
		if click_obj == self.login then
	        local account = tonumber(self.account.text)
	        if not account then
	            account = 123
	        end
			local password = tonumber(self.password.text)
			if not password then
				password = "password"
			end
			
	        local login_info = {
	            account = account,
	            password = password,
	            login_server_ip = self.login_server_ip.text,
	            login_server_port = self.login_server_port.text,
				game_server_ip = self.game_server_ip.text;
				game_server_port = self.game_server_port.text;
	        }
	        print("Cat:LoginView [start:40] login_info:", login_info)
	        GlobalEventSystem:Fire(LoginConst.Event.StartLogin, login_info)
		elseif click_obj == self.exit then
			print("[LoginView]: Quit")
			CS.UnityEngine.Application.Quit()
		end
	end

	UIHelper.BindClickEvent(self.login, on_click)
	UIHelper.BindClickEvent(self.exit, on_click)
end

function LoginView:UpdateView(  )
		--TODO:the default ip and port
		self.account.text =  ""
		self.login_server_ip.text = "192.168.3.72"
		self.login_server_port.text = "8001"
		self.game_server_ip.text = "192.168.3.72"
        self.game_server_port.text = "8888"
end
        
return LoginView