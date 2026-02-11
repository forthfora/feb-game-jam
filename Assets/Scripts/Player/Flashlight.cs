using System;
using UnityEngine;
using UnityEngine.InputSystem;
using UnityEngine.Rendering.Universal;

namespace GameJamProject
{
    public class Flashlight : MonoBehaviour
    {
        public RenderTexture renderTexture;
        public Light2D beamLight;
        public Light2D spotLight;

        private bool _isActive;
        private float _beamMaxIntensity;
        private float _spotMaxIntensity;

        private void Start()
        {
            _beamMaxIntensity = beamLight.intensity;
            _spotMaxIntensity = spotLight.intensity;
        }

        private void LateUpdate()
        {
            if (_isActive)
            {
                RotateToMouse();

                beamLight.intensity = Mathf.MoveTowards(beamLight.intensity, _beamMaxIntensity, 0.03f);
                spotLight.intensity = Mathf.MoveTowards(beamLight.intensity, _spotMaxIntensity, 0.03f);
            }
            else
            {
                beamLight.intensity = Mathf.MoveTowards(beamLight.intensity, 0.0f, 0.03f);
                spotLight.intensity = Mathf.MoveTowards(beamLight.intensity, 0.0f, 0.03f);
            }
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
    
            // Remap mouse position to render texture resolution
            var x = (mouseScreen.x / Screen.width) * renderTexture.width;
            var y = (mouseScreen.y / Screen.height) * renderTexture.height;
    
            var mouseWorld = mainCam.ScreenToWorldPoint(new Vector3(x, y, -mainCam.transform.position.z));
            var direction = ((Vector2)mouseWorld - (Vector2)transform.position).normalized;
            var angle = Mathf.Atan2(direction.y, direction.x) * Mathf.Rad2Deg;
            
            transform.rotation = Quaternion.Euler(0, 0, angle);
        }
    }
}