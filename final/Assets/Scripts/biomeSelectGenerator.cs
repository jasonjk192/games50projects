using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using UnityEngine.SceneManagement;

public class biomeSelectGenerator : MonoBehaviour
{
    public Material[] groundMaterial;
    GameObject ground;
    int biomeIndex = 0;

    public GameObject[] trees;
    public GameObject[] rocks;
    public GameObject pointLight;
    public GameObject envLight;

    public string[] env_names;

    private bool isAxisInUse = false;
    public static bool isNight = false;

    private Color[] envColor;

    public Text[] selectionText;

    private int selectedText = 0;

    public GameObject menuSounds;
    void Start()
    {
        envColor = new Color[] { Color.green, new Color(1,0.7f,0.7f),Color.yellow, new Color(1,0.7f,0), Color.white };
        GenerateBlock(0);
        TextSelection();
    }

    void Update()
    {
        if (ground)
            ground.transform.Rotate(new Vector3(0, 0.6f, 0));
        float lr = Input.GetAxisRaw("Horizontal");
        float ud = Input.GetAxisRaw("Vertical");

        if (lr > 0 && isAxisInUse == false)
        {
            if (selectedText == 0)
            {
                isNight = !isNight;
                selectionText[0].text = isNight ? "NIGHT" : "DAY";
                envLight.GetComponent<Light>().intensity = isNight ? 0.25f : 1;
                menuSounds.GetComponents<AudioSource>()[0].Play();
            }
            else if (selectedText == 1)
            {
                if(biomeIndex == groundMaterial.Length -1)
                    menuSounds.GetComponents<AudioSource>()[2].Play();
                else
                    menuSounds.GetComponents<AudioSource>()[0].Play();
                biomeIndex = Mathf.Clamp(biomeIndex + 1, 0, groundMaterial.Length - 1);
            }
            Destroy(ground);
            GenerateBlock(biomeIndex);
            isAxisInUse = true;
        }
        else if (lr < 0 && isAxisInUse == false)
        {
            if (selectedText == 0)
            {
                isNight = !isNight;
                selectionText[0].text = isNight ? "NIGHT" : "DAY";
                envLight.GetComponent<Light>().intensity = isNight ? 0.25f : 1;
                menuSounds.GetComponents<AudioSource>()[0].Play();
            }
            else if (selectedText  == 1)
            {
                if (biomeIndex == 0)
                    menuSounds.GetComponents<AudioSource>()[2].Play();
                else
                    menuSounds.GetComponents<AudioSource>()[0].Play();
                biomeIndex = Mathf.Clamp(biomeIndex - 1, 0, groundMaterial.Length - 1);
            }
            Destroy(ground);
            GenerateBlock(biomeIndex);
            isAxisInUse = true;
        }
        else if (ud > 0 && isAxisInUse == false)
        {
            if(selectedText == 1)
                menuSounds.GetComponents<AudioSource>()[0].Play();
            else
                menuSounds.GetComponents<AudioSource>()[2].Play();
            selectedText = Mathf.Clamp(selectedText - 1, 0, selectionText.Length - 1);
            TextSelection();
            isAxisInUse = true;
        }
        else if (ud < 0 && isAxisInUse == false)
        {
            if (selectedText == 0)
                menuSounds.GetComponents<AudioSource>()[0].Play();
            else
                menuSounds.GetComponents<AudioSource>()[2].Play();
            selectedText = Mathf.Clamp(selectedText + 1, 0, selectionText.Length - 1);
            TextSelection(); 
            isAxisInUse = true;
        }
        else if (lr == 0 && ud == 0)
        {
            isAxisInUse = false;
        }

        if(Input.GetButtonDown("Submit"))
        {

            menuSounds.GetComponents<AudioSource>()[1].Play();
            if(DontDestroy.instance)
                DontDestroy.instance.GetComponents<AudioSource>()[0].Stop();
            constants.resetConstants();
            switch(biomeIndex)
            {
                case 0: 
                    SceneManager.LoadScene("SummerScene");
                    break;
                case 1:
                    SceneManager.LoadScene("SpringScene");
                    break;
                case 2:
                    SceneManager.LoadScene("AutumnScene");
                    break;
                case 3:
                    SceneManager.LoadScene("DesertScene");
                    break;
                case 4:
                    SceneManager.LoadScene("WinterScene");
                    break;
            }
            
        }
        else if(Input.GetButtonDown("Cancel"))
        {
            menuSounds.GetComponents<AudioSource>()[2].Play();
            SceneManager.LoadScene("StartScene");
        }
    }

    void TextSelection()
    {
        selectionText[selectedText].fontSize = 20;
        if (selectedText==0)
        {
            selectionText[0].color = Color.white;
            selectionText[0].fontSize = 20;
            selectionText[1].color = envColor[biomeIndex]-new Color(0.1f, 0.1f, 0.1f, 0.3f);
            selectionText[1].fontSize = 14;
            selectionText[0].gameObject.GetComponentInChildren<Image>().enabled = true;
            selectionText[1].gameObject.GetComponentInChildren<Image>().enabled = false;
        }
        else if (selectedText == 1)
        {
            selectionText[0].color = Color.white - new Color(0.1f, 0.1f, 0.1f, 0.3f);
            selectionText[0].fontSize = 14;
            selectionText[1].color = envColor[biomeIndex];
            selectionText[1].fontSize = 20;
            selectionText[0].gameObject.GetComponentInChildren<Image>().enabled = false;
            selectionText[1].gameObject.GetComponentInChildren<Image>().enabled = true;
        }
    }
    void GenerateBlock(int i)
    {
        selectionText[1].text = env_names[i].ToUpper();
        selectionText[1].color = envColor[i];
        TextSelection();

        ground = GameObject.CreatePrimitive(PrimitiveType.Cube);
        ground.transform.localScale = new Vector3(2f, 0.5f, 2f);
        ground.GetComponent<Renderer>().material = groundMaterial[i];
        ground.transform.position = new Vector3(0f, -0.25f, -5f);
        float space = 0.25f;
        int hs = 1;

        for (float x = 0.2f; x < 1.8f; x += space)
        {
            float scaleFactor = Random.Range(0.1f, 0.2f);

            for (float z = 0.2f; z < 1.8f; z += space)
            {
                int rn = Random.Range(1, 10);
                if (rn == 1)
                {
                    scaleFactor = Random.Range(0.1f, 0.2f);
                    var rockPrefab = Instantiate(rocks[Random.Range(0, rocks.Length - 1)], new Vector3(x - hs, 0, z - hs - 5f), Quaternion.identity);
                    rockPrefab.transform.localScale = new Vector3(scaleFactor, scaleFactor, scaleFactor);
                    rockPrefab.transform.parent = ground.transform;
                }
                else if (rn == 2)
                {
                    scaleFactor = Random.Range(0.1f, 0.2f);
                    var treePrefab = Instantiate(trees[Random.Range(0, 2) + 3*i], new Vector3(x - hs, 0, z - hs - 5f), Quaternion.identity);
                    treePrefab.transform.localScale = new Vector3(scaleFactor, scaleFactor, scaleFactor);
                    treePrefab.transform.parent = ground.transform;
                    if(isNight)
                    {
                        var lightPrefab = Instantiate(pointLight, new Vector3(x - hs, 0, z - hs - 5f), Quaternion.identity);
                        lightPrefab.transform.parent = ground.transform;
                    }
                }
            }

        }
    }
}
