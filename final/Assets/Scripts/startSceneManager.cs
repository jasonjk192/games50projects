using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;
using UnityEngine.UI;

public class startSceneManager : MonoBehaviour
{
    private bool isAxisInUse = false;
    private Canvas canvas;
    private Text startText, rulesText, exitText;
    private int selection = 1;

    public AudioSource[] startMenuSounds;

    void Start()
    {
        canvas = GameObject.Find("Canvas").GetComponent<Canvas>();
        startText = canvas.transform.Find("StartText").GetComponent<Text>();
        rulesText = canvas.transform.Find("RulesText").GetComponent<Text>();
        exitText = canvas.transform.Find("ExitText").GetComponent<Text>();
        TextSelection();
    }
    void Update()
    {
        float ud = Input.GetAxisRaw("Vertical");
        if (ud > 0 && isAxisInUse == false)
        {
            selection = Mathf.Clamp(selection - 1, 1, 3);
            TextSelection();
            startMenuSounds[0].Play();
            isAxisInUse = true;
        }
        else if (ud < 0 && isAxisInUse == false)
        {
            selection = Mathf.Clamp(selection + 1, 1, 3);
            TextSelection();
            startMenuSounds[0].Play();
            isAxisInUse = true;
        }
        else if (ud == 0)
        {
            isAxisInUse = false;
        }
        if (Input.GetButtonDown("Submit"))
        {
            startMenuSounds[1].Play();
            constants.resetConstants();
            switch (selection)
            {
                case 1:
                    SceneManager.LoadScene("SelectionScene");
                    break;
                case 2:
                    SceneManager.LoadScene("rulesScene");
                    break;
                case 3:
                    Application.Quit();
                    break;
            }
        }
    }

    void TextSelection()
    {
        switch(selection)
        {
            case 1:
                startText.GetComponentInChildren<Image>().enabled = true;
                rulesText.GetComponentInChildren<Image>().enabled = false;
                exitText.GetComponentInChildren<Image>().enabled = false;
                break;
            case 2:
                startText.GetComponentInChildren<Image>().enabled = false;
                rulesText.GetComponentInChildren<Image>().enabled = true;
                exitText.GetComponentInChildren<Image>().enabled = false;
                break;
            case 3:
                startText.GetComponentInChildren<Image>().enabled = false;
                rulesText.GetComponentInChildren<Image>().enabled = false;
                exitText.GetComponentInChildren<Image>().enabled = true;
                break;
        }
    }
}
