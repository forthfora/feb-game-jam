using UnityEngine;
using UnityEngine.InputSystem;

namespace GameJamProject
{
    public class Player : MonoBehaviour
    {
        public PlayerStats stats;
        public CollisionTrigger groundTrigger;
        public Flashlight flashlight;
        
        public Animator Animator { get; set; }
        public Rigidbody2D Rigidbody { get; set; }
        public PlayerInputFrame[] Inputs { get; } = new PlayerInputFrame[20]; // # of frames

        private PlayerInput _playerInput;
        private SpriteRenderer _renderer;
        
        private PlayerStateMachine _stateMachine;
        private PlayerInputFrame _currentInput;

        private int _flipDir = 1;
        
        private void Start()
        {
            Rigidbody = GetComponent<Rigidbody2D>();
            Animator = GetComponent<Animator>();
            
            _playerInput = GetComponent<PlayerInput>();
            _renderer = GetComponent<SpriteRenderer>();
            
            _stateMachine = new(this);
        }

        private void Update()
        {
            _stateMachine.Update();

            _currentInput.MoveDir = _playerInput.actions["Move"].ReadValue<Vector2>();
            _currentInput.Jump = _playerInput.actions["Jump"].IsPressed();
            _currentInput.Flashlight = _playerInput.actions["Flashlight"].IsPressed();

            _flipDir = Rigidbody.linearVelocity.x > 0.0f ? 1 : (Rigidbody.linearVelocity.x < 0.0f ? -1 : _flipDir);
            _renderer.flipX = _flipDir == -1;
        }

        private void FixedUpdate()
        {
            _stateMachine.FixedUpdate();
            
            Inputs.ShiftRight();
            Inputs[0] = _currentInput;

            if (Inputs[0].Flashlight && !Inputs[1].Flashlight)
            {
                flashlight.Toggle();
            }
        }


        private void OnGUI()
        {
            var i = 0;
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