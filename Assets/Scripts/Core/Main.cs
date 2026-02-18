using System;
using System.Collections;
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
        public CinemachineCamera vCam;
        public BlackScreen blackScreen;
        public string defaultScene;

        public int FixedFrameCount { get; private set; }
        
        public event Action SceneChange;
        
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

        private void FixedUpdate()
        {
            FixedFrameCount++;
        }

        private void SceneManagerOnSceneLoaded(Scene scene, LoadSceneMode mode)
        {
            StartCoroutine(SceneFullyLoaded(scene));
        }
        
        private IEnumerator SceneFullyLoaded(Scene scene)
        {
            yield return null; // Wait one frame for everything to initialize
            
            if (scene.name == "Main")
            {
                yield break;
            }
            
            var bounds = GameObject.FindGameObjectsWithTag("CameraBounds").FirstOrDefault();

            if (bounds is null)
            {
                throw new Exception($"No camera bounds on level: {scene.name}");
            }

            if (!bounds.TryGetComponent<Collider2D>(out var boundsCollider))
            {
                throw new Exception("No collider found on camera bounds");
            }

            var confiner = vCam.GetComponent<CinemachineConfiner2D>();

            confiner.BoundingShape2D = boundsCollider;
            confiner.InvalidateBoundingShapeCache();
            
            SceneChange?.Invoke();
        }

        public void SnapCameraToPlayer()
        {
            vCam.PreviousStateIsValid = false;
            vCam.gameObject.SetActive(false);
            vCam.gameObject.SetActive(true);
        }
    }
}
