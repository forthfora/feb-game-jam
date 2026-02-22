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
                StartCoroutine(TransitionLevel());
            }

            _wasTriggered = IsTriggered;
        }

        private IEnumerator TransitionLevel()
        {
            var player = Main.Instance.player;
            var moveDir = direction == Direction.Left ? Vector2.left : Vector2.right;
            
            player.IsInputActive = false;
         
            var endTime = Time.time + timeToFade;

            Main.Instance.blackScreen.FadeToBlack();
            
            while (Time.time < endTime)
            {
                player.Inputs[0].MoveDir = moveDir;
                yield return null; 
            }
            
            SceneManager.LoadScene(nextLevel);

            player.transform.position = nextLevelPos;
            Main.Instance.blackScreen.FadeFromBlack();
            
            endTime = Time.time + timeToFade;
            
            while (Time.time < endTime)
            {
                player.Inputs[0].MoveDir = moveDir;
                yield return null; 
            }

            player.IsInputActive = true;
        }
    }
}