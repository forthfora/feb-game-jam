using System;
using UnityEngine;

namespace GameJamProject
{
    public class DeathPit : CollisionTrigger
    {
        private bool _wasTriggered;
        
        private void Update()
        {
            if (IsTriggered && !_wasTriggered)
            {
                Main.Instance.blackScreen.FadeOut();
            }

            _wasTriggered = IsTriggered;
        }
    }
}