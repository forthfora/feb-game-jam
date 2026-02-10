using UnityEngine;
using UnityEngine.InputSystem;

namespace GameJamProject
{
    public class Flashlight : MonoBehaviour
    {
        public RenderTexture renderTexture;
        
        private void LateUpdate()
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