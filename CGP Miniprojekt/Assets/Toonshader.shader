Shader "Unlit/ToonShader"
{
 Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Brightness("Brightness",Range(0,1)) = 0.1
        _Strength("Strenght", Range(0,1)) = 0.5
        _Color("Color", COLOR) = (1,1,1,1)
        _Detail("Detail", Range(0,1)) = 0.3
        _outlineColor("OutlineColor",Color) = (0,0,0,1)
        _outlineThickness("OutlineThickness", Range(0.0,0.3)) = 0.15
    }
    SubShader
    {
       


         Pass
        {
            Tags {"Queue" = "Transparent"}
            //Blend SrcAlpha OneMinusSrcAlpha
            Zwrite Off
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
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

             float4 outline(float4 vPos, float outlineval)
            {
                float4x4 Scale = float4x4
                (
                    1 + outlineval,0,0,0,
                    0,1 + outlineval,0,0,
                    0,0,1 + outlineval,0,
                    0,0,0,1 + outlineval);
                    return mul(Scale,vPos);
            }

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _outlineThickness;
            float _outlineColor;

            v2f vert (appdata v)
            {
                v2f o;
                float4 vPos = outline(v.vertex, _outlineThickness);
                o.vertex = UnityObjectToClipPos(vPos);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                
                
                return o;
            }

            

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);
                return _outlineColor;
            }
            ENDCG
        }
        
        Pass
        {
            Tags { "Queue" = "Transparent+1"}
            Blend SrcAlpha OneMinusSrcAlpha
            LOD 100
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            
      

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
                float4 uv1 : TEXCOORD1;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float3 worldNormal : NORMAL;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _Brightness;
            float _Strength;
            float4 _Color;
            float _Detail;
            

            float Toon(float3 normal, float3 lightDir)
            {
                float NdotL = max(0.0,dot(normalize(normal), normalize(lightDir)));

                return floor(NdotL/_Detail);

            }

           

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
              
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);
                col *= Toon(i.worldNormal, _WorldSpaceLightPos0.xyz) *_Strength *_Color +_Brightness;
                return col;
            }
            ENDCG
        }
    }
}

