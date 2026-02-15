using UnityEngine;

namespace GameJamProject
{
    public class CollisionTrigger : MonoBehaviour
    {
        public string colliderTag;
        public bool IsTriggered => _triggerCount > 0;
        
        private int _triggerCount;

        private void OnCollisionEnter2D(Collision2D collision)
        {
            if (!collision.gameObject.CompareTag(colliderTag))
            {
                return;
            }

            _triggerCount++;
        }

        private void OnCollisionExit2D(Collision2D collision)
        {
            if (!collision.gameObject.CompareTag(colliderTag))
            {
                return;
            }

            _triggerCount = Mathf.Max(0, _triggerCount - 1);
        }
    }
}