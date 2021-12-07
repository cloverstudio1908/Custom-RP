using UnityEngine;
using UnityEngine.Rendering;

public class Shadows
{
    const string bufferName = "Shadows";
    static int shadowAtlasId = Shader.PropertyToID("_ShadowAtlas");
    static int shadowMatrix = Shader.PropertyToID("_ShadowMatrix");

    CommandBuffer buffer = new CommandBuffer()
    {
        name = bufferName,
    };
    ScriptableRenderContext context;
    CullingResults cullingResults;
    ShadowSettings shadowSettings;
    int lightIndex;    

    public void Setup(ScriptableRenderContext context, CullingResults cullingResults, ShadowSettings shadowSettings)
    {
        this.context = context;
        this.cullingResults = cullingResults;
        this.shadowSettings = shadowSettings;

        lightIndex = -1;
    }

    void ExecuteBuffer()
    {
        context.ExecuteCommandBuffer(buffer);
        buffer.Clear();
    }

    public void Reserve(Light light, int lightIndex)
    {
        if (light.shadows != LightShadows.None && light.shadowStrength > 0f && cullingResults.GetShadowCasterBounds(lightIndex, out Bounds bounds))
            this.lightIndex = lightIndex;        
    }

    public void Render()
    {
        if (lightIndex != -1)
        {
            int size = (int)shadowSettings.directional.atlasSize;
            buffer.GetTemporaryRT(shadowAtlasId, size, size, 32, FilterMode.Bilinear, RenderTextureFormat.Shadowmap);
            buffer.SetRenderTarget(shadowAtlasId, RenderBufferLoadAction.DontCare, RenderBufferStoreAction.Store);
            buffer.ClearRenderTarget(true, false, Color.clear);

            var sds = new ShadowDrawingSettings(cullingResults, lightIndex);
            cullingResults.ComputeDirectionalShadowMatricesAndCullingPrimitives(lightIndex, 0, 1, Vector3.zero, size, 0f, out Matrix4x4 viewMatrix, out Matrix4x4 projectionMatrix, out ShadowSplitData splitData);
            sds.splitData = splitData;            
            buffer.SetViewProjectionMatrices(viewMatrix, projectionMatrix);
            buffer.SetGlobalMatrix(shadowMatrix, projectionMatrix * viewMatrix);
            ExecuteBuffer();
            context.DrawShadows(ref sds);
        }
    }

    public void Cleanup()
    {
        if (lightIndex != -1)
        {
            buffer.ReleaseTemporaryRT(shadowAtlasId);
            ExecuteBuffer();
        }
    }
}