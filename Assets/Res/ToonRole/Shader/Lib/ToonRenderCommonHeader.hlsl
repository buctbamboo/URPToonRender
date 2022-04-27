#pragma once

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

#include "OutlineUtil.hlsl"

struct Attributes
{
    float3 positionOS   : POSITION;
    half3 normalOS      : NORMAL;
    half4 tangentOS     : TANGENT;
    float2 uv           : TEXCOORD0;
};

struct Varyings
{
    float2 uv                       : TEXCOORD0;
    float4 positionWSAndFogFactor   : TEXCOORD1; // xyz: positionWS, w: vertex fog factor
    half3 normalWS                  : TEXCOORD2;
    float4 positionCS               : SV_POSITION;
};

struct ToonSurfaceData
{
    half3   albedo;
    half    alpha;
    half3   emission;
    half    occlusion;
};

struct ToonLightingData
{
    half3   normalWS;
    float3  positionWS;
    half3   viewDirectionWS;
    float4  shadowCoord;
};

sampler2D _BaseMap;

CBUFFER_START(UnityPerMaterial)
    // base color
    float4  _BaseMap_ST;
    half4   _BaseColor;

    // outline
    float   _OutlineWidth;
    half4   _OutlineColor;
CBUFFER_END

/* Outline Function */
float3 TransformPositionWSToOutlinePositionWS(float3 positionWS, float positionVS_Z, float3 normalWS)
{
    float outlineExpandAmount = _OutlineWidth * 0.1;
    return positionWS + normalWS * outlineExpandAmount; 
}

half4 ConvertSurfaceColorToOutlineColor(half4 originalSurfaceColor)
{
    return originalSurfaceColor * _OutlineColor;
}
/* ================= */

Varyings VertexShaderWork(Attributes input)
{
    Varyings output;
    VertexPositionInputs vertexInput = GetVertexPositionInputs(input.positionOS);
    VertexNormalInputs vertexNormalInput = GetVertexNormalInputs(input.normalOS, input.tangentOS);

    float3 positionWS = vertexInput.positionWS;
#ifdef ToonShaderIsOutline
    positionWS = TransformPositionWSToOutlinePositionWS(vertexInput.positionWS, vertexInput.positionVS.z, vertexNormalInput.normalWS);
#endif

    output.uv = TRANSFORM_TEX(input.uv,_BaseMap);
    output.normalWS = vertexNormalInput.normalWS;
    output.positionCS = TransformWorldToHClip(positionWS);

    return output;
}

half4 GetFinalBaseColor(Varyings input)
{
    return tex2D(_BaseMap, input.uv) * _BaseColor;
}

half4 FragShaderColor(Varyings input) : SV_TARGET
{
    half4 baseColor = GetFinalBaseColor(input);

#ifdef ToonShaderIsOutline
    baseColor = ConvertSurfaceColorToOutlineColor(baseColor);
#endif

    return baseColor;
}