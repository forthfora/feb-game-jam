using System.Collections.Generic;
using System.Linq;
using UnityEngine;
using UnityEngine.InputSystem;

namespace GameJamProject
{
    public class Flashlight : MonoBehaviour
    {
        public float onAngle;
        public float offAngle;
        public float onRadius;
        public float offRadius;
        public float timeToOnOff;

        public Sprite onSprite;
        public Sprite offSprite;

        public bool IsActive { get; set; }
        public Vector2 PointDir { get; set; }

        private SpriteRenderer _spriteRenderer;
        private Camera _mainCam;
        private AudioSource _audioSource;
        
        private GameObject _presentMask;
        private GameObject _pastMask;

        private readonly List<Collider2D> _colliders = new();
        
        private float _beamMaxIntensity;
        private float _spotMaxIntensity;

        private float _angleLerp;
        private float _radiusLerp;
        private float _onOffVelAngle;
        private float _onOffVelRadius;
        
        
        // Faster than string lookup
        private static readonly int TorchWorldPos = Shader.PropertyToID("_TorchScreenPos");
        private static readonly int TorchPointDir = Shader.PropertyToID("_TorchPointDir");
        private static readonly int TorchConeAngle = Shader.PropertyToID("_ConeAngle");
        private static readonly int TorchRadius = Shader.PropertyToID("_Radius");
        private static readonly int TorchEnabled = Shader.PropertyToID("_TorchEnabled");

        private void Start()
        {
            Main.Instance.SceneChange += InstanceOnSceneChange;
            
            Shader.SetGlobalInteger(TorchEnabled, 1);
            
            _mainCam = Camera.main;
            _angleLerp = offAngle;
            _radiusLerp = offRadius;

            _spriteRenderer = GetComponentInChildren<SpriteRenderer>();
            _audioSource = GetComponent<AudioSource>();
        }

        // refresh collider for this level
        private void InstanceOnSceneChange(string sceneName)
        {
            _presentMask = GameObject.FindGameObjectsWithTag("PresentMask").First();
            _pastMask = GameObject.FindGameObjectsWithTag("PastMask").First();

            _colliders.Clear();
            
            _colliders.AddRange(_pastMask.GetComponentsInParent<Collider2D>());
            _colliders.Add(_pastMask.GetComponent<Collider2D>());
            _colliders.Add(_presentMask.GetComponent<Collider2D>());
            
        }
        
        private void Update()
        {
            _angleLerp  = Mathf.SmoothDamp(_angleLerp, IsActive ? onAngle : offAngle, ref _onOffVelAngle, timeToOnOff);
            _radiusLerp = Mathf.SmoothDamp(_radiusLerp, IsActive ? onRadius : offRadius, ref _onOffVelRadius, timeToOnOff);

            Shader.SetGlobalVector(TorchWorldPos, _mainCam.WorldToScreenPoint(transform.position));
            Shader.SetGlobalVector(TorchPointDir, PointDir);
            Shader.SetGlobalFloat(TorchConeAngle, _angleLerp);
            Shader.SetGlobalFloat(TorchRadius, _radiusLerp);

            _spriteRenderer.sprite = IsActive ? onSprite : offSprite;

            if (!_presentMask || !_pastMask)
            {
                return;
            }
            
            foreach (var x in _colliders)
            {
                x.enabled = IsActive;
            }

            _presentMask.transform.position = transform.position;
            _presentMask.transform.rotation = transform.rotation;
            
            _pastMask.transform.position = transform.position;
            _pastMask.transform.rotation = transform.rotation;
        }

        public void Toggle()
        {
            IsActive = !IsActive;
            _audioSource.Play();
        }

        public void RotateToMouse()
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