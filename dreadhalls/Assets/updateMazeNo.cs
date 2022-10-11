using System.Collections;
using System.Collections.Generic;
using UnityEngine.UI;
using UnityEngine;

public class updateMazeNo : MonoBehaviour {

	void Start () {
		GetComponent<Text>().text = "Maze : " + LoadSceneOnInput.mazeno;
	}
}
