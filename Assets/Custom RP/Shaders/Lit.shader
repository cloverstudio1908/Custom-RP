Shader "Custom RP/Lit"
{
    Properties
    {
        _MainTex ("Main Texture", 2D) = "white" {}
        _BaseColor ("Base Color", Color) = (0.5,0.5,0.5,1)    
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
                surface.color = UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial, _BaseColor);
                surface.metallic = UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial, _Metallic);
                surface.smoothness = UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial, _Smoothness);                                

                BRDF brdf = GetBRDF(surface);                
                return float4(GetLighting(surface, brdf), 1);                      
            }

            ENDHLSL
        }
    }
}
