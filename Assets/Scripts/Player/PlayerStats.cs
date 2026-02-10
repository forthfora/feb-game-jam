using UnityEngine;

namespace GameJamProject
{
    [CreateAssetMenu(fileName = "Data", menuName = "ScriptableObjects/PlayerStats", order = 1)]
    public class PlayerStats : ScriptableObject
    {
        [Header("Ground")]
        public float walkSpeed;
        
        [Header("Air")]
        public float fallGravity;
        public float coyoteTime;

        public float maxJumpHeight;
        public float minJumpHeight;
        public float timeToMaxJumpHeight;
    }
}