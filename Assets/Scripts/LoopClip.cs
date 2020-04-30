using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class LoopClip : MonoBehaviour
{
    new public Renderer renderer = null;

    public float from;
    public float to;
    public float speed = 1.0f;

    private float t;
    private Material m;
    void Start()
    {
        t = 0.0f;
        if (renderer == null)
        {
            return;
        }
        m = renderer.material;
    }

    // Update is called once per frame
    void Update()
    {
        if (speed < 0.0f)
        {
            speed = 0.0f;
        }
        t += Time.deltaTime * speed;
        if (t > 1.0f)
        {
            t = 0.0f;
        }
        m.SetFloat("_Clip", Mathf.Lerp(from, to, t));
    }
}
