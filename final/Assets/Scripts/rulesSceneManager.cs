using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;

public class rulesSceneManager : MonoBehaviour
{
    public AudioSource enterSound;
    void Update()
    {
        if (Input.GetButtonDown("Submit") || Input.GetButtonDown("Cancel"))
        {
            enterSound.Play();
            SceneManager.LoadScene("startScene");
        }
    }
}
