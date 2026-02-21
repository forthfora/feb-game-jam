using System.Collections.Generic;
using UnityEngine;

namespace GameJamProject
{
    [CreateAssetMenu(fileName = "Data", menuName = "ScriptableObjects/DialogueLines", order = 2)]
    public class DialogueLines : ScriptableObject
    {
        public List<string> lines;
    }
}