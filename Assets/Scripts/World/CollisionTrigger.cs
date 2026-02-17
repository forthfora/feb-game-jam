using UnityEngine;

namespace GameJamProject
{
    public class CollisionTrigger : MonoBehaviour
    {
        public string colliderTag;
        public bool IsTriggered => _triggerCount > 0;
        
        private int _triggerCount;

        private void OnTriggerEnter2D(Collider2D other)
        {
            if (!other.gameObject.CompareTag(colliderTag))
            {
                return;
            }

            _triggerCount++;
        }

        private void OnTriggerExit2D(Collider2D other)
        {
            if (!other.gameObject.CompareTag(colliderTag))
            {
                return;
            }

            _triggerCount = Mathf.Max(0, _triggerCount - 1);
        }
    }
}