Shader "URPToon/URPToonShader"
{
    Properties
    {
        [Header(Base Color)]
        [MainTexture]_BaseMap("_BaseMap (Albedo)", 2D) = "white" {}
        [HDR][MainColor]_BaseColor("_BaseColor", Color) = (1,1,1,1)

        [Header(Outline)]
        _OutlineWidth("_OutlineWidth (World Space)", Range(0,1)) = 1
        _OutlineColor("_OutlineColor", Color) = (0.5,0.5,0.5,1)
    }

    SubShader
    {
        Tags
        {
            "RenderPipeline" = "UniversalPipeline"
            "RenderType"="Opaque"
            "Queue"="Geometry"
        }

        Pass
        {
            Name "ForwardLit"
            Tags
            {
                "LightMode" = "UniversalForward"
            }

            Cull Back
            ZTest LEqual
            ZWrite On
            Blend One Zero

            HLSLPROGRAM
            #pragma vertex VertexShaderWork
            #pragma fragment FragShaderColor

            #include "Lib/ToonRenderCommonHeader.hlsl"
            ENDHLSL
        }

        Pass
        {
            Name "Outline"

            Tags 
            {
                "LightMode" = "SRPDefaultUnlit"
            }

            Cull Front

            HLSLPROGRAM
            #pragma vertex VertexShaderWork
            #pragma fragment FragShaderColor

            #define ToonShaderIsOutline
            #include "Lib/ToonRenderCommonHeader.hlsl"
            ENDHLSL
        }
    }
}