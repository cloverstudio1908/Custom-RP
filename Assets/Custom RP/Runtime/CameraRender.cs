using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;

public partial class CameraRender
{
    static ShaderTagId UnlitShaderTagId = new ShaderTagId("SRPDefaultUnlit"),
        LitShaderTagId = new ShaderTagId("CustomLit");
    const string bufferName = "Render Camera";

    ScriptableRenderContext context;
    Camera camera;
    CommandBuffer buffer = new CommandBuffer()
    {
        name = bufferName,
    };
    CullingResults cullingResults;
    Lighting lighting = new Lighting();

    public void Render(ScriptableRenderContext context, Camera camera, bool useDynamicBatching, bool useGPUInstancing, ShadowSettings shadowSettings)
    {
        this.context = context;
        this.camera = camera;

#if UNITY_EDITOR
        PrepareForSceneWindow();
#endif
        if (!Cull(shadowSettings.maxDistance))
            return;
        
        lighting.Setup(context, cullingResults, shadowSettings);

        Setup();
        DrawVisibleGeometry(useDynamicBatching, useGPUInstancing);

#if UNITY_EDITOR
        DrawUnsupportedShaders();
        DrawGizmos();
#endif

        lighting.Cleanup();
        Submit();
    }

    bool Cull(float maxShadowDistance)
    {
        if(camera.TryGetCullingParameters(out ScriptableCullingParameters p))
        {
            p.shadowDistance = Mathf.Min(maxShadowDistance, camera.farClipPlane);
            cullingResults = context.Cull(ref p);
            return true;
        }

        return false;
    }

    void ExecuteBuffer()
    {
        context.ExecuteCommandBuffer(buffer);
        buffer.Clear();
    }

    void Setup()
    {
        context.SetupCameraProperties(camera);
        buffer.ClearRenderTarget(true, true, Color.clear);
        buffer.BeginSample(bufferName);
        ExecuteBuffer();        
    }

    void DrawVisibleGeometry(bool useDynamicBatching, bool useGPUInstancing)
    {          
        SortingSettings sortingSettings = new SortingSettings(camera)
        {
            criteria = SortingCriteria.CommonOpaque,
        };
        //场景中的Renderer所用shader需要是无光照版才会被渲染
        DrawingSettings drawingSettings = new DrawingSettings(UnlitShaderTagId, sortingSettings)
        {
            enableDynamicBatching = useDynamicBatching,
            enableInstancing = useGPUInstancing,
        };
        drawingSettings.SetShaderPassName(1, LitShaderTagId);
        FilteringSettings filteringSettings = new FilteringSettings(RenderQueueRange.opaque);
        context.DrawRenderers(cullingResults, ref drawingSettings, ref filteringSettings);

        context.DrawSkybox(camera);

        sortingSettings.criteria = SortingCriteria.CommonTransparent;
        drawingSettings.sortingSettings = sortingSettings;
        filteringSettings.renderQueueRange = RenderQueueRange.transparent;
        context.DrawRenderers(cullingResults, ref drawingSettings, ref filteringSettings);
    }    

    void Submit()
    {
        buffer.EndSample(bufferName);
        ExecuteBuffer();
        context.Submit();
    }
}
