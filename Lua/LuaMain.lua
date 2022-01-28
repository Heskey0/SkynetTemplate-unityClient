require "Game.Common.UIManager"
PrefabPool = require "Game.Common.PrefabPool"
require "Common.UI.UIComponent"
require "Common.UI.Countdown"
require("Common.UI.ItemListCreator")
require("Game.Common.Message")

--管理器--
local Game = {}
local Ctrls = {}

function LuaMain()
    print("logic start")     
    UpdateManager:GetInstance():Startup()
    Game:OnInitOK()
end

function ExitGame()
    print('Cat:LuaMain.lua[ExitGame]')
    local util = require 'Tools.print_delegate'
    util.print_func_ref_by_csharp()
end

--初始化完成
function Game:OnInitOK()
    print('Cat:Game.lua[Game.OnInitOK()]')
    GlobalEventSystem.Init()
    Game:InitUI()
    Game:InitControllers()
	Message:Init()
end

function Game.InitUI()
    UIMgr:Init({"UICanvas/Bottom","UICanvas/Normal", "UICanvas/Top"}, "Normal")
    
    local pre_load_prefab = {
		--[[
				TODO:在此处添加UI路径
		--]]
		
		--[[
        "Assets/AssetBundleRes/ui/common/Background.prefab",
        "Assets/AssetBundleRes/ui/common/GoodsItem.prefab",
        "Assets/AssetBundleRes/ui/common/WindowBig.prefab",
        "Assets/AssetBundleRes/ui/common/WindowNoTab.prefab",
        "Assets/AssetBundleRes/ui/common/EmptyContainer.prefab",
        "Assets/AssetBundleRes/ui/common/Button1.prefab",
        "Assets/AssetBundleRes/ui/common/Button2.prefab",
        "Assets/AssetBundleRes/ui/common/Button3.prefab",
		--]]
    }
    PrefabPool:Register(pre_load_prefab)
end

function Game:InitControllers()
    local ctrl_paths = {
		--[[
				TODO:在此处添加UIController路径
		--]]
		
		"Game/Login/LoginController",
		
        --[[
		"Game/Test/TestController",
        "Game/Login/LoginController", 
        "Game/MainUI/MainUIController", 
        "Game/Task/TaskController", 
        "Game/Scene/SceneController", 
        "Game/Bag/BagController", 
        "Game/GM/GMController", 
        "Game/Chat/ChatController", 
		--]]
    }
    for i,v in ipairs(ctrl_paths) do
        local ctrl = require(v)
        if type(ctrl) ~= "boolean" then
            --调用每个Controller的Init函数
            ctrl:Init()
            table.insert(Ctrls, ctrl)
        else
            --Controller类忘记了在最后return
            assert(false, 'Cat:Main.lua error : you must forgot write a return in you controller file :'..v)
        end
    end
	--print("*************")
end


--销毁--
function Game:OnDestroy()

end
