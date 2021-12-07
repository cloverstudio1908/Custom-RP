#ifndef CUSTOM_SHADOW_CASTER_PASS_INCLUDED
#define CUSTOM_SHADOW_CASTER_PASS_INCLUDED

#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Common.hlsl"
#include "../ShaderLibrary/UnityInput.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/UnityInstancing.hlsl"    
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/SpaceTransforms.hlsl"        

TEXTURE2D(_MainTex);
SAMPLER(sampler_MainTex);

UNITY_INSTANCING_BUFFER_START(UnityPerMaterial)
    UNITY_DEFINE_INSTANCED_PROP(float4, _BaseMap_ST)
UNITY_INSTANCING_BUFFER_END(UnityPerMaterial)

struct Atrributes
{
    float3 vertex : POSITION;    
    float2 uv : TEXCOORD0;
    UNITY_VERTEX_INPUT_INSTANCE_ID
};

struct Varyings
{
    float4 positionWS : UNUSED1;
    float4 position : SV_POSITION;    
    float2 uv : UNUSED0;
    UNITY_VERTEX_INPUT_INSTANCE_ID
};

Varyings ShadowCasterVert(Atrributes input)
{
    Varyings output;
    UNITY_SETUP_INSTANCE_ID(input);
    UNITY_TRANSFER_INSTANCE_ID(input, output);

    output.positionWS = mul(UNITY_MATRIX_M, float4(input.vertex, 1.0));
    // output.position = mul(UNITY_MATRIX_VP, mul(UNITY_MATRIX_M, float4(input.vertex, 1.0)));
    output.position = mul(UNITY_MATRIX_VP, output.positionWS);
    output.uv = input.uv;
    return output;
}

void ShadowCasterFrag(Varyings input)
{
    UNITY_SETUP_INSTANCE_ID(input);
    float4 col = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, input.uv);    
    //return col;
}

#endif