using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class gameOverSceneManager : MonoBehaviour
{
    Canvas canvas;
    Text pointTallyText, highScoreText;
    int highScore;
    void Start()
    {
        highScore = PlayerPrefs.GetInt("highScore", highScore);
        if (DontDestroy.instance)
            DontDestroy.instance.GetComponents<AudioSource>()[0].Play();
        canvas = GameObject.Find("Canvas").GetComponent<Canvas>();
        pointTallyText = canvas.transform.Find("pointTallyText").GetComponent<Text>();
        highScoreText = canvas.transform.Find("highScoreText").GetComponent<Text>();

        int pt = Mathf.CeilToInt((constants.remainingTime * 250) + (constants.collectibleCount * 500) + (constants.opponentCount * 100) + (constants.velocityPoint));
        pointTallyText.text = "POINT TALLY : "+pt;
        if (pt > highScore)
        {
            highScoreText.text = "New High Score!";
            highScore = pt;
            PlayerPrefs.SetInt("highScore", highScore);
        }
        else
            highScoreText.text = "High Score : " + highScore;
    }

    private void Update()
    {
        if (Input.GetButtonDown("Submit"))
        {
            biomeSelectGenerator.isNight = false;
            UnityEngine.SceneManagement.SceneManager.LoadScene("SelectionScene");
        }
    }
}
