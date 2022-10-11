using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class startAIScript : MonoBehaviour
{
    public GameObject ai;
    public GameObject collectible;
    public Text colText;

    public int coll = 0;
    void Update()
    {
        if (Input.GetKeyDown(KeyCode.E))
        {
            if (Vector3.Distance(ai.transform.position, transform.position) < 3)
            {
                ai.GetComponent<AIfollowPlayerScript>().enabled = true;
                CreateCollectible();
            }
        }
    }

    public void CreateCollectible()
    {
        for (int i = 0; i < 3; i++)
        {
            Instantiate(collectible, new Vector3(Random.Range(8.5f, 29f), -6, Random.Range(4.5f, 23.5f)), Quaternion.identity);
            //8.5, -6, 4.5
            //29, -6, 23.5
        }
    }

    public void Collect(GameObject g)
    {
        coll += 1;
        colText.text = "Sphere Collected : " + coll;
        Destroy(g);
    }
}
