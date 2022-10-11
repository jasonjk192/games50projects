using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class generateGroundScript : MonoBehaviour
{
    GameObject ground;

    public Material groundMaterial;

    public GameObject[] trees;
    public GameObject[] rocks;
    public GameObject[] miscObj;

    public GameObject pointLight;
    public GameObject envLight;

    GameObject treesParent;
    GameObject rocksParent;
    GameObject miscParent;

    public GameObject collectible;

    public GameObject[] entities;

    static public int ground_size = 100;

    static public int probDensity = 30; //Determines how many objects get generated

    int collectibleCount = 3;

    private bool isNight = biomeSelectGenerator.isNight;
    void Start()
    {
        treesParent = new GameObject("TreesParent");
        rocksParent = new GameObject("RocksParent");
        miscParent = new GameObject("MiscParent");

        ground = GameObject.CreatePrimitive(PrimitiveType.Quad);
        ground.transform.Rotate(90, 0, 0);
        ground.transform.localScale = new Vector3(ground_size, ground_size, 1);
        ground.GetComponent<Renderer>().material = groundMaterial;
        ground.tag = "Ground";

        GameObject g1 = GameObject.CreatePrimitive(PrimitiveType.Quad);
        g1.transform.localScale = new Vector3(ground_size, 30, 1);
        g1.transform.Rotate(0, 90, 0);
        g1.transform.position = new Vector3(-ground_size / 2, -15, 0);
        g1.GetComponent<Renderer>().material = groundMaterial;

        GameObject g2 = GameObject.CreatePrimitive(PrimitiveType.Quad);
        g2.transform.localScale = new Vector3(ground_size, 30, 1);
        g2.transform.position = new Vector3(0, -15, -ground_size / 2);
        g2.GetComponent<Renderer>().material = groundMaterial;

        if (isNight)
        {
            envLight.GetComponent<Light>().intensity = 0.25f;
            Camera.main.GetComponent<Camera>().backgroundColor = Color.black;
        }
        else
            envLight.GetComponent<Light>().intensity = 1;
        GenerateEnvironmentObjects();

        SpawnEntities();

        gameObject.AddComponent<gameSceneHandler>();
    }
    void CreateChildPrefab(GameObject prefab, GameObject parent, int x, int y, int z)
    {
        var myPrefab = Instantiate(prefab, new Vector3(x, y, z), Quaternion.identity);
        myPrefab.transform.parent = parent.transform;
    }

    void CreateChildPrefab(GameObject prefab, GameObject parent, Vector3 pos, Quaternion rot, float scaleFactor)
    {
        var myPrefab = Instantiate(prefab, pos, rot);
        myPrefab.transform.localScale = new Vector3(scaleFactor, scaleFactor, scaleFactor);
        myPrefab.transform.parent = parent.transform;
    }
    void CreateChildPrefab(GameObject prefab, GameObject parent)
    {
        prefab.transform.parent = parent.transform;
    }
    void GenerateEnvironmentObjects()
    {
        int space = 3;
        int hs = ground_size / 2;
        for (int x = 1; x < ground_size - 1; x += space)
        {
            float scaleFactor = Random.Range(1f, 5f);
            float offset = Random.Range(-1f, 1f);

            for (int z = 1 ; z < (ground_size - 1); z += space)
            {
                int rn = Random.Range(1, probDensity);
                if (rn == 1)
                {
                    scaleFactor = Random.Range(.5f, 2.5f);
                    var rockPrefab = Instantiate(rocks[Random.Range(0, rocks.Length)], new Vector3(x - hs, 0, z - hs), Quaternion.identity);
                    rockPrefab.transform.localScale = new Vector3(scaleFactor, scaleFactor, scaleFactor);
                    rockPrefab.tag = "EnvironmentObjects";
                    CreateChildPrefab(rockPrefab, rocksParent);
                }
                else if (rn <= 3)
                {
                    scaleFactor = Random.Range(.5f, 2.5f);
                    var treePrefab = Instantiate(trees[Random.Range(0, trees.Length)], new Vector3(x - hs, 0, z - hs), Quaternion.identity);
                    treePrefab.transform.localScale = new Vector3(scaleFactor, scaleFactor, scaleFactor);
                    treePrefab.tag = "EnvironmentObjects";
                    CreateChildPrefab(treePrefab, treesParent);
                    if (isNight)
                        CreateChildPrefab(pointLight, treesParent, new Vector3(x - hs, scaleFactor, z - hs), Quaternion.identity, 1);
                }
                else if (rn <= probDensity / 3)
                {
                    scaleFactor = Random.Range(1f, 2.5f);

                    var miscPrefab = Instantiate(miscObj[Random.Range(0, miscObj.Length)], new Vector3(x - hs + Random.Range(-1f, 1f), 0, z - hs + Random.Range(-1f, 1f)), Quaternion.identity);
                    miscPrefab.transform.localScale = new Vector3(scaleFactor, scaleFactor, scaleFactor);
                    miscPrefab.transform.Rotate(new Vector3(Random.Range(-20f, 20f), Random.Range(-180f, 180f), Random.Range(-20f, 20f)));
                    CreateChildPrefab(miscPrefab, miscParent);
                }

            }

        }
    }
    void SpawnEntities()
    {
        GameObject player = GameObject.FindGameObjectWithTag("Player");
        player.GetComponentInChildren<TrailRenderer>().enabled = true;
        int hs = ground_size / 2;
        player.transform.position = new Vector3(Random.Range(-hs + 7, hs - 7), 1, Random.Range(-hs + 7, hs - 7));
        for (int i = 0; i < entities.Length; i++)
        {
            var Prefab = Instantiate(entities[i], new Vector3(Random.Range(-hs + 7, hs - 7), 1, Random.Range(-hs + 7, hs - 7)), Quaternion.identity);
            Prefab.GetComponentInChildren<TrailRenderer>().enabled = true;
        }

        for (int i = collectibleCount; i > 0; i--)
            Instantiate(collectible, new Vector3(Random.Range(-hs + 7, hs - 7), 1, Random.Range(-hs + 7, hs - 7)), Quaternion.identity);
    }
}
