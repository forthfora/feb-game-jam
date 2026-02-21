using UnityEngine;
using UnityEngine.UI;

namespace GameJamProject
{
    public class MainMenu : Menu
    {
        public Button startGameButton;
        public Button quitGameButton;

        public override void Start()
        {
            base.Start();

            startGameButton.onClick.AddListener(OnStartGameClick);
            quitGameButton.onClick.AddListener(OnQuitGameClick);
        }

        public override void Update()
        {
            base.Update();
            
            startGameButton.enabled = AcceptInput;
            quitGameButton.enabled = AcceptInput;
        }
        
        private void OnStartGameClick()
        {
            StartCoroutine(Hide(Main.Instance.IntroSequence));
        }
        
        private void OnQuitGameClick()
        {
            AcceptInput = false;
            Main.Instance.blackScreen.FadeToBlack(Quit);
        }

        private void Quit()
        {
            Application.Quit();
        }

    }
}
