using UnityEngine;
using UnityEngine.UI;

namespace GameJamProject
{
    public class MainMenu : MonoBehaviour
    {
        public bool isVisible = true;
        public float timeToFade;
        public Button startGameButton;
        public Button quitGameButton;

        private bool _acceptInput = true;
        private CanvasGroup _canvasGroup;
        private float _fadeVel;

        private void Start()
        {
            _canvasGroup = GetComponent<CanvasGroup>();
            
            startGameButton.onClick.AddListener(OnStartGameClick);
            quitGameButton.onClick.AddListener(OnQuitGameClick);
        }

        private void Update()
        {
            _canvasGroup.alpha = Mathf.SmoothDamp(_canvasGroup.alpha, isVisible ? 1.0f : 0.0f, ref _fadeVel, timeToFade);

            startGameButton.enabled = _acceptInput;
            startGameButton.enabled = _acceptInput;
        }

        public void Show()
        {
            isVisible = true;
            _acceptInput = true;
        }

        public void Hide()
        {
            isVisible = false;
            _acceptInput = false;
        }

        public void HideNow()
        {
            Hide();
            
            _canvasGroup.alpha = 0.0f;
        }

        private void OnStartGameClick()
        {
            Hide();
            Main.Instance.IntroSequence();
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
