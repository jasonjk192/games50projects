using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class invisTimerScript : MonoBehaviour
{
    public float waitTime = 1f;
    void Start()
    {
        Material[] mat = GetComponent<Renderer>().materials;
        for (int j = 0; j < mat.Length; j++)
        {
            MaterialExtensions.ToFadeMode(mat[j]);
            mat[j].color = new Color(mat[j].color.r, mat[j].color.g, mat[j].color.b, 0.2f);
        }
        StartCoroutine(WaitCoroutine());
    }
    
    IEnumerator WaitCoroutine()
    {
        yield return new WaitForSeconds(waitTime);
        Material[] mat = GetComponent<Renderer>().materials;
        for (int j = 0; j < mat.Length; j++)
        {
            MaterialExtensions.ToOpaqueMode(mat[j]);
            mat[j].color = new Color(mat[j].color.r, mat[j].color.g, mat[j].color.b, 1f);
        }
        Destroy(this);
    }
}
