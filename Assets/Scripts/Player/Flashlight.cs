using System.Collections;
using System.Linq;
using UnityEngine;
using UnityEngine.InputSystem;
using UnityEngine.Rendering.Universal;
using UnityEngine.Tilemaps;

namespace GameJamProject
{
    public class Flashlight : MonoBehaviour
    {
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
            Main.Instance.SceneChange += InstanceOnSceneChange;
        }

        // refresh collider for this level
        private void InstanceOnSceneChange()
        {
            _torchColliderMask = GameObject.FindGameObjectsWithTag("TorchColliderMask").First();
            _collider1 = _torchColliderMask.GetComponentInParent<CompositeCollider2D>();
            _collider2 = _torchColliderMask.GetComponentInParent<TilemapCollider2D>();
            _collider3 = _torchColliderMask.GetComponent<PolygonCollider2D>();
        }
        
        private void Update()
        {
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
            var lightAngle = Mathf.Atan2(direction.y, direction.x) * Mathf.Rad2Deg;
            
            transform.rotation = Quaternion.Euler(0, 0, lightAngle);
            PointDir = direction;
        }
    }
}