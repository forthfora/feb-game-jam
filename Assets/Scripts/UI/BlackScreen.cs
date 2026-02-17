    using System;
using System.Threading;
using System.Threading.Tasks;
using JetBrains.Annotations;
using UnityEngine;

namespace GameJamProject
{
    public class BlackScreen : MonoBehaviour
    {
        public float duration = 1f;
        public AnimationCurve easeCurve = AnimationCurve.EaseInOut(0, 0, 1, 1);

        private static readonly int Progress = Shader.PropertyToID("_CircularFadeProgress");
        private CancellationTokenSource _cts;

        private void Awake()
        {
            Shader.SetGlobalFloat(Progress, 0.0f);
        }

        public void FadeFromBlack([CanBeNull] Action callback = null)
        {
            FireAndForget(ct => FadeFromBlackAsync(callback, ct));
        }

        public void FadeToBlack([CanBeNull] Action callback = null)
        {
            FireAndForget(ct => FadeToBlackAsync(callback, ct));
        }

        public async Task FadeFromBlackAsync([CanBeNull] Action callback, CancellationToken ct = default)
        {
            await TweenProgress(1f, 0f, ct, callback);
        }

        public async Task FadeToBlackAsync([CanBeNull] Action callback, CancellationToken ct = default)
        {
            await TweenProgress(0f, 1f, ct, callback);
        }
        
        private async Task TweenProgress(float from, float to, CancellationToken externalCt, [CanBeNull] Action callback)
        {
            _cts?.Cancel();
            _cts = new CancellationTokenSource();

            using var linked = CancellationTokenSource.CreateLinkedTokenSource(_cts.Token, externalCt);
            var token = linked.Token;

            var elapsed = 0f;
            
            Shader.SetGlobalFloat(Progress, from);

            while (elapsed < duration)
            {
                if (token.IsCancellationRequested)
                {
                    return;
                }

                elapsed += Time.deltaTime;
                
                var t = Mathf.Clamp01(elapsed / duration);
                var curved = easeCurve.Evaluate(t);
                
                Shader.SetGlobalFloat(Progress, Mathf.Lerp(from, to, curved));

                await Task.Yield();
            }

            Shader.SetGlobalFloat(Progress, to);
            callback?.Invoke();
        }

        // ReSharper disable Unity.PerformanceAnalysis
        private async void FireAndForget(Func<CancellationToken, Task> fn)
        {
            try
            {
                await fn(destroyCancellationToken);
            }
            catch (Exception e)
            {
                Debug.LogError(e);
            }
        }
    }
}