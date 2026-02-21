using System;
using System.Threading.Tasks;
using UnityEngine;
using UnityEngine.UI;

namespace GameJamProject
{
    public class DemoEnd : Menu
    {
        public Button returnToMainMenuButton;

        public override void Start()
        {
            base.Start();
            
            returnToMainMenuButton.onClick.AddListener(OnReturnToMainMenuClick);
        }

        public override void Update()
        {
            base.Update();
            
            returnToMainMenuButton.enabled = AcceptInput;
        }

        private async void OnReturnToMainMenuClick()
        {
            try
            {
                await Hide();
            
                Main.Instance.ReturnToMainMenu();
            }
            catch (Exception e)
            {
                Debug.LogException(e);
            }
        }
    }
}