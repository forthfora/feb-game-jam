using System.Collections;
using UnityEngine;
using UnityEngine.SceneManagement;

namespace GameJamProject
{
    public enum Direction
    {
        Left,
        Right,
    }
    
    public class LevelTransitionTrigger : CollisionTrigger
    {
        public string nextLevel;
        public Vector2 nextLevelPos;
        
        [Header("Cosmetic")]
        public Direction direction;
        public float timeToFade = 2.0f;
        
        private bool _wasTriggered;
        
        private void Start()
        {
            colliderTag = "Player";
        }
        
        private void Update()
        {
            if (IsTriggered && !_wasTriggered)
            {
                var moveDir = direction == Direction.Left ? Vector2.left : Vector2.right;
                StartCoroutine(Main.Instance.TransitionLevel(moveDir, timeToFade, nextLevel, nextLevelPos));
            }

            _wasTriggered = IsTriggered;
        }
    }
}