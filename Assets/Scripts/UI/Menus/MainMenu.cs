using System;
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
        
        private async void OnStartGameClick()
        {
            try
            {
                await Hide();
            
                Main.Instance.IntroSequence();
            }
            catch (Exception e)
            {
                Debug.LogException(e);
            }
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
