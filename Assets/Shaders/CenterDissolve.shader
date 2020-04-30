Shader "ZDStudio/粒子/定点溶解"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}

		[Vector2(1)] _DissolveCenterUV("Dissolve Center UV", Vector) = (0,1,0)
		_WorldSpaceScale("World Space Dissolve Factor", float) = 0.1

		_DissTex("Dissolve Texture", 2D) = "white"{}

		_EdgeWidth("Edge Wdith", float) = 0
		[HDR]_DlvEdgeColor("Dissolve Edge Color", Color) = (0.0, 0.0, 0.0, 0)
		_Smoothness("Smoothness", Range(0.001, 1)) = 0.2

		[ScaleOffset] _DissTex_Scroll("Scroll", Vector) = (0, 0, 0, 0)

		_Clip("Clip", float) = 0
    }
    SubShader
    {
		Tags { "Queue" = "Geometry" "IgnoreProjector" = "True" "RenderType" = "Transparent" "PreviewType" = "Plane" }

        Pass
        {
			Blend SrcAlpha OneMinusSrcAlpha

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;

				float4 uv : TEXCOORD0;
            };

            sampler2D _MainTex;
			sampler2D _DissTex;
            float4 _MainTex_ST;
			float4 _DissTex_ST;
			float2 _DissolveCenterUV;
			half _Clip;
			half _WorldSpaceScale;
			half _Smoothness;
			float4 _DlvEdgeColor;
			float _EdgeWidth;

			float2 _DissTex_Scroll;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv.xy = TRANSFORM_TEX(v.uv, _MainTex);
				o.uv.zw = TRANSFORM_TEX(v.uv, _DissTex) + frac(_DissTex_Scroll.xy * _Time.x);

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv.xy);
				fixed dissove = tex2D(_DissTex, i.uv.zw).r;

				float dist = distance(_DissolveCenterUV, i.uv.xy);

				dissove = dissove + dist * _WorldSpaceScale;

				float dissolve_alpha = step(_Clip, dissove);
				clip(dissolve_alpha - 0.5);

				float edge_area = saturate(1 - saturate((dissove - _Clip - _EdgeWidth) / _Smoothness));
				edge_area *= _DlvEdgeColor.a;
				col.rgb = col.rgb * (1 - edge_area) + _DlvEdgeColor.rgb * edge_area;

                return col;
            }
            ENDCG
        }
    }
}
