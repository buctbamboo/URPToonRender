Shader "LearnUnlit/BodyShader"
{
    Properties
    {
        _MainTex("MainTex", 2D) = "white" {}
        _NormalTex("NormalTex", 2D) = "bump" {}
        _OutlineColor("Outline Color", Color) = (1, 1, 1, 1)
        _Outline("Outline", Range(0,1)) = 0.1
        
    }
    
    SubShader
    {
        Pass
        {
            Name "UniversalForward"
            Tags { "RenderType" = "Opaque" "RenderPipeline" = "UniversalRenderPipeline" "LightMode" = "UniversalForward"}
            Cull Back

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            struct Atributes
            {
                float4 positionOS : POSITION;
                float2 uv : TEXCOORD0;

            };

            struct Varyings
            {
                float4 positionHCS  : SV_POSITION;
                float2 uv : TEXCOORD0;

                //世界空间顶点
				float3 positionWS :  TEXCOORD1;
				//世界空间法线
				float3 normalWS : TEXCOORD2;
				//世界空间切线
				float3 tangentWS : TEXCOORD3;
				//世界空间副切线
				float3 bitangentWS : TEXCOORD4;
            };

            TEXTURE2D(_MainTex);
            SAMPLER(sampler_MainTex);
            TEXTURE2D(_NormalTex);
            SAMPLER(sampler_NormalTex);
            CBUFFER_START(UnityPerMaterial)
                float4 _MainTex_ST;
            CBUFFER_END

            Varyings vert(Atributes IN)
            {
                Varyings OUT = (Varyings)0;
                OUT.positionHCS = TransformObjectToHClip(IN.positionOS.xyz);
                
                
                
                OUT.uv = TRANSFORM_TEX(IN.uv, _MainTex);
                return OUT;
           }

           float4 frag(Varyings IN) : SV_Target
           {
                float4 color = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, IN.uv);
                //float4 normalTXS = SAMPLE_TEXTURE2D(_NormalTex, sampler_NormalTex, IN.uv);
                //float3 normalTS = UnpackNormalScale(normalTXS, 1);
                //half3 normalWS = TransformTangentToWorld(normalTS, float3x3(IN.tangentWS, iIN.bitangentWS, IN.normalWS));
                return color;
           }
           ENDHLSL
        }

        Pass
        {
            Name "SRPDefaultUnlit"
            Tags { "RenderType" = "Opaque" "RenderPipeline" = "UniversalRenderPipeline" "LightMode" = "SRPDefaultUnlit"}
            Cull Front

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            struct Atributes
            {
                float4 positionOS : POSITION;
                float3 normalOS : NORMAL;
                float4 tangentOS  : TANGENT;
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float2 uv : TEXCOORD0;
            };

            CBUFFER_START(UnityPerMaterial)
                float4 _OutlineColor;
                float _Outline;
            CBUFFER_END

            Varyings vert(Atributes input)
            {
                Varyings o = (Varyings)0;
                VertexPositionInputs vertexInput = GetVertexPositionInputs(input.positionOS);
                VertexNormalInputs normalInputs = GetVertexNormalInputs(input.normalOS, input.tangentOS);
                float3 positionWS = vertexInput.positionWS;


                positionWS += normalInputs.normalWS * _Outline * 0.1;

                o.positionCS = TransformWorldToHClip(positionWS);
               return o;
           }

           float4 frag(Varyings i) : SV_Target
           {
               return _OutlineColor;
           }
           ENDHLSL
       }
    }
}
