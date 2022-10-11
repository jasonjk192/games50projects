using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class respawnPlayerScript : MonoBehaviour
{

    private void OnTriggerEnter(Collider other)
    {
        if (other.gameObject.CompareTag("Player"))
        {
            other.GetComponent<Rigidbody>().velocity = Vector3.zero;
            other.transform.position = new Vector3(10,0,5);
        }
    }
}
