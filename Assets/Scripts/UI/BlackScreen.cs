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
            SetClear();
        }
        
        public void SetBlack()
        {
            Shader.SetGlobalFloat(Progress, 1.0f);
            _cts?.Cancel();
            _cts?.Dispose();
        }
        
        public void SetClear()
        {
            Shader.SetGlobalFloat(Progress, 0.0f);
            _cts?.Cancel();
            _cts?.Dispose();
        }


        public void FadeFromBlack([CanBeNull] Action callback = null)
        {
            FireAndForget(ct => TweenProgress(1f, 0f, ct), callback);
        }

        public void FadeToBlack([CanBeNull] Action callback = null)
        {
            FireAndForget(ct => TweenProgress(0f, 1f, ct), callback);
        }
        
        private async Task TweenProgress(float from, float to, CancellationToken externalCt)
        {
            _cts?.Cancel();
            _cts?.Dispose();
            _cts = new CancellationTokenSource();

            using var linked = CancellationTokenSource.CreateLinkedTokenSource(_cts.Token, externalCt);
            var token = linked.Token;

            Shader.SetGlobalFloat(Progress, from);

            var elapsed = 0f;

            while (elapsed < duration)
            {
                token.ThrowIfCancellationRequested();

                elapsed += Time.deltaTime;
                
                var t = Mathf.Clamp01(elapsed / duration);
                var curved = easeCurve.Evaluate(t);
                
                Shader.SetGlobalFloat(Progress, Mathf.Lerp(from, to, curved));

                await Task.Yield();
            }

            Shader.SetGlobalFloat(Progress, to);
        }

        private async void FireAndForget(Func<CancellationToken, Task> fn, [CanBeNull] Action callback)
        {
            try
            {
                await fn(destroyCancellationToken);
                callback?.Invoke();
            }
            catch (OperationCanceledException) { }
            catch (Exception e)
            {
                Debug.LogException(e);
            }
        }
    }
}