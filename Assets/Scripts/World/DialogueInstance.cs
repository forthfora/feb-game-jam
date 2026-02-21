using System;
using GameJamProject;
using UnityEngine;

public class DialogueInstance : MonoBehaviour
{
    public DialogueLines Lines;
    private bool _hasTriggered = false;

    private void OnTriggerEnter2D(Collider2D other)
    {
        if(_hasTriggered) return;
        
        _hasTriggered = true;
        Main.Instance.dialogueBox.StartSequence(Lines);
    }
}
