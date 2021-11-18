Shader "Custom RP/Lit"
{
    Properties
    {
        _MainTex ("Main Texture", 2D) = "white" {}
        _BaseColor ("Base Color", Color) = (0.5,0.5,0.5,1)        
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

            #include "../ShaderLibrary/UnityInput.hlsl"
            #include "../ShaderLibrary/Surface.hlsl"
            #include "../ShaderLibrary/Light.hlsl"
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
                float2 uv0 : UNUSED0;
                float3 normal : UNUSED1;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            Varyings vert(Attributes input)
            {
                Varyings output;
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_TRANSFER_INSTANCE_ID(input, output);

                output.position = mul(UNITY_MATRIX_VP, mul(UNITY_MATRIX_M, float4(input.vertex,1.0)));
                output.uv0 = input.uv0;
                output.normal = TransformObjectToWorldNormal(input.normal);

                return output;                    
            }

            float4 frag(Varyings input) : SV_TARGET
            {          
                // return input.normal.y; 
                // return abs(length(input.normal)-1.0) * 10;                
                // // return float4(input.normal, 1.0);
                // return float4(normalize(input.normal), 1.0);
                
                Surface surface;
                surface.normal = normalize(input.normal);
                surface.color = _BaseColor;

                return float4(GetLighting(surface), 1);                      
            }

            ENDHLSL
        }
    }
}
