
using UnityEngine;

namespace GameJamProject
{
    public partial class PlayerStateMachine : StateMachine
    {
        public Player Player { get; }

        private GroundIdleState GroundIdle { get; }
        private GroundWalkState GroundWalk { get; }

        private AirJumpState AirJump { get; }
        private AirFallState AirFall { get; }

        public PlayerStateMachine(Player player)
        {
            Player = player;
        
            GroundIdle = new GroundIdleState(this);
            GroundWalk = new GroundWalkState(this);
        
            AirJump = new AirJumpState(this);
            AirFall = new AirFallState(this);

            CurrentState = GroundIdle;
            CurrentState.Enter(GroundIdle);
        }

        public abstract class PlayerState : State
        {
            protected PlayerStateMachine StateMachine { get; }
            
            protected Player Player => StateMachine.Player;
            protected PlayerStats Stats => Player.stats;
            protected PlayerInputFrame[] Inputs => Player.Inputs;

            protected abstract string StateAnim { get; }

            protected Vector2 Velocity
            {
                get => Player.Rigidbody.linearVelocity;
                set => Player.Rigidbody.linearVelocity = value;
            }

            protected bool IsGrounded => Player.IsGrounded;
            
            protected PlayerState(PlayerStateMachine stateMachine) : base(stateMachine)
            {
                StateMachine = stateMachine;
            }

            public override void Enter(State lastState)
            {
                base.Enter(lastState);

                Player.Animator.Play(StateAnim);
            }
        }
    }
}
