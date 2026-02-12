using System;
using UnityEngine;
using UnityEngine.InputSystem;
using UnityEngine.Rendering.Universal;

namespace GameJamProject
{
    public class Flashlight : MonoBehaviour
    {
        public Light2D beamLight;
        public Light2D spotLight;
        public float lightDelta;

        private bool _isActive = true;
        private float _beamMaxIntensity;
        private float _spotMaxIntensity;
        private Vector2 _lastPointDirection;

        private void Start()
        {
            _beamMaxIntensity = beamLight.intensity;
            _spotMaxIntensity = spotLight.intensity;
        }
        
        void Update()
        {
            Shader.SetGlobalVector("_TorchWorldPos", gameObject.transform.position);
            Shader.SetGlobalVector("_TorchPointDir", _lastPointDirection);
        }

        private void LateUpdate()
        {
            float d = lightDelta * Time.deltaTime;
            if (_isActive)
            {
                beamLight.intensity = Mathf.Lerp(beamLight.intensity, _beamMaxIntensity, d);
                spotLight.intensity = Mathf.Lerp(spotLight.intensity, _spotMaxIntensity, d);
            }
            else
            {
                beamLight.intensity = Mathf.Lerp(beamLight.intensity, 0.0f, d);
                spotLight.intensity = Mathf.Lerp(spotLight.intensity, 0.0f, d);
            }
            
            RotateToMouse();
        }

        public void Toggle()
        {
            _isActive = !_isActive;
        }

        private void RotateToMouse()
        {
            var mainCam = Camera.main;
            
            if (mainCam is null)
            {
                return;
            }
            
            var mouseScreen = Mouse.current.position.ReadValue();
            var mouseWorld = mainCam.ScreenToWorldPoint(new Vector3(mouseScreen.x, mouseScreen.y, -mainCam.transform.position.z));
            
            var direction = ((Vector2)mouseWorld - (Vector2)transform.position).normalized;
            var angle = Mathf.Atan2(direction.y, direction.x) * Mathf.Rad2Deg;
            
            transform.rotation = Quaternion.Euler(0, 0, angle);
            _lastPointDirection = direction;
        }
    }
}