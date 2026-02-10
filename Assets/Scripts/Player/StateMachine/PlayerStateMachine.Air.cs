using UnityEngine;

namespace GameJamProject
{
    public partial class PlayerStateMachine
    {
        public abstract class AirState : PlayerState
        {
            protected AirState(PlayerStateMachine stateMachine) : base(stateMachine)
            {
            }

            public override void FixedUpdate()
            {
                base.FixedUpdate();

                if (this != StateMachine.AirJump && IsGrounded)
                {
                    if (Velocity.x > 0.0f)
                    {
                        ChangeState(StateMachine.GroundWalk);
                    }
                    else
                    {
                        ChangeState(StateMachine.GroundIdle);
                    }
                }
            }
        }

        public class AirFallState : AirState
        {
            public AirFallState(PlayerStateMachine stateMachine) : base(stateMachine)
            {
            }

            public bool InCoyoteTime => LastState is GroundState && TimeSinceEntered < Stats.coyoteTime;
        
            public override void FixedUpdate()
            {
                base.FixedUpdate();

                if (InCoyoteTime && Inputs[0].Jump)
                {
                    ChangeState(StateMachine.AirJump);
                }
                else
                {
                    Velocity = new Vector2(Velocity.x, Velocity.y - Stats.fallGravity * Time.fixedDeltaTime);
                }
            }
        }

        public class AirJumpState : AirState
        {
            public AirJumpState(PlayerStateMachine stateMachine) : base(stateMachine)
            {
            }

            private float Gravity => 2.0f * Stats.maxJumpHeight / Mathf.Pow(Stats.timeToMaxJumpHeight, 2.0f);
            private float MaxJumpVelocity => Mathf.Abs(Gravity) * Stats.timeToMaxJumpHeight;
            private float MinJumpVelocity => Mathf.Sqrt(2.0f * Mathf.Abs(Gravity) * Stats.minJumpHeight);

            public override void Enter(State lastState)
            {
                base.Enter(lastState);

                Velocity = new Vector2(Velocity.x, MaxJumpVelocity);
            }

            public override void FixedUpdate()
            {
                base.FixedUpdate();

                // Velocity += Vector2.up * (Gravity * Stats.fallGravity * Time.fixedDeltaTime);
                //
                // if (!Inputs[0].Jump && Velocity.y > MinJumpVelocity)
                // {
                //     Velocity = new Vector2(Velocity.x, MinJumpVelocity);
                // }
            }
        }
    }
}
