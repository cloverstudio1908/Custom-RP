using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;

public class Lighting
{
    static int DirectionLightId = Shader.PropertyToID("_LightDir0"),
        DirectionLightColorId = Shader.PropertyToID("_LightColor0");
    const string bufferName = "Lighting";

    CommandBuffer buffer = new CommandBuffer()
    {
        name = bufferName,
    };
    Shadows shadows = new Shadows();

    public void Setup(ScriptableRenderContext context, CullingResults cullingResults, ShadowSettings shadowSettings)
    {
        Light light = RenderSettings.sun;
        shadows.Setup(context, cullingResults, shadowSettings);
        SetupLight();
        shadows.Render();
        context.ExecuteCommandBuffer(buffer);
        buffer.Clear();        
    }

    void SetupLight()
    {
        Light light = RenderSettings.sun;
        if (null == light)
        {
            buffer.SetGlobalVector(DirectionLightId, Vector4.zero);
            buffer.SetGlobalColor(DirectionLightColorId, Color.black);            
        }
        else
        {
            buffer.SetGlobalVector(DirectionLightId, -light.transform.forward);
            buffer.SetGlobalColor(DirectionLightColorId, light.color.linear * light.intensity);
            shadows.Reserve(light, 0);
        }
    }

    public void Cleanup()
    {
        shadows.Cleanup();
    }
}
