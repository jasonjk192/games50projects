using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class collectibleScript : MonoBehaviour
{
    void Update()
    {
        transform.Rotate(new Vector3(0, 0, 4));
    }
    private void OnTriggerEnter(Collider other)
    {
        if (other.CompareTag("Player"))
        {
            other.GetComponent<playerController>().collectibleCollect();
            Destroy(gameObject);
        }
    }
}
