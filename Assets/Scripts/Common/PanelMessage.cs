using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using DG.Tweening;
using UnityEngine.UI;

public class PanelMessage : MonoBehaviour
{
    // Start is called before the first frame update
    void Start()
    {
        transform.Find("txt_message").GetComponent<Text>()
            .DOFade(0, 1)
            .SetDelay(1);
        transform.Find("txt_message").transform
            .DOMoveY(2.5f, 1.1f)
            .SetDelay(1)
            .OnComplete(()=>GameObject.Destroy(gameObject));
    }


}
