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

        public bool IsActive { get; set; }
        public Vector2 PointDir { get; set; }

        
        private float _beamMaxIntensity;
        private float _spotMaxIntensity;
        
        // Faster than string lookup
        private static readonly int TorchWorldPos = Shader.PropertyToID("_TorchWorldPos");
        private static readonly int TorchPointDir = Shader.PropertyToID("_TorchPointDir");
        private static readonly int TorchEnabled = Shader.PropertyToID("_TorchEnabled");

        private void Start()
        {
            _beamMaxIntensity = beamLight.intensity;
            _spotMaxIntensity = spotLight.intensity;

            beamLight.intensity = 0.0f;
            spotLight.intensity = 0.0f;
        }

        private void Update()
        {
            Shader.SetGlobalVector(TorchWorldPos, gameObject.transform.position);
            Shader.SetGlobalVector(TorchPointDir, PointDir);
            Shader.SetGlobalInteger(TorchEnabled, IsActive ? 1 : 0);
        }

        private void LateUpdate()
        {
            var d = lightDelta * Time.deltaTime;
           
            if (IsActive)
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
            IsActive = !IsActive;
        }

        private void RotateToMouse()
        {
            var mainCam = Main.Instance.mainCamera;
            
            if (mainCam is null)
            {
                return;
            }
            
            var mouseScreen = Mouse.current.position.ReadValue();
            var mouseWorld = mainCam.ScreenToWorldPoint(new Vector3(mouseScreen.x, mouseScreen.y, -mainCam.transform.position.z));
            
            var direction = ((Vector2)mouseWorld - (Vector2)transform.position).normalized;
            var angle = Mathf.Atan2(direction.y, direction.x) * Mathf.Rad2Deg;
            
            transform.rotation = Quaternion.Euler(0, 0, angle);
            PointDir = direction;
        }
    }
}