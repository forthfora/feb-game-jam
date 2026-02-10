using UnityEngine;

namespace GameJamProject
{
    public partial class PlayerStateMachine
    {
        public abstract class GroundState : PlayerState
        {
            protected GroundState(PlayerStateMachine stateMachine) : base(stateMachine)
            {
            }

            public override void Enter(State lastState)
            {
                base.Enter(lastState);

                Velocity = new Vector2(Velocity.x, 0.0f);
            }

            public override void FixedUpdate()
            {
                if (!IsGrounded)
                {
                    ChangeState(StateMachine.AirFall);
                    return;
                }
                
                if (Inputs[0].Jump)
                {
                    ChangeState(StateMachine.AirJump);
                    return;
                }
                
                base.FixedUpdate();
            }
        }

        public class GroundIdleState : GroundState
        {
            public GroundIdleState(PlayerStateMachine stateMachine) : base(stateMachine)
            {
            }

            public override void Enter(State lastState)
            {
                base.Enter(lastState);

                Velocity = Vector2.zero;
            }

            public override void FixedUpdate()
            {
                if (Inputs[0].MoveDir.x != 0.0f)
                {
                    ChangeState(StateMachine.GroundWalk);
                    return;
                }
                
                base.FixedUpdate();
            }
        }

        public class GroundWalkState : GroundState
        {
            public GroundWalkState(PlayerStateMachine stateMachine) : base(stateMachine)
            {
            }

            public override void FixedUpdate()
            {
                if (Inputs[0].MoveDir.x == 0.0f && Mathf.Abs(Velocity.x) < 0.5f)
                {
                    ChangeState(StateMachine.GroundIdle);
                    return;
                }

                var dir = Inputs[0].MoveDir.x == 0.0f ? 0.0f : Mathf.Sign(Inputs[0].MoveDir.x);
                var targetVelX = dir * Stats.maxGroundSpeed;
                
                var accel = (Mathf.Sign(dir) != Mathf.Sign(Velocity.x)) ? Stats.groundDeceleration : Stats.groundAcceleration;
                var velX = Mathf.MoveTowards(Velocity.x, targetVelX, accel * Time.fixedDeltaTime);
                
                Velocity = new Vector2(velX, Velocity.y);

                base.FixedUpdate();
            }
        }
    }
}
