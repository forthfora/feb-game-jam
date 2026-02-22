using System.Collections;
using UnityEngine;

namespace GameJamProject
{
    public class DemoEndTrigger : CollisionTrigger
    {
        public float timeToFade = 2.0f;
        
        private bool _wasTriggered;
        
        private void Update()
        {
            if (IsTriggered && !_wasTriggered)
            {
                StartCoroutine(GoToDemoScreen());
            }

            _wasTriggered = IsTriggered;
        }

        private IEnumerator GoToDemoScreen()
        {
            Main.Instance.player.IsInputActive = false;
            Main.Instance.player.flashlight.IsActive = false;
         
            var endTime = Time.time + timeToFade;

            while (Time.time < endTime)
            {
                Main.Instance.player.Inputs[0].MoveDir = Vector2.right;
                yield return null; 
            }
            
            Main.Instance.demoEnd.Show();
        }
    }
}