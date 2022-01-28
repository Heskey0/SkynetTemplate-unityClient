using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;
using System.IO;
using UnityEditor.SceneManagement;
public class EasyEditor : Editor
{
    /// <summary>
    /// ��0.Setup����
    /// </summary>
    [MenuItem("CustomTools/GotoSetup")]
    public static void GotoSetup()
    {
        EditorSceneManager.SaveOpenScenes();
        EditorSceneManager.OpenScene(Application.dataPath + "/Scenes/0.Setup.unity");
    }

    /// <summary>
    /// �������ļ�����ResourceĿ¼��
    /// </summary>
    [MenuItem("CustomTools/ConfigToResources")]
    public static void ConfigToResources()
    {
        /*
         * �ҵ�Ŀ��·�� �� ԭ·��
         * ���Ŀ��·��
         * ��ԭ·���ڵ������ļ� ���Ƶ�Ŀ��·�� ��������չ��
         * ǿ��ˢ��
         */
         


        var srcPath = Application.dataPath + "/../Config";
        var dstPath = Application.dataPath + "/Resources/Config";

        //���Ŀ��·��
        Directory.Delete(dstPath,true);
        Directory.CreateDirectory(dstPath);

        foreach (var filePath in Directory.GetFiles(srcPath + "/"))
        {
            var fileName = filePath.Substring(filePath.LastIndexOf('/') + 1);
            File.Copy(filePath, dstPath + "/" + fileName + ".bytes",true);
        }

        AssetDatabase.Refresh();
        Debug.Log("aaa");
    }
}