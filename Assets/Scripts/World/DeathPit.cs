namespace GameJamProject
{
    public class DeathPit : CollisionTrigger
    {
        private bool _wasTriggered;
        
        private void Update()
        {
            if (IsTriggered && !_wasTriggered)
            {
                Main.Instance.flashlight.IsActive = false;
                Main.Instance.blackScreen.FadeToBlack(RespawnPlayer);
            }

            _wasTriggered = IsTriggered;
        }

        private void RespawnPlayer()
        {
            Main.Instance.player.ReturnToLastGround();
            Main.Instance.SnapCameraToPlayer();
            Main.Instance.blackScreen.FadeFromBlack();
        }
    }
}