Shader "PostEffect/ToneMapping"
{
	Properties
	{
		_MainTex("Texture", 2D) = "white" {}
		_Lum("Lum",float) = 0.5
	}
		SubShader
		{
			// No culling or depth
			Cull Off ZWrite Off ZTest Always

			Pass
			{
				CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag

				#include "UnityCG.cginc"
				float _MiddleGrey;
				float _Lum;
				sampler2D _MainTex;

				struct appdata
				{
					float4 vertex : POSITION;
					float2 uv : TEXCOORD0;
				};

				struct v2f
				{
					float2 uv : TEXCOORD0;
					float4 vertex : SV_POSITION;
				};
				float3 ChangeBright(float3 color,float adapted_lum)
				{
					color *= adapted_lum;
					return color;
				}
				float3 ReinhardToneMapping(float3 color,float adapted_lum)
				{
					_MiddleGrey = 1;
					color *= _MiddleGrey / adapted_lum;
					return color / (1.0f + color);
				}

				float3 CEToneMapping(float3 color, float adapted_lum)
				{
					return 1 - exp(-adapted_lum * color);
				}

				float3 ACESToneMapping(float3 color, float adapted_lum)
				{
					const float A = 2.51f;
					const float B = 0.03f;
					const float C = 2.43f;
					const float D = 0.59f;
					const float E = 0.14f;

					color *= adapted_lum;
					return (color * (A * color + B)) / (color * (C * color + D) + E);
				}

				v2f vert(appdata v)
				{
					v2f o;
					o.vertex = UnityObjectToClipPos(v.vertex);
					o.uv = v.uv;
					return o;
				}



				fixed4 frag(v2f i) : SV_Target
				{
					fixed4 col = tex2D(_MainTex, i.uv);
				col.rgb = ChangeBright(col.rgb, _Lum);
				return col;
			}
			ENDCG
		}
		}
}
