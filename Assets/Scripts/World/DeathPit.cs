namespace GameJamProject
{
    public class DeathPit : CollisionTrigger
    {
        private bool _wasTriggered;
        
        private void Update()
        {
            if (IsTriggered && !_wasTriggered)
            {
                Main.Instance.blackScreen.FadeToBlack(RespawnPlayer);
            }

            _wasTriggered = IsTriggered;
        }

        private void RespawnPlayer()
        {
            Main.Instance.player.ReturnToLastGround();
        }
    }
}