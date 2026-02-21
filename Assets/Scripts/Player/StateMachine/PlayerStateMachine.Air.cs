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
                if (Velocity.y <= 0.1f && IsGrounded)
                {
                    if (Mathf.Abs(Velocity.x) > 0.0f)
                    {
                        ChangeState(StateMachine.GroundWalk);
                        return;
                    }

                    ChangeState(StateMachine.GroundIdle);
                    return;
                }
                
                var dir = Inputs[0].MoveDir.x == 0.0f ? 0.0f : Mathf.Sign(Inputs[0].MoveDir.x);
                var targetVelX = dir * Stats.maxAirSpeed;
                
                var accel = (Mathf.Sign(dir) != Mathf.Sign(Velocity.x)) ? Stats.airDeceleration : Stats.airAcceleration;
                var velX = Mathf.MoveTowards(Velocity.x, targetVelX, accel * Time.fixedDeltaTime);
                
                Velocity = new Vector2(velX, Velocity.y);
             
                base.FixedUpdate();
            }
        }

        public class AirFallState : AirState
        {
            public AirFallState(PlayerStateMachine stateMachine) : base(stateMachine)
            {
            }

            protected override string StateAnim => "Jump";

            public bool InCoyoteTime => LastState is GroundState && TimeSinceEntered < Stats.coyoteTime;
        
            public override void FixedUpdate()
            {
                if (InCoyoteTime && Inputs[0].Jump)
                {
                    ChangeState(StateMachine.AirJump);
                    return;
                }

                base.FixedUpdate();

                Velocity = new Vector2(Velocity.x, Velocity.y - Stats.fallGravity * Time.fixedDeltaTime);
            }
        }

        public class AirJumpState : AirState
        {
            public AirJumpState(PlayerStateMachine stateMachine) : base(stateMachine)
            {
            }
            
            protected override string StateAnim => "Jump";

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

                if (!Inputs[0].Jump && Velocity.y > MinJumpVelocity)
                {
                    Velocity = new Vector2(Velocity.x, MinJumpVelocity);
                }
                else
                {
                    Velocity = new Vector2(Velocity.x, Velocity.y - Gravity * Time.fixedDeltaTime);
                }
            }
        }
    }
}
