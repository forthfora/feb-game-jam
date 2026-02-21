using UnityEngine;
using UnityEngine.InputSystem;

namespace GameJamProject
{
    public class Player : MonoBehaviour
    {
        public PlayerStats stats;
        
        public CollisionTrigger groundTrigger;
        public CollisionTrigger safeTriggerL;
        public CollisionTrigger safeTriggerR;
        
        public Flashlight flashlight;
        public float groundPosInterval;
        
        public Animator Animator { get; set; }
        public Rigidbody2D Rigidbody { get; set; }
        public PlayerInputFrame[] Inputs { get; } = new PlayerInputFrame[20]; // # of frames
        public bool IsInputActive { get; set; }

        public bool IsGrounded => groundTrigger.IsTriggered;
        public bool IsOnSafeGround => safeTriggerL.IsTriggered && safeTriggerR.IsTriggered
                                                               && safeTriggerL.LastColliderLayer != LayerMask.NameToLayer("Past")
                                                               && safeTriggerR.LastColliderLayer != LayerMask.NameToLayer("Past");

        private PlayerInput _playerInput;
        private SpriteRenderer _renderer;
        
        private PlayerStateMachine _stateMachine;
        private PlayerInputFrame _currentInput;

        private int _flipDir = 1;
        private Vector2 _lastGroundPos;
        
        private void Start()
        {
            Rigidbody = GetComponent<Rigidbody2D>();
            Animator = GetComponent<Animator>();
            
            _playerInput = GetComponent<PlayerInput>();
            _renderer = GetComponent<SpriteRenderer>();
            
            _stateMachine = new(this);
            _lastGroundPos = Rigidbody.position;
        }

        private void Update()
        {
            _stateMachine.Update();

            _currentInput.MoveDir = _playerInput.actions["Move"].ReadValue<Vector2>();
            _currentInput.Jump = _playerInput.actions["Jump"].IsPressed();
            _currentInput.Flashlight = _playerInput.actions["Flashlight"].IsPressed();

            if (IsInputActive)
            {
                flashlight.RotateToMouse();
            }

            if (flashlight.IsActive)
            {
                _flipDir = flashlight.PointDir.x > 0.0f ? 1 : -1;
            }
            else
            {
                _flipDir = Rigidbody.linearVelocity.x > 0.0f ? 1 : (Rigidbody.linearVelocity.x < 0.0f ? -1 : _flipDir);
            }
            
            _renderer.flipX = _flipDir == -1;
        }

        private void FixedUpdate()
        {
            _stateMachine.FixedUpdate();
            
            Inputs.ShiftRight();

            if (IsInputActive)
            {
                Inputs[0] = _currentInput;
            }
            else
            {
                Inputs[0] = new PlayerInputFrame();
                
            }
            
            if (Inputs[0].Flashlight && !Inputs[1].Flashlight)
            {
                flashlight.Toggle();
            }
            
            // record ground position every x frames
            if (IsOnSafeGround && Main.Instance.FixedFrameCount % groundPosInterval == 0)
            {
                _lastGroundPos = Rigidbody.position;
            }
        }
        
        public void ReturnToLastGround()
        {
            Rigidbody.position = _lastGroundPos;
        }
        
        private void OnGUI()
        {
            if (!Application.isEditor)
            {
                return;
            }
            
            var i = 0;
            AddDebugLabel(ref i, $"Position: {transform.position}");
            AddDebugLabel(ref i, $"Velocity: {Rigidbody.linearVelocity:F2}");
            AddDebugLabel(ref i, $"State: {_stateMachine?.CurrentState.GetType().Name}");
            AddDebugLabel(ref i, $"GroundPos: {_lastGroundPos}");
        }

        private void AddDebugLabel(ref int index, string text)
        {
            GUI.Label(new Rect(10, 10 + index++ * 20, 300, 20), text);
        }
    }
}