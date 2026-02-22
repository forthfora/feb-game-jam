using System.Collections;
using GameJamProject;
using TMPro;
using UnityEngine;
using UnityEngine.InputSystem;

public class DialogueBox : MonoBehaviour
{
    
    public TextMeshProUGUI textComponent;
    public float charPerSecond;
    public float cooldown;
    
    private DialogueLines _activeLines;
    private int _lineIndex = 0;
    private bool _inSequence = false;
    private bool _inCooldown = false;
    private bool _finishedTyping = false;
    private Coroutine _typingCoroutine;
    
    
    public void StartSequence(DialogueLines lines)
    {
        Main.Instance.player.IsInputActive = false;
        textComponent.text = "";
        _inSequence = true;
        _activeLines = lines;
        _lineIndex = 0;
        
        gameObject.SetActive(true);
        
        _typingCoroutine = StartCoroutine(TypeLine(_activeLines.lines[_lineIndex]));
    }

    private void Update()
    {
        bool shouldContinue = Mouse.current.leftButton.isPressed || Keyboard.current.spaceKey.isPressed;
        if (!_inSequence || !shouldContinue || _inCooldown)
            return;
        
        
        if (_finishedTyping)
        {
            NextLine();
        }
        else
        {
            _finishedTyping = true;
            StopCoroutine(_typingCoroutine);
            StartCoroutine(StartCooldown());
            textComponent.text = _activeLines.lines[_lineIndex];
        }
    }

    void NextLine()
    {
        if (_lineIndex < _activeLines.lines.Count - 1)
        {
            _lineIndex++;
            textComponent.text = "";
            _typingCoroutine = StartCoroutine(TypeLine(_activeLines.lines[_lineIndex]));
            StartCoroutine(StartCooldown());
        }
        else
        {
            _inSequence = false;
            Main.Instance.player.IsInputActive = true;
            gameObject.SetActive(false);
        }
    }

    IEnumerator StartCooldown()
    {
        _inCooldown = true;
        yield return new WaitForSeconds(cooldown);
        _inCooldown = false;
    }

    IEnumerator TypeLine(string line)
    {
        _finishedTyping = false;
        foreach (char c in line)
        {
            textComponent.text += c;
            yield return new WaitForSeconds(1.0f / charPerSecond);
        }

        _finishedTyping = true;
    }
}
