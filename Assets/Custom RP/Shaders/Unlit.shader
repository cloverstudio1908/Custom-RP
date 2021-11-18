Shader "Custom RP/Unlit"
{
    Properties
    {        
        _BaseColor ("Base Color", Color) = (1,1,1,1)
        _MainTex ("Main Texture", 2D) = "white" {}
    }
        SubShader
    {
        Tags { "RenderType" = "Opaque" }
        LOD 100

        Pass
        {
            HLSLPROGRAM        
            #pragma target 3.5                
            
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Common.hlsl"
            
            CBUFFER_START(UnityPerDraw)
                float4x4 unity_ObjectToWorld;
                float4x4 unity_WorldToObject;
                float4 unity_LODFade;
                real4 unity_WorldTransformParams;                
            CBUFFER_END
            
            float4x4 unity_MatrixV;
            float4x4 unity_MatrixVP;
            float4x4 glstate_matrix_projection;               

            #define UNITY_MATRIX_M unity_ObjectToWorld
            #define UNITY_MATRIX_I_M unity_WorldToObject
            #define UNITY_MATRIX_V unity_MatrixV
            #define UNITY_MATRIX_VP unity_MatrixVP
            #define UNITY_MATRIX_P glstate_matrix_projection                        
               
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/UnityInstancing.hlsl"            

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
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct Varying
            {
                float4 position : SV_POSITION;
                float2 uv0 : _UNUSED;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            Varying vert(Attributes input)
            {
                Varying output;
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_TRANSFER_INSTANCE_ID(input, output);
                
                output.position = mul(UNITY_MATRIX_VP, mul(UNITY_MATRIX_M, float4(input.vertex,1.0)));    
                float4 st = UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial, _MainTex_ST);                      
                output.uv0 = input.uv0 * st.xy + st.zw;

                return output;
            }

            float4 frag(Varying input) : SV_Target
            {
                UNITY_SETUP_INSTANCE_ID(input);
                float4 col = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, input.uv0);
                return UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial, _BaseColor) * col;
            }
            ENDHLSL
        }
    }
}
