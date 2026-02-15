using UnityEditor;
using UnityEditor.SceneManagement;
using UnityEngine;
using UnityEngine.SceneManagement;

#if UNITY_EDITOR
[InitializeOnLoad]
public static class AutoLoadMainScene // all this script does is ensure Main is added to every other level scene
{
    public static string MainScenePath => "Assets/Scenes/Main.unity";
    
    static AutoLoadMainScene()
    {
        EditorSceneManager.sceneOpened += OnSceneOpened;
    }

    private static void OnSceneOpened(Scene scene, OpenSceneMode mode)
    {
        if (scene.path == MainScenePath)
        {
            return;
        }

        if (SceneManager.GetSceneByPath(MainScenePath).isLoaded)
        {
            return;
        }

        EditorSceneManager.OpenScene(MainScenePath, OpenSceneMode.Additive);
    }
}
#endif