// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

////////////////////////////////////////////
// CameraFilterPack - by VETASOFT 2017 /////
////////////////////////////////////////////

Shader "CameraFilterPack/Blend2Camera_Luminosity" { 
Properties 
{
_MainTex ("Base (RGB)", 2D) = "white" {}
_MainTex2 ("Base (RGB)", 2D) = "white" {}
_TimeX ("Time", Range(0.0, 1.0)) = 1.0
_ScreenResolution ("_ScreenResolution", Vector) = (0.,0.,0.,0.)
}
SubShader
{
Pass
{
Cull Off ZWrite Off ZTest Always
CGPROGRAM
#pragma vertex vert
#pragma fragment frag
#pragma fragmentoption ARB_precision_hint_fastest
#pragma target 3.0
#pragma glsl
#include "UnityCG.cginc"
uniform sampler2D _MainTex;
uniform sampler2D _MainTex2;
uniform float _TimeX;
uniform float _Value;
uniform float _Value2;
uniform float4 _ScreenResolution;
uniform float2 _MainTex_TexelSize;
struct appdata_t
{
float4 vertex   : POSITION;
float4 color    : COLOR;
float2 texcoord : TEXCOORD0;
};
struct v2f
{
float2 texcoord  : TEXCOORD0;
float4 vertex   : SV_POSITION;
float4 color    : COLOR;
};
v2f vert(appdata_t IN)
{
v2f OUT;
OUT.vertex = UnityObjectToClipPos(IN.vertex);
OUT.texcoord = IN.texcoord;
OUT.color = IN.color;
return OUT;
}
float3 luminosity( float3 s, float3 d )
{
float dLum = dot(d, float3(0.3, 0.59, 0.11));
float sLum = dot(s, float3(0.3, 0.59, 0.11));
float lum = sLum - dLum;
float3 c = d + lum;
float minC = min(min(c.x, c.y), c.z);
float maxC = max(max(c.x, c.y), c.z);
if(minC < 0.0) return sLum + ((c - sLum) * sLum) / (sLum - minC);
else if(maxC > 1.0) return sLum + ((c - sLum) * (1.0 - sLum)) / (maxC - sLum);
else return c;
}

half4 _MainTex_ST;
float4 frag(v2f i) : COLOR
{
float2 uvst = UnityStereoScreenSpaceUVAdjust(i.texcoord, _MainTex_ST);
float2 uv=uvst.xy;

float4 tex = tex2D(_MainTex,uv);    
#if UNITY_UV_STARTS_AT_TOP
if (_MainTex_TexelSize.y < 0)
uv.y = 1-uv.y;
#endif
float4 tex2 = tex2D(_MainTex2,uv);
float3 S1=lerp(tex.rgb,tex2.rgb,_Value2);
float3 S2=lerp(tex.rgb,tex2.rgb,1-_Value2);
S1=lerp(S1,luminosity(S1,S2),_Value);
return  float4(S1,1.0);
}
ENDCG
}
}
}
