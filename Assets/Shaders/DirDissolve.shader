Shader "ZDStudio/粒子/定向溶解"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}

		[Vector3(1)] _DissolveDir("Dissolve Direction", Vector) = (0,1,0)
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
				float worldFactor : TEXCOORD1;
            };

            sampler2D _MainTex;
			sampler2D _DissTex;
            float4 _MainTex_ST;
			float4 _DissTex_ST;
			float3 _DissolveDir;
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

				float4 worldPos = mul(unity_ObjectToWorld, v.vertex);
				float3 rootPos = float3(unity_ObjectToWorld[0].w, unity_ObjectToWorld[1].w, unity_ObjectToWorld[2].w);
				float3 pos = worldPos.rgb - rootPos;
				float posOffset = dot(normalize(_DissolveDir), pos);
				o.worldFactor = posOffset;

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv.xy);
				fixed dissove = tex2D(_DissTex, i.uv.zw).r;
				dissove = dissove + i.worldFactor * _WorldSpaceScale;

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
