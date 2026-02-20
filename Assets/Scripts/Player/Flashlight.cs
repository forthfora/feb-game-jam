using System.Collections.Generic;
using System.Linq;
using UnityEngine;
using UnityEngine.InputSystem;

namespace GameJamProject
{
    public class Flashlight : MonoBehaviour
    {
        public float onValue;
        public float offValue;
        public float timeToOnOff;

        public bool IsActive { get; set; }
        public Vector2 PointDir { get; set; }

        private GameObject _presentMask;
        private GameObject _pastMask;

        private readonly List<Collider2D> _presentColliders = new();
        private readonly List<Collider2D> _pastColliders = new();
        
        private float _beamMaxIntensity;
        private float _spotMaxIntensity;

        private float _onOffLerp;
        private float _onOffVel;
        
        
        // Faster than string lookup
        private static readonly int TorchWorldPos = Shader.PropertyToID("_TorchScreenPos");
        private static readonly int TorchPointDir = Shader.PropertyToID("_TorchPointDir");
        private static readonly int TorchConeAngle = Shader.PropertyToID("_ConeAngle");
        private static readonly int TorchEnabled = Shader.PropertyToID("_TorchEnabled");
        private Camera _mainCam;

        private void Start()
        {
            Main.Instance.SceneChange += InstanceOnSceneChange;
            
            Shader.SetGlobalInteger(TorchEnabled, 1);
            
            _mainCam = Camera.main;
            _onOffLerp = offValue;
        }

        // refresh collider for this level
        private void InstanceOnSceneChange()
        {
            _presentMask = GameObject.FindGameObjectsWithTag("PresentMask").First();
            _pastMask = GameObject.FindGameObjectsWithTag("PastMask").First();

            _presentColliders.Clear();
            _pastColliders.Clear();
            
            _presentColliders.AddRange(_presentMask.GetComponentsInParent<Collider2D>());
            _presentColliders.Add(_presentMask.GetComponent<Collider2D>());
            
            _pastColliders.AddRange(_pastMask.GetComponentsInParent<Collider2D>());
            _pastColliders.Add(_pastMask.GetComponent<Collider2D>());
            
            Debug.Log("New scene");
            foreach (var x in _pastColliders)
                Debug.Log(x);
        }
        
        private void Update()
        {
            _onOffLerp = Mathf.SmoothDamp(_onOffLerp, IsActive ? onValue : offValue, ref _onOffVel, timeToOnOff);

            Shader.SetGlobalVector(TorchWorldPos, _mainCam.WorldToViewportPoint(transform.position));
            Shader.SetGlobalVector(TorchPointDir, PointDir);
            Shader.SetGlobalFloat(TorchConeAngle, _onOffLerp);

            if (!_presentMask || !_pastMask)
            {
                return;
            }
            
            foreach (var x in _presentColliders)
            {
                x.enabled = !IsActive;
            }

            foreach (var x in _pastColliders)
            {   
                x.enabled = IsActive;
            }

            _presentMask.transform.position = transform.position;
            _presentMask.transform.rotation = transform.rotation;
            
            _pastMask.transform.position = transform.position;
            _pastMask.transform.rotation = transform.rotation;
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