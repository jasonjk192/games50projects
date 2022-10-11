using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class followPlayer : MonoBehaviour
{
    GameObject player;

    List<GameObject> objects = new List<GameObject>();
    Vector3 offset = new Vector3(-25,20,-25);
    Vector3 dir;
    float dirLength;
    void Start()
    {
        player = GameObject.FindGameObjectWithTag("Player");
        dir = (player.transform.position - transform.position)  -Vector3.up;
        dirLength = Vector3.Magnitude(dir);
    }

    void Update()
    {
        Vector3 cpos = player.transform.position;
        cpos.y = offset.y;
        cpos.x += offset.x;
        cpos.z += offset.z;
        transform.position = cpos; 
        RaycastHit[] hits;
        hits = Physics.RaycastAll(transform.position, dir, dirLength);
        //Debug.DrawRay(transform.position, dir, Color.yellow);

        /* Hide all objects that are between the camera and player
         * Cause all such objects to be translucent (but still collidable)
         */
        for (int h = 0; h < hits.Length; h++)
        {
            RaycastHit hit = hits[h];
            //Debug.Log("Did Hit : " + hit.collider.name);
            if (hit.collider.CompareTag("EnvironmentObjects"))
            {
                GameObject envobj = hit.collider.gameObject;
                objects.Add(envobj);
                Material[] mat = envobj.GetComponent<Renderer>().materials;
                for (int i = 0; i < mat.Length; i++)
                {
                    MaterialExtensions.ToFadeMode(mat[i]);
                    mat[i].color = new Color(mat[i].color.r, mat[i].color.g, mat[i].color.b, 0.2f);
                }
            }
        }

        hits = Physics.RaycastAll(transform.position, dir, dirLength);
        //Debug.DrawRay(transform.position, dir, Color.red);

        /* Remove all objects that are not inbetween the camera and player
         * Restore opaqueness
         */
        for (int i = objects.Count - 1; i >= 0; i--)
        {
            bool hasObj = false;
            for(int h = 0; h < hits.Length; h++)
            {
                RaycastHit hit = hits[h];
                if (hit.collider.gameObject == objects[i])
                { 
                    hasObj = true;
                    break;
                }
            }
            if (!hasObj)
            {
                Material[] mat = objects[i].GetComponent<Renderer>().materials;
                for (int j = 0; j < mat.Length; j++)
                {
                    MaterialExtensions.ToOpaqueMode(mat[j]);
                    mat[j].color = new Color(mat[j].color.r, mat[j].color.g, mat[j].color.b, 1f);
                }
                objects.RemoveAt(i);
            }
        }

    }
}
