using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class DrawMeshInstanced : MonoBehaviour
{
    static int baseColorId = Shader.PropertyToID("_BaseColor"),
        metallicId = Shader.PropertyToID("_Metallic"),
        smoothnessId = Shader.PropertyToID("_Smoothness");

    [SerializeField]
    Mesh mesh = default;
    public Material material;

    private const int count = 1023;
    private Matrix4x4[] matrices = new Matrix4x4[count];
    private Vector4[] colors = new Vector4[count];
    private float[] metallic = new float[count];
    private float[] smoothness = new float[count];
    private MaterialPropertyBlock block;

    private void Awake()
    {
        Random.InitState((int)System.DateTime.Now.Ticks);        

        for(int i=0;i< count;++i)
        {
            matrices[i] = Matrix4x4.TRS(Random.insideUnitSphere * 10, transform.rotation, transform.localScale);
            colors[i] = new Color(Random.value, Random.value, Random.value, 1);
            metallic[i] = Random.Range(0.0f,1.0f);
            smoothness[i] = Random.Range(0.5f, 0.95f);
        }
        block = new MaterialPropertyBlock();
        block.SetVectorArray(baseColorId, colors);           
        block.SetFloatArray(metallicId, metallic);
        block.SetFloatArray(smoothnessId, smoothness);
    }

    private void Update()
    {        
        Graphics.DrawMeshInstanced(mesh, 0, material, matrices, count, block);                
    }
}
