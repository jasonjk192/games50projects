using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using UnityStandardAssets.Characters.FirstPerson;

public class endGameScript : MonoBehaviour
{
    public Text text;

    private void OnTriggerEnter(Collider other)
    {
        if (other.gameObject.CompareTag("Player"))
        {
            if(other.GetComponent<startAIScript>().coll == 3)
            { 
                other.GetComponent<Rigidbody>().velocity = Vector3.zero;
                other.GetComponent<FirstPersonController>().enabled = false;
                text.color = new Color(text.color.r, text.color.g, text.color.b, 1);
            }
            else
            {
                other.GetComponent<Rigidbody>().velocity = Vector3.zero;
                other.transform.position = new Vector3(10, 0, 5);
            }
        }
    }
}
