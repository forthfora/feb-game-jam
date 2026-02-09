using UnityEngine;
using UnityEngine.InputSystem;

namespace GameJamProject
{
    public class Player : MonoBehaviour
    {
        private SpriteRenderer Sprite { get; set; }
        private PlayerStateMachine StateMachine { get; set; }

        public Player()
        {
            StateMachine = new(this);
        }
    
        private void Start()
        {
            Sprite = GetComponent<SpriteRenderer>();
        }

        public void OnMove(InputValue value)
        {
            Debug.Log(value.Get<Vector2>());
        }

        public void OnJump()
        {
            Debug.Log("Jump");
        }
    }
}
