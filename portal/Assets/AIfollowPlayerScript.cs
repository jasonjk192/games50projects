using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class AIfollowPlayerScript : MonoBehaviour
{

    public GameObject player;

    void Update()
    {
        Vector3 dir = player.transform.position - transform.position;
        if (Vector3.Distance(player.transform.position,transform.position)>2)
            transform.Translate(Vector3.Normalize(dir) * Time.deltaTime * 4);
    }
}
