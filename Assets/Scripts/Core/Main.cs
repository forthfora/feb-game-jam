using System;
using System.Linq;
using Unity.Cinemachine;
using UnityEngine;
using UnityEngine.SceneManagement;

namespace GameJamProject
{
    public class Main : MonoBehaviour
    {
        public static Main Instance { get; set; }
        
        [RuntimeInitializeOnLoadMethod(RuntimeInitializeLoadType.SubsystemRegistration)]
        public static void Init()
        {
            Instance = null;
        }
        
        public Player player;
        public Camera mainCamera;
        public CinemachineCamera cinemachineCamera;
        
        public BlackScreen blackScreen;
        
        public string defaultScene;
        
        private void Awake()
        {
            if (Instance is not null)
            {
                Destroy(this);
                return;
            }
        
            Instance = this;
            DontDestroyOnLoad(this);
            
            SceneManager.sceneLoaded += SceneManagerOnSceneLoaded;
        }
        
        private void Start()
        {
            SceneManager.LoadScene(defaultScene);
        }

        private void SceneManagerOnSceneLoaded(Scene scene, LoadSceneMode mode)
        {
            var bounds = GameObject.FindGameObjectsWithTag("CameraBounds").FirstOrDefault();

            if (bounds is null)
            {
                throw new Exception($"No camera bounds on level: {scene.name}");
            }

            if (!bounds.TryGetComponent<Collider2D>(out var boundsCollider))
            {
                throw new Exception("No collider found on camera bounds");
            }

            var confiner = cinemachineCamera.GetComponent<CinemachineConfiner2D>();

            confiner.BoundingShape2D = boundsCollider;
        }
    }
}
