local EventSystem = require "Common.EventSystem"
GlobalEventSystem = EventSystem.New()

function GlobalEventSystem.Init(  )
	print('Cat:GlobalEventSystem.lua[Init]')
	--为了性能考虑，一些c#侧的事件在lua侧只监听一次，然后在lua内部转发，减少c#与lua的交互
	local SceneChanged = function ( )
		GlobalEventSystem:Fire(GlobalEvents.SceneChanged)
	end
	CSLuaBridge.GetInstance():SetLuaFunc(GlobalEvents.SceneChanged, SceneChanged)
end