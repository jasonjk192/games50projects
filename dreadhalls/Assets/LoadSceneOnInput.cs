using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;

public class LoadSceneOnInput : MonoBehaviour {
	public static int mazeno = 1;
	private AudioSource soundSource=null;
	void Start () {
		if (DontDestroy.instance!=null)
			soundSource = DontDestroy.instance.GetComponents<AudioSource>()[0];
	}
	
	// Update is called once per frame
	void Update () {
		if (Input.GetAxis("Submit") == 1) {
			if (soundSource != null)
				if (!soundSource.isPlaying)
					soundSource.Play();
			SceneManager.LoadScene("Play");
		}
	}
}
