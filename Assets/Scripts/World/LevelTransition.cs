using UnityEngine;
using UnityEngine.SceneManagement;

namespace GameJamProject
{
    public class LevelTransition : CollisionTrigger
    {
        public string nextLevel;
        public Vector2 nextLevelPos;
        public Vector2 nextLevelDir;
            
        private BoxCollider2D _collider2D;

        private void Start()
        {
            colliderTag = "Player";
        }

        private void Update()
        {
            if (IsTriggered)
            {
                Main.Instance.blackScreen.FadeToBlack(TransitionLevel);
            }
        }

        private void TransitionLevel()
        {
            SceneManager.LoadScene(nextLevel);
            Main.Instance.blackScreen.FadeFromBlack();
        }
    }
}