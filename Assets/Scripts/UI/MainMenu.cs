using UnityEngine;
using UnityEngine.UI;

namespace GameJamProject
{
    public class MainMenu : MonoBehaviour
    {
        public Button startGameButton;
        public Button quitGameButton;
        public float fadeLerp;

        public bool IsVisible { get; set; } = true;

        private bool _acceptInput = true;
        private CanvasGroup _canvasGroup;

        private void Start()
        {
            _canvasGroup = GetComponent<CanvasGroup>();
            
            startGameButton.onClick.AddListener(OnStartGameClick);
            quitGameButton.onClick.AddListener(OnQuitGameClick);
        }

        private void Update()
        {
            _canvasGroup.alpha = Mathf.MoveTowards(_canvasGroup.alpha, IsVisible ? 1.0f : 0.0f, fadeLerp * Time.deltaTime);

            startGameButton.enabled = _acceptInput;
            startGameButton.enabled = _acceptInput;
        }

        private void OnStartGameClick()
        {
            IsVisible = false;
            _acceptInput = false;
        }
        
        private void OnQuitGameClick()
        {
            _acceptInput = false;
            Main.Instance.blackScreen.FadeToBlack(Quit);
        }

        private void Quit()
        {
            Application.Quit();
        }
    }
}
