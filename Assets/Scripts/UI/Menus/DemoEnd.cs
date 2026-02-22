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

        private void OnReturnToMainMenuClick()
        {
            StartCoroutine(Hide(() =>
            {
                Main.Instance.ReturnToMainMenu();
            }));
        }
    }
}