using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class checktriggerScript : MonoBehaviour
{
    private void OnTriggerEnter(Collider other)
    {
        if (other.CompareTag("Player"))
        {
            GetComponent<AIfollowPlayerScript>().enabled = true;
            other.GetComponent<startAIScript>().CreateCollectible();
            Destroy(this);
        }
    }
}
