using UnityEngine;
using UnityEngine.SceneManagement;

namespace GameJamProject
{
    public class Main : MonoBehaviour
    {
        public Player player;
        public Camera mainCamera;
        public string defaultScene;
    
        public static Main Instance { get; set; }
        
        [RuntimeInitializeOnLoadMethod(RuntimeInitializeLoadType.SubsystemRegistration)]
        public static void Init()
        {
            Instance = null;
        }
        
        private void Awake()
        {
            if (Instance is not null)
            {
                Destroy(this);
                return;
            }
        
            Instance = this;
            DontDestroyOnLoad(this);
        }
        
        private void Start()
        {
            SceneManager.LoadScene(defaultScene);
        }
    }
}
