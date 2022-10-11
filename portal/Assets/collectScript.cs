using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class collectScript : MonoBehaviour
{
    GameObject sphere;
    private void Start()
    {
        sphere = GameObject.FindGameObjectWithTag("AI");
    }
    private void Update()
    {
        if(Vector3.Distance(sphere.transform.position, transform.position) < 4)
        {
            this.GetComponent<MeshRenderer>().enabled = true;
            this.GetComponentInChildren<Light>().enabled = true;
        }
        else
        {
            this.GetComponent<MeshRenderer>().enabled = false;
            this.GetComponentInChildren<Light>().enabled = false;
        }
    }
    private void OnTriggerEnter(Collider other)
    {
        if (other.gameObject.CompareTag("Player") && Vector3.Distance(sphere.transform.position, transform.position) < 4)
        {
            other.GetComponent<startAIScript>().Collect(this.gameObject);
        }
    }
}
