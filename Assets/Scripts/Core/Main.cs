using System;
using System.Collections;
using System.Linq;
using Unity.Cinemachine;
using UnityEngine;
using UnityEngine.InputSystem;
using UnityEngine.SceneManagement;

namespace GameJamProject
{
    public class Main : MonoBehaviour
    {
        public static Main Instance { get; set; }
        
        public Player player;
        public MainAudioController audioController;
        public DialogueBox dialogueBox;
        
        [Header("Cameras")]
        public Camera mainCamera;
        public CinemachineCamera vCam;
        
        [Header("Menus")]
        public BlackScreen blackScreen;
        public MainMenu mainMenu;
        public DemoEnd demoEnd;
        
        [Header("Startup")]
        public string defaultScene;
        public bool normalStartup;

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
        
        private IEnumerator Start()
        {
            SceneManager.LoadScene(defaultScene);

            if (normalStartup)
            {
                blackScreen.SetBlack();

                yield return new WaitForSeconds(1.0f);
                
                demoEnd.HideNow();
                
                GoToMainMenu();
                
                blackScreen.FadeFromBlack();
            }
            else
            {
                yield return new WaitForEndOfFrame();
                
                mainMenu.HideNow();
                demoEnd.HideNow();
                
                player.IsInputActive = true;
            }
        }

        private void Update()
        {
            // TODO: just for debug maybe add a pause menu 
            if (Application.isEditor && Keyboard.current.escapeKey.wasPressedThisFrame && !mainMenu.isVisible)
            {
                GoToMainMenu();
            }
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
        
        private void GoToMainMenu()
        {
            mainMenu.Show();
            
            player.IsInputActive = false;
            player.transform.position = new Vector3(0.0f, -1.0f, 0.0f);
        }

        public void ReturnToMainMenu()
        {
            blackScreen.FadeToBlack(() =>
            {
                SceneManager.LoadScene("Level1");
                
                GoToMainMenu();
                
                blackScreen.SetBlack();
                blackScreen.FadeFromBlack();
            });
        }

        public void IntroSequence()
        {
            // TODO
            player.IsInputActive = true;
            audioController.PlaySound(1);
        }
    }
}
