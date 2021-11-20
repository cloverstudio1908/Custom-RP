using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PerObjectMaterialProperties : MonoBehaviour
{
    static int baseColorId = Shader.PropertyToID("_BaseColor"),
        metallicId = Shader.PropertyToID("_Metallic"),
        smoothnessId = Shader.PropertyToID("_Smoothness");

    //不能在构造时初始化
    //static MaterialPropertyBlock block = new MaterialPropertyBlock();
    static MaterialPropertyBlock block;

    public Color color;
    [Range(0f, 1f)]
    public float metallic, smoothness;

    private void Awake()
    {
        OnValidate();
    }

    private void OnValidate()
    {
        if (null == block)
            block = new MaterialPropertyBlock();

        block.SetColor(baseColorId, color);        
        block.SetFloat(metallicId, metallic);
        block.SetFloat(smoothnessId, smoothness);
        GetComponent<Renderer>().SetPropertyBlock(block);        
    }

}
