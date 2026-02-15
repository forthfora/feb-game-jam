using UnityEngine;

public class ParallaxObject : MonoBehaviour
{
    public GameObject target;
    public Vector2 intensity;
    private Vector2 _startXY, _targetStart;
    private float _startZ;
    
    void Start()
    {
        _startXY = gameObject.transform.position;
        _startZ = gameObject.transform.position.z;
        _targetStart = target.transform.position;
    }

    void Update()
    {
        Vector2 diff = (Vector2)target.transform.position - _targetStart;
        Vector2 pos = intensity * diff + _startXY;
        
        transform.position = new Vector3(pos.x, pos.y, _startZ);
    }
}
