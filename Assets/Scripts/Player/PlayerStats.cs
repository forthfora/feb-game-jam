using UnityEngine;

namespace GameJamProject
{
    [CreateAssetMenu(fileName = "Data", menuName = "ScriptableObjects/PlayerStats", order = 1)]
    public class PlayerStats : ScriptableObject
    {
        [Header("Ground")]
        public float maxGroundSpeed;
        public float groundAcceleration;
        public float groundDeceleration;
        
        [Space]
        
        [Header("Air")]
        public float fallGravity;
        public float coyoteTime;

        [Space]
        
        public float maxJumpHeight;
        public float minJumpHeight;
        public float timeToMaxJumpHeight;
        
        [Space]
        
        public float maxAirSpeed;
        public float airAcceleration;
        public float airDeceleration;
    }
}