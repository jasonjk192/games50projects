using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using UnityEngine.SceneManagement;

public class gameSceneHandler : MonoBehaviour
{
    public float countdownTimer = 3;
    public float gameTimer = 30;
    public bool timerIsRunning = false;

    GameObject player;
    Canvas canvas;
    Text text;
    Text collectibleCount;
    Text gameTimeText;
    Text vpText;
    Text velText;
    Image image;

    private void Start()
    {
        player = GameObject.FindGameObjectWithTag("Player");
        canvas = GameObject.Find("Canvas").GetComponent<Canvas>();
        text = canvas.transform.Find("Count").GetComponent<Text>();
        image = canvas.transform.Find("Image").GetComponent<Image>();
        collectibleCount = canvas.transform.Find("CollectibleCount").GetComponent<Text>();
        gameTimeText = canvas.transform.Find("GameTime").GetComponent<Text>();
        vpText = canvas.transform.Find("velPointText").GetComponent<Text>();
        velText = canvas.transform.Find("velText").GetComponent<Text>();
        timerIsRunning = true;
        player.GetComponent<playerController>().initSceneHandler();

        collectibleCount.text = "COLLECTIBLES : 0";
        gameTimeText.text = "TIME : " + (int)Mathf.Ceil(gameTimer);
        vpText.text = "VELOCITY POINTS : 0";
        velText.text = "VELOCITY : 0 units/s";
    }

    void Update()
    {
        if (timerIsRunning)
        {
            if (countdownTimer > 0)
            {
                text.text = (int)Mathf.Ceil(countdownTimer) + "";
                countdownTimer -= Time.deltaTime;
                PauseGame();
            }
            else
            {
                text.text = "";
                text.enabled = false;
                image.enabled = false;
                countdownTimer = 0;
                timerIsRunning = false;
                ContinueGame();
            }
        }
        else
        {
            float vel = Vector3.Magnitude(player.GetComponent<Rigidbody>().velocity);
            gameTimeText.text = "TIME : "+(int)Mathf.Ceil(gameTimer);
            vpText.text = "VELOCITY POINTS : " + constants.velocityPoint;
            velText.text = "VELOCITY : " + vel.ToString("F1") + " units/s";
            if (vel > 10)
                velText.color = Color.green;
            else
                velText.color = Color.white;
            gameTimer -= Time.deltaTime;
            if(gameTimer < 0)
            {
                constants.remainingTime = 0;
                gameOverSceneLoad();
            }
        }
    }
    void PauseGame()
    {
        GameObject.FindGameObjectWithTag("Player").GetComponent<playerController>().enabled = false;
        GameObject[] enemies = GameObject.FindGameObjectsWithTag("Enemy");
        foreach(GameObject enemy in enemies)
        {
            enemy.GetComponent<opponentController>().enabled = false;
            enemy.GetComponent<Rigidbody>().velocity = Vector3.zero;
        }
    }
    void ContinueGame()
    {
        GameObject.FindGameObjectWithTag("Player").GetComponent<playerController>().enabled = true;
        GameObject[] enemies = GameObject.FindGameObjectsWithTag("Enemy");
        foreach (GameObject enemy in enemies)
        {
            enemy.GetComponent<opponentController>().enabled = true;
        }
    }

    public void UpdateCount(int count)
    {
        collectibleCount.text = "COLLECTIBLES : " + count;
        constants.collectibleCount = count;
        if (count == 3)
        {
            constants.remainingTime = gameTimer;
            gameOverSceneLoad();
        }
    }

    public void UpdateOpponentCount()
    {
        constants.opponentCount++;
    }

    public void gameOverSceneLoad()
    {
        SceneManager.LoadScene("gameOverScene");
    }
}
