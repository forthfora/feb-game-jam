using UnityEngine;

namespace GameJamProject
{
    public class CollisionTrigger : MonoBehaviour
    {
        public LayerMask layerMask;
        
        public bool IsTriggered { get; private set; }
        
        private void OnCollisionEnter2D(Collision2D collision)
        {
            if ((layerMask.value & (1 << collision.transform.gameObject.layer)) <= 0)
            {
                return;
            }

            IsTriggered = true;
        }

        private void OnCollisionExit2D(Collision2D collision)
        {
            if ((layerMask.value & (1 << collision.transform.gameObject.layer)) <= 0)
            {
                return;
            }
            
            IsTriggered = false;
        }
    }
}