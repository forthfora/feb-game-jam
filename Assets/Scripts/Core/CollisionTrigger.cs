using UnityEngine;

namespace GameJamProject
{
    public class CollisionTrigger : MonoBehaviour
    {
        public LayerMask layerMask;
        public bool IsTriggered => _triggerCount > 0;
        
        private int _triggerCount;

        private void OnCollisionEnter2D(Collision2D collision)
        {
            if ((layerMask.value & (1 << collision.gameObject.layer)) <= 0)
            {
                return;
            }

            _triggerCount++;
        }

        private void OnCollisionExit2D(Collision2D collision)
        {
            if ((layerMask.value & (1 << collision.gameObject.layer)) <= 0)
            {
                return;
            }

            _triggerCount = Mathf.Max(0, _triggerCount - 1);
        }
    }
}