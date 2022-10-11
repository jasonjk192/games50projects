using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;

public class triggerGameOver : MonoBehaviour {
	private AudioSource pickupSoundSource;
	void Awake()
	{
		pickupSoundSource = DontDestroy.instance.GetComponents<AudioSource>()[0];
	}
	void Update () {
		if (transform.position.y<-2)
        {
			LoadSceneOnInput.mazeno = 1;
			pickupSoundSource.Stop();
			SceneManager.LoadScene("GameOver");
		}
	}
}
