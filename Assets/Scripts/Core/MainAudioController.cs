using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MainAudioController : MonoBehaviour
{
    [Range(0,1)]
    public float volume;
    public float fadeTime;
    public List<AudioClip> environmentSounds;
    
    private AudioSource _audioSource;
    private int _currentPlaying = 0;

    private void Start()
    {
        _audioSource = GetComponent<AudioSource>();
        _audioSource.volume = volume;
    }

    public void PlaySound(int index)
    {
        _currentPlaying = index;
        StartCoroutine(FadeOutInTo(environmentSounds[_currentPlaying]));
    }

    public void PlayNext()
    {
        _currentPlaying += 1;
        StartCoroutine(FadeOutInTo(environmentSounds[_currentPlaying]));
    }

    IEnumerator FadeOutInTo(AudioClip target)
    {   
        // Fade Out
        float timeElapsed = 0;
        while (timeElapsed < fadeTime)
        {
            timeElapsed += Time.deltaTime;
            float t = timeElapsed / fadeTime;
            _audioSource.volume = Mathf.Lerp(volume, 0, t);
            yield return null;
        }

        _audioSource.clip = target;
        _audioSource.Play();
        
        // Fade in
        timeElapsed = 0;
        while (timeElapsed < fadeTime)
        {
            timeElapsed += Time.deltaTime;
            float t = timeElapsed / fadeTime;
            _audioSource.volume = Mathf.Lerp(0, volume, t);
            yield return null;
        }
    }
}
