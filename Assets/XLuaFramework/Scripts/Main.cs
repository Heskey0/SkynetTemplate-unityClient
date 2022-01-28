using UnityEngine;
using System.Collections;
using XLua;


namespace XLuaFramework
{
    //负责整个游戏流程调度,从启动后热更新,渠道sdk接入,各系统的初始化,直到登录才完成使命
    public class Main : MonoBehaviour
    {
        public enum State
        {
            CheckExtractResource, //初次运行游戏时需要解压资源文件
            UpdateResourceFromNet, //热更阶段：从服务器上拿到最新的资源
            InitAssetBundle, //初始化AssetBundle
            StartLogin, //登录流程
            StartGame, //正式进入场景游戏
            Playing, //完成启动流程了，接下来把控制权交给玩法逻辑
            None, //无
        }

        public enum SubState
        {
            Enter,
            Update
        }

        State cur_state = State.None;
        SubState cur_sub_state = SubState.Enter;
        public bool IsNeedPrintConcole = true;

        void Start()
        {
            Debug.Log("Main:Start()");

            AppConfig.Init();

            GameObject.DontDestroyOnLoad(this.gameObject);

            this.gameObject.AddComponent<ThreadManager>(); //for download or extract assets
            this.gameObject.AddComponent<ResourceManager>();
            this.gameObject.AddComponent<NetworkManager>();
            this.gameObject.AddComponent<XLuaManager>();

            JumpToState(State.CheckExtractResource);
        }

        void JumpToState(State new_state)
        {
            cur_state = new_state;
            cur_sub_state = SubState.Enter;
            Debug.Log("new_state : " + new_state.ToString());
        }

        private void Update()
        {
            if (cur_state == State.Playing)
                return;
            switch (cur_state)
            {
                case State.CheckExtractResource:
                    if (cur_sub_state == SubState.Enter)
                    {
                        cur_sub_state = SubState.Update;
                        this.gameObject.AddComponent<AssetsHotFixManager>();
                        AssetsHotFixManager.Instance.CheckExtractResource(percent =>
                        {
                            //Debug.Log( "首次解压游戏数据（不消耗流量）");
                        }, () =>
                        {
                            Debug.Log("Main.cs CheckExtractResource OK!!!");
                            JumpToState(State.UpdateResourceFromNet);
                        });
                    }

                    break;
                case State.UpdateResourceFromNet:
                    if (cur_sub_state == SubState.Enter)
                    {
                        cur_sub_state = SubState.Update;
                        AssetsHotFixManager.Instance.UpdateResource((percent, tip) =>
                        {
                            //Debug.Log( "首次解压游戏数据（不消耗流量）");
                        }, delegate(string result)
                        {
                            if (result == "")
                            {
                                Debug.Log("Main.cs UpdateResourceFromNet OK!!!");
                            }
                            else
                            {
                                Debug.Log(result);
                            }

                            JumpToState(State.InitAssetBundle);
                        });
                    }

                    break;
                case State.InitAssetBundle:
                    if (cur_sub_state == SubState.Enter)
                    {
                        cur_sub_state = SubState.Update;
                        //Debug.Log("初始化游戏资源...");
                        ResourceManager.GetInstance()
                            .Initialize(AppConfig.AssetDir, () => { JumpToState(State.StartLogin); });
                    }

                    break;
                case State.StartLogin:
                    if (cur_sub_state == SubState.Enter)
                    {
                        cur_sub_state = SubState.Update;
                        //Debug.Log("初始化游戏资源完毕");
                        XLuaManager.Instance.InitLuaEnv();
                        XLuaManager.Instance.StartLogin(() =>
                        {
                            Debug.Log("Main.cs XLuaManager StartLogin OK!!!");
                            JumpToState(State.StartGame);
                        });
                    }

                    break;
                case State.StartGame:
                    if (cur_sub_state == SubState.Enter)
                    {
                        cur_sub_state = SubState.Update;
                        JumpToState(State.Playing);
                    }

                    break;
                case State.Playing:
                    break;
            }
        }
    }
}