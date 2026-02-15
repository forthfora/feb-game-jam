using System.Collections.Generic;
using UnityEngine;

namespace GameJamProject
{
    /// <summary>
    /// Represents the base for a hierarchical finite state machine.
    /// </summary>
    public abstract class StateMachine
    {
        private List<State> States { get; } = new();
        public State CurrentState { get; protected set; } = null!;

        public void Update()
        {
            foreach (var state in States)
            {
                state.UpdateTimers(Time.deltaTime);
            }
        
            CurrentState.Update();
        }

        public void FixedUpdate()
        {
            CurrentState.FixedUpdate();
        }

        private void ChangeState(State state)
        {
            CurrentState.Exit(state);
            var lastState = CurrentState;
            CurrentState = state;
            CurrentState.Enter(lastState);
        }

        public abstract class State
        {
            private StateMachine StateMachine { get; }
        
            /// <summary>
            /// Represents the order in which this state was added to the state machine.
            /// </summary>
            public int Index { get; }
        
            protected State LastState { get; private set; }

            protected float TimeSinceEntered { get; private set; }
            protected float TimeSinceExited { get; private set; }

            public State(StateMachine stateMachine)
            {
                StateMachine = stateMachine;
                Index = StateMachine.States.Count;
                StateMachine.States.Add(this);
            }
        
            public void UpdateTimers(float delta)
            {
                if (this == StateMachine.CurrentState)
                {
                    TimeSinceEntered += delta;
                }
                else
                {
                    TimeSinceExited += delta;
                }
            }
        
            protected void ChangeState(State state)
            {
                StateMachine.ChangeState(state);
            }

            public virtual void Enter(State lastState)
            {
                LastState = lastState;
                TimeSinceEntered = 0.0f;
            }

            public virtual void Exit(State nextState)
            {
                TimeSinceExited = 0.0f;
            }

            public virtual void Update() { }
            public virtual void FixedUpdate() { }
        }
    }
}
