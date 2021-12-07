Shader "Custom RP/Lit"
{
    Properties
    {
        _MainTex ("Main Texture", 2D) = "white" {}
        _BaseColor ("Base Color", Color) = (0.5,0.5,0.5,1)   
        [Enum(UnityEngine.Rendering.BlendMode)] _SrcBlend ("Src Blend", float) = 1
        [Enum(UnityEngine.Rendering.BlendMode)] _DstBlend ("Dst Blend", float) = 0
        [Enum(Off, 0, On, 1)] _ZWrite ("Z Write", float) = 1
        _Metallic ("Metallic", Range(0.0, 1.0)) = 0.0
        _Smoothness ("Smoothness", Range(0.0, 1.0)) = 0.5  
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            Tags
            {
                "LightMode" = "CustomLit"
            }

            Blend [_SrcBlend] [_DstBlend]
            ZWrite [_ZWrite]

            HLSLPROGRAM
            #pragma target 3.5

            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Common.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/CommonMaterial.hlsl"
            #include "../ShaderLibrary/UnityInput.hlsl"
            #include "../ShaderLibrary/Surface.hlsl"
            #include "../ShaderLibrary/Light.hlsl"
            #include "../ShaderLibrary/BRDF.hlsl"
            #include "../ShaderLibrary/Lighting.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/UnityInstancing.hlsl"            
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/SpaceTransforms.hlsl"             

            #pragma multi_compile_instancing
            #pragma vertex vert
            #pragma fragment frag

            TEXTURE2D(_MainTex);
            SAMPLER(sampler_MainTex);   

            TEXTURE2D_SHADOW(_ShadowAtlas);
            #define SHADOW_SAMPLER sampler_linear_clamp_compare
            SAMPLER_CMP(SHADOW_SAMPLER);

            float4x4 _ShadowMatrix;         

            UNITY_INSTANCING_BUFFER_START(UnityPerMaterial)
                UNITY_DEFINE_INSTANCED_PROP(float4, _MainTex_ST)
                UNITY_DEFINE_INSTANCED_PROP(float4, _BaseColor)                
                UNITY_DEFINE_INSTANCED_PROP(float, _Metallic)
                UNITY_DEFINE_INSTANCED_PROP(float, _Smoothness)
            UNITY_INSTANCING_BUFFER_END(UnityPerMaterial)
            
            struct Attributes
            {
                float3 vertex : POSITION;
                float2 uv0 : TEXCOORD0;
                float3 normal : NORMAL;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct Varyings
            {
                float4 position : SV_POSITION;
                float3 positionWS : UNUSED0;
                float2 uv0 : UNUSED1;
                float3 normal : UNUSED2;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            Varyings vert(Attributes input)
            {
                Varyings output;
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_TRANSFER_INSTANCE_ID(input, output);

                output.positionWS = mul(UNITY_MATRIX_M, float4(input.vertex, 1.0)).xyz;
                output.position = mul(UNITY_MATRIX_VP, mul(UNITY_MATRIX_M, float4(input.vertex, 1.0)));
                output.uv0 = input.uv0;
                output.normal = TransformObjectToWorldNormal(input.normal);

                return output;                    
            }

            float4 frag(Varyings input) : SV_TARGET
            {          
                UNITY_SETUP_INSTANCE_ID(input);
                // return input.normal.y; 
                // return abs(length(input.normal)-1.0) * 10;                
                // // return float4(input.normal, 1.0);
                // return float4(normalize(input.normal), 1.0);
                
                Surface surface;
                surface.normal = normalize(input.normal);
                surface.viewDir = normalize(_WorldSpaceCameraPos - input.positionWS);
                float4 col = UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial, _BaseColor);
                float4 mainMap = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, input.uv0);     
                col *= mainMap;
                surface.color = col.rgb;
                surface.alpha = col.a;
                surface.metallic = UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial, _Metallic);
                surface.smoothness = UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial, _Smoothness);                                                

                BRDF brdf = GetBRDF(surface);                
                return float4(GetLighting(surface, brdf), surface.alpha) + SAMPLE_TEXTURE2D_SHADOW(_ShadowAtlas, SHADOW_SAMPLER, mul(_ShadowMatrix, input.positionWS).xyz);                      
            }

            ENDHLSL
        }

        Pass
        {
            Tags
            {
                "LightMode" = "ShadowCaster"
            }

            ColorMask 0

            HLSLPROGRAM
            #pragma target 3.5
            #pragma multi_compile_instancing
            #pragma vertex ShadowCasterVert
            #pragma fragment ShadowCasterFrag
            #include "../ShaderLibrary/ShadowCasterPass.hlsl"
            ENDHLSL
        }
    }
}
