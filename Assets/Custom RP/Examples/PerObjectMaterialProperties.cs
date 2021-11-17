using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PerObjectMaterialProperties : MonoBehaviour
{
    static int baseColorId = Shader.PropertyToID("_BaseColor");
    //不能在构造时初始化
    //static MaterialPropertyBlock block = new MaterialPropertyBlock();
    static MaterialPropertyBlock block;

    public Color color;

    private void Awake()
    {
        OnValidate();
    }

    private void OnValidate()
    {
        if (null == block)
            block = new MaterialPropertyBlock();

        block.SetColor(baseColorId, color);        
        GetComponent<Renderer>().SetPropertyBlock(block);        
    }

}
