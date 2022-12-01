using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Rotatearound : MonoBehaviour
{
    // Start is called before the first frame update
    void Start()
    {
        
    }
    public Transform objectToRotateAround;
    public float RotateSpeed;
    // Update is called once per frame
    void Update()
    {
        transform.RotateAround(objectToRotateAround.position,Vector3.up,RotateSpeed);
        
    }
}
