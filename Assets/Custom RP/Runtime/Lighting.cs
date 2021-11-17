using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;

public class Lighting
{
    static int DirectionLightId = Shader.PropertyToID("_LightDir0");
    const string bufferName = "Lighting";

    CommandBuffer buffer = new CommandBuffer()
    {
        name = bufferName,
    };

    public void Setup(ScriptableRenderContext context)
    {        
        Light light = RenderSettings.sun;
        if (null == light)
            buffer.SetGlobalVector(DirectionLightId, Vector4.zero);
        else
            buffer.SetGlobalVector(DirectionLightId, -light.transform.forward);
        context.ExecuteCommandBuffer(buffer);
        buffer.Clear();
    }
}
