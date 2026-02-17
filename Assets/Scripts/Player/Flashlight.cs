using System.Linq;
using UnityEngine;
using UnityEngine.InputSystem;
using UnityEngine.Rendering.Universal;
using UnityEngine.Tilemaps;

namespace GameJamProject
{
    public class Flashlight : MonoBehaviour
    {
        public Light2D beamLight;
        public Light2D spotLight;
        public float lightDelta;

        public float angle;

        public bool IsActive { get; set; }
        public Vector2 PointDir { get; set; }

        private GameObject _torchColliderMask;
        private Collider2D _collider1;
        private Collider2D _collider2;
        private Collider2D _collider3;
        
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

            // _torchColliderMask = GameObject.FindGameObjectsWithTag("TorchColliderMask").First();
        }

        private void Update()
        {
            // Doesn't fucking work in Start()
            if (!_torchColliderMask)
            {
                _torchColliderMask = GameObject.FindGameObjectsWithTag("TorchColliderMask").First();
                _collider1 = _torchColliderMask.GetComponentInParent<CompositeCollider2D>();
                _collider2 = _torchColliderMask.GetComponentInParent<TilemapCollider2D>();
                _collider3 = _torchColliderMask.GetComponent<PolygonCollider2D>();
            }
                
            
            Shader.SetGlobalVector(TorchWorldPos, transform.position);
            Shader.SetGlobalVector(TorchPointDir, PointDir);
            Shader.SetGlobalInteger(TorchEnabled, IsActive ? 1 : 0);
            
            _collider1.enabled = IsActive;
            _collider2.enabled = IsActive;
            _collider3.enabled = IsActive;
            _torchColliderMask.transform.position = transform.position;
            _torchColliderMask.transform.rotation = transform.rotation;
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