require("Game/Login/LoginConst")
local crypt = require "crypt"

LoginController = {}

function LoginController:Init(  )
	self:InitEvents()

    self.loginView = require("Game/Login/LoginView").New()
    self.loginView:Load()
end

function LoginController:InitEvents(  )
    GlobalEventSystem:Bind(LoginConst.Event.StartLogin, LoginController.StartLogin, self)
    GlobalEventSystem:Bind(NetDispatcher.Event.OnConnect, LoginController.Connect, self)
    GlobalEventSystem:Bind(NetDispatcher.Event.OnDisConnect, LoginController.Disconnect, self)
    GlobalEventSystem:Bind(NetDispatcher.Event.OnReceiveLine, LoginController.OnReceiveLine, self)

    local LoginSucceed = function (  )
		--TODO:登录成功
		print('Lua：登录成功')
    end
    self.login_succeed_handler = GlobalEventSystem:Bind(LoginConst.Event.LoginSucceed, LoginSucceed)

    local SelectRoleEnterGame = function ( role_id )
        local on_ack = function ( ack_data )
            if ack_data.result == 1 then
                --进入游戏成功,先关掉所有界面
                UIMgr:CloseAllView()
                --请求角色信息和场景信息
                --self:ReqMainRole()
            else
                --进入游戏失败
            end
        end
        NetDispatcher:SendMessage("account_select_role_enter_game", {role_id = role_id}, on_ack)
    end
end


function LoginController:StartLogin(login_info)
    print('Cat:LoginController.lua[StartLogin]')
    PrintTable(login_info)
    self.login_info = login_info
    --向登录服务器请求连接,一连接上就等待收到其发过来的随机值了(challenge)
    self.login_state = LoginConst.Status.WaitForLoginServerChanllenge

	NetMgr:SendConnect(self.login_info.login_server_ip, self.login_info.login_server_port, CS.XLuaFramework.NetPackageType.BaseLine)
end

function LoginController:OnReceiveLine(bytes) 
    local code = tostring(bytes)
    if self.login_state == LoginConst.Status.WaitForLoginServerChanllenge then
        self.challenge = crypt.base64decode(code)
        self.clientkey = crypt.randomkey()
        local handshake_client_key = crypt.base64encode(crypt.dhexchange(self.clientkey))
        local buffer = handshake_client_key.."\n"
        NetMgr:SendBytes(buffer)
        self.login_state = LoginConst.Status.WaitForLoginServerHandshakeKey
    elseif self.login_state == LoginConst.Status.WaitForLoginServerHandshakeKey then
        self.secret = crypt.dhsecret(crypt.base64decode(code), self.clientkey)
        local hmac = crypt.hmac64(self.challenge, self.secret)
        local hmac_base = crypt.base64encode(hmac)
        NetMgr:SendBytes(hmac_base.."\n")

        local token = {
            server = "DevelopServer",
            user = self.login_info.account,
            pass = self.login_info.password,
        }
        self.token = token
        local function encode_token(token)
            return string.format("%s@%s:%s",
                crypt.base64encode(token.user),
                crypt.base64encode(token.server),
                crypt.base64encode(token.pass))
        end
        local etoken = crypt.desencode(self.secret, encode_token(token))
        local etoken_base = crypt.base64encode(etoken)
        NetMgr:SendBytes(etoken_base.."\n")

        self.login_state = LoginConst.Status.WaitForLoginServerAuthorResult
    elseif self.login_state == LoginConst.Status.WaitForLoginServerAuthorResult then
        local result = tonumber(string.sub(code, 1, 3))
        if result == 200 then
            print('Cat:LoginController.lua login succeed!')
            self.subid = crypt.base64decode(string.sub(code, 5))
            self:StartConnectGameServer()
        else
            self.error_map = self.error_map or {
                [400] = "握手失败",
                [401] = "自定义的 auth_handler 不认可 token",
                [403] = "自定义的 login_handler 执行失败",
                [406] = "该用户已经在登陆中",
            }
            local error_str = self.error_map[result] or "未知错误"
            Message:Show(error_str)
        end
    end
end

function LoginController:Connect()
	-- print('Cat:LoginController.lua[Connect] self.login_state : ', self.login_state)
	if self.login_state == LoginConst.Status.WaitForGameServerConnect then
		--刚连接上游戏服务器时需要进行一次握手校验
		local handshake = string.format("%s@%s#%s:%d", crypt.base64encode(self.token.user), crypt.base64encode(self.token.server),crypt.base64encode(self.subid) , 1)
		local hmac = crypt.hmac64(crypt.hashkey(handshake), self.secret)
		local handshake_str = handshake .. ":" .. crypt.base64encode(hmac)
		-- print('Cat:LoginController.lua[132] handshake_str', handshake_str)
        NetMgr:SendBytes(handshake_str)
        --接下来的处理就在OnReceiveMsg函数里
        self.login_state = LoginConst.Status.WaitForGameServerHandshake
	end
    if self.reconnectView then
        UIMgr:Close(self.reconnectView)
        self.reconnectView = nil
    end
end

function LoginController:StartConnectGameServer(  )
    NetMgr:SendConnect(self.login_info.game_server_ip, self.login_info.game_server_port, CS.XLuaFramework.NetPackageType.BaseHead)
    self.login_state = LoginConst.Status.WaitForGameServerConnect
end

function LoginController:OnReceiveMsg( bytes )
    local code = tostring(bytes)
    local result = string.sub(code, 1, 3)
    if tonumber(result) == 200 then
        --接收完一次就把网络控制权交给NetDispatcher了,开始使用sproto协议 
        NetDispatcher:Start()

        GlobalEventSystem:Fire(LoginConst.Event.LoginSucceed)
        CS.XLuaManager.Instance:OnLoginOk()

        Time:StartSynchServerTime()
    else
        Message:Show("与游戏服务器握手失败:"..result)
    end
end

function LoginController:Disconnect()
	print('Cat:LoginController.lua[Disconnect]', self.login_state)
    if not self.login_info.had_disconnect_with_account_server and (self.login_state == LoginConst.Status.WaitForGameServerConnect or self.login_state == LoginConst.Status.WaitForGameServerHandshake) then
        --每次登录流程中，进入游戏服务器时都会从帐号服务器断开，所以首次断开时可忽略，不需要弹断网的窗口
        self.login_info.had_disconnect_with_account_server = true
        return
    end
    if self.login_state == LoginConst.Status.WaitForLoginServerChanllenge then
        Message:Show("连接登录服务器失败")
    end
    if self.reconnectView then return end
    local showData = {
        content = "网络已断开连接",
        ok_btn_text = "重连",
        on_ok = function()
            --Cat_Todo : 判断帐号服务器是否也断了，是的话也是要先连帐号服务器的
            self:StartLogin(self.login_info)
        end,
        cancel_btn_text = "重新登录",
        on_cancel = function()
            if self.loginView then
                UIMgr:Close(self.reconnectView)
                self.reconnectView = nil
            else
                self.loginView = require("Game/Login/LoginView").New()
                self.loginView:Load()
            end
        end,
    }
end

return LoginController