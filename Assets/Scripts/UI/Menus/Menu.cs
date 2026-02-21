using System;
using System.Collections;
using JetBrains.Annotations;
using UnityEngine;

namespace GameJamProject
{
    public abstract class Menu : MonoBehaviour
    {
        public bool isVisible = true;
        public float timeToFade;

        protected bool AcceptInput { get; set; } = true;
        private float TargetAlpha => isVisible ? 1.0f : 0.0f;
    
        private CanvasGroup _canvasGroup;
        private float _fadeVel;

        public virtual void Start()
        {
            _canvasGroup = GetComponent<CanvasGroup>();
        }

        public virtual void Update()
        {
            _canvasGroup.alpha = Mathf.SmoothDamp(_canvasGroup.alpha, TargetAlpha, ref _fadeVel, timeToFade);
            _canvasGroup.blocksRaycasts = AcceptInput;
        }
    
        public void Show()
        {
            isVisible = true;
            AcceptInput = true;
        }

        public IEnumerator Hide([CanBeNull] Action callback)
        {
            isVisible = false;
            AcceptInput = false;
            
            while (Mathf.Abs(_canvasGroup.alpha - TargetAlpha) > 0.01f)
            {
                yield return null;
            }
            
            callback?.Invoke();
        }

        public void HideNow()
        {
            StartCoroutine(Hide(null));
            _canvasGroup.alpha = 0.0f;
        }
    }   
}