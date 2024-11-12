Shader "Unlit/SleepSphere"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Color1("Color1", Color) = (1, 1, 1, 1)
        _Color2("Color2", Color) = (0, 0, 0, 1)
    }
    SubShader
    {
        Tags { "Queue" = "Geometry+1100" "RenderType"="Opaque" }
        LOD 100
        Cull Front
        ZTest Greater
        ZWrite Off
        GrabPass{}

        Pass
        {
            Stencil{
                Ref 64
                Comp always
                Pass replace
            }
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 screenPos : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

            sampler2D _GrabTexture;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.screenPos = ComputeGrabScreenPos(o.vertex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            { 
                half2 grabUV = (i.screenPos.xy / i.screenPos.w);
                fixed4 col = tex2D(_GrabTexture, grabUV);
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
              ENDCG
        }

            ZTest LEqual
            ZWrite On
            Cull Back

        Pass
        {
            Stencil{
                Ref 64
                Comp Equal
            }
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            fixed4 _Color1;

            struct v2f
            {
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

            v2f vert(appdata v)
            {
              v2f o;
              o.vertex = UnityObjectToClipPos(v.vertex);
              UNITY_TRANSFER_FOG(o, o.vertex);
              return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                return _Color1;
            }
            ENDCG
        }
        ZTest Less
        Pass
        {
            Stencil{
                Ref 64
                Comp NotEqual
            }
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            fixed4 _Color2;

            struct v2f
            {
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

            v2f vert(appdata v)
            {
              v2f o;
              o.vertex = UnityObjectToClipPos(v.vertex);
              UNITY_TRANSFER_FOG(o, o.vertex);
              return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                return _Color2;
            }
            ENDCG
        }
    }
}
