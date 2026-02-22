using System;
using System.Collections;
using JetBrains.Annotations;
using UnityEngine;

namespace GameJamProject
{
    public class BlackScreen : MonoBehaviour
    {
        public float duration = 1f;
        public AnimationCurve easeCurve = AnimationCurve.EaseInOut(0, 0, 1, 1);

        private static readonly int Progress = Shader.PropertyToID("_CircularFadeProgress");

        private void Awake()
        {
            SetClear();
        }
        
        public void SetBlack()
        {
            Shader.SetGlobalFloat(Progress, 1.0f);
        }
        
        public void SetClear()
        {
            Shader.SetGlobalFloat(Progress, 0.0f);
        }


        public void FadeFromBlack([CanBeNull] Action callback = null)
        {
            StartCoroutine(TweenBlack(1.0f, 0.0f, callback));
        }

        public void FadeToBlack([CanBeNull] Action callback = null)
        {
            StartCoroutine(TweenBlack(0.0f, 1.0f, callback));
        }
        
        private IEnumerator TweenBlack(float from, float to, [CanBeNull] Action callback = null)
        {
            Shader.SetGlobalFloat(Progress, from);

            var startTime = Time.time;
            var endTime = startTime + duration;

            while (Time.time < endTime)
            {
                var t = Mathf.InverseLerp(startTime, endTime, Time.time);
                var curved = easeCurve.Evaluate(t);
                
                Shader.SetGlobalFloat(Progress, Mathf.Lerp(from, to, curved));

                yield return null;
            }

            Shader.SetGlobalFloat(Progress, to);
            callback?.Invoke();
        }
    }
}