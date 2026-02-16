using UnityEngine;

namespace GameJamProject
{
    public class FollowCamera : MonoBehaviour
    {
        private void Update()
        {
            var camPos = Main.Instance.mainCamera.transform.position;
            transform.position = new Vector3(camPos.x, camPos.y, transform.position.z);
        }
    }
}
