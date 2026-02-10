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

            public override void FixedUpdate()
            {
                base.FixedUpdate();

                if (!IsGrounded)
                {
                    ChangeState(StateMachine.AirFall);
                }
                else if (Inputs[0].Jump)
                {
                    ChangeState(StateMachine.AirJump);
                }
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
                base.FixedUpdate();
                
                if (Inputs[0].MoveDir.x != 0.0f)
                {
                    ChangeState(StateMachine.GroundWalk);
                }
            }
        }

        public class GroundWalkState : GroundState
        {
            public GroundWalkState(PlayerStateMachine stateMachine) : base(stateMachine)
            {
            }

            public override void FixedUpdate()
            {
                base.FixedUpdate();
                
                if (Mathf.Abs(Inputs[0].MoveDir.x) == 0.0f)
                {
                    ChangeState(StateMachine.GroundIdle);
                }
                else
                {
                    var dir = Mathf.Sign(Inputs[0].MoveDir.x);
                    Velocity = new Vector2(Stats.walkSpeed * dir, 0.0f);
                }
            }
        }
    }
}
