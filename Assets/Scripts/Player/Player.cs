using System;
using UnityEngine;
using UnityEngine.InputSystem;
using UnityEngine.Serialization;

namespace GameJamProject
{
    public class Player : MonoBehaviour
    {
        public PlayerStats stats;
        public CollisionTrigger groundTrigger;
        
        public Rigidbody2D Rigidbody { get; set; }
        public PlayerInputFrame[] Inputs { get; } = new PlayerInputFrame[20]; // # of frames

        private PlayerStateMachine _stateMachine;
        private PlayerInputFrame _currentInput;
        
        private void Start()
        {
            Rigidbody = GetComponent<Rigidbody2D>();
            
            _stateMachine = new(this);
            
            DontDestroyOnLoad(this);
        }

        private void Update()
        {
            _stateMachine.Update();
        }

        private void FixedUpdate()
        {
            _stateMachine.FixedUpdate();
            
            Inputs.ShiftRight();
            Inputs[0] = _currentInput;
        }


        public void OnMove(InputValue value)
        {
            _currentInput.MoveDir = value.Get<Vector2>();
        }

        public void OnJump(InputValue value)
        {
            _currentInput.Jump = value.isPressed;
        }
        
        
        
        void OnGUI()
        {
            var i = 0;
            AddDebugLabel(ref i, $"Player:");
            AddDebugLabel(ref i, $"Position: {transform.position}");
            AddDebugLabel(ref i, $"Velocity: {Rigidbody.linearVelocity:F2}");
            AddDebugLabel(ref i, $"State: {_stateMachine?.CurrentState.GetType().Name}");
        }

        private void AddDebugLabel(ref int index, string text)
        {
            GUI.Label(new Rect(10, 10 + index++ * 20, 300, 20), text);
        }
    }
}