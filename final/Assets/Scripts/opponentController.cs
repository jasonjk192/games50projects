using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class opponentController : MonoBehaviour
{
    public float moveSpeed = 4f;
    GameObject player;
    [SerializeField]
    float vel = 0f;

    public float angle = 0f;
    void Start()
    {
        player = GameObject.FindGameObjectWithTag("Player");
    }

    void Update()
    {
        vel = Vector3.Magnitude(GetComponent<Rigidbody>().velocity);
        angle = Vector3.Angle(player.transform.position - transform.position, GetComponent<Rigidbody>().velocity);
        if (transform.position.y < -20)
        {
            GameObject.Find("Generator").GetComponent<gameSceneHandler>().UpdateOpponentCount();
            Destroy(gameObject);
        }
    }

    void FixedUpdate()
    {
        Vector3 dir = player.transform.position - transform.position;
        dir.y = 0;
        Vector3 heading = Vector3.Normalize(dir);
        GetComponent<Rigidbody>().AddForce(heading * moveSpeed);

        float x1 = generateGroundScript.ground_size/2 - transform.position.x;
        if (x1 > 0)
        {
            GetComponent<Rigidbody>().AddForce(Vector3.left * moveSpeed /x1);
        }
        x1 = generateGroundScript.ground_size / 2 + transform.position.x;
        if (x1 > 0)
        {
            GetComponent<Rigidbody>().AddForce(Vector3.right * moveSpeed / x1);
        }

        x1 = generateGroundScript.ground_size / 2 - transform.position.z;
        if (x1 > 0)
        {
            GetComponent<Rigidbody>().AddForce(Vector3.back * moveSpeed / x1);
        }
        x1 = generateGroundScript.ground_size / 2 + transform.position.z;
        if (x1 > 0)
        {
            GetComponent<Rigidbody>().AddForce(Vector3.forward * moveSpeed / x1);
        }

        if (Vector3.Magnitude(GetComponent<Rigidbody>().velocity) > moveSpeed)
            GetComponent<Rigidbody>().velocity = Vector3.ClampMagnitude(GetComponent<Rigidbody>().velocity, moveSpeed);
    }
    void OnCollisionEnter(Collision collision)
    {
        if (collision.gameObject.CompareTag("Player") || collision.gameObject.CompareTag("Enemy"))
        {
            collision.gameObject.GetComponent<Rigidbody>().AddForce(GetComponent<Rigidbody>().velocity * - Vector3.Magnitude(collision.impulse));
            GetComponent<Rigidbody>().AddForce(collision.rigidbody.velocity * - Vector3.Magnitude(collision.impulse));
        }
    }
}
