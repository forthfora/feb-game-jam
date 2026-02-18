Shader "Custom/PastReveal"
{
    Properties
    {
        [NoScaleOffset]_MainTex("Sprite Texture", 2D) = "white" {}
        _TorchNoiseStrength("Torch Noise Strength", Float) = 0.3
        _Noise_Scale("Noise Scale", Float) = 19.49
        _Noise_Speed("Noise Speed", Float) = 0.2
        _Threshold("Threshold", Float) = 0
        _Warp_Strength("Warp Strength", Float) = 0.1
        _Warp_Scale("Warp Scale", Float) = 10
        _Abberation_Intensity("Abberation Intensity", Float) = 0
        _Cutoff("Cutoff", Float) = 1.2
        [HideInInspector]White("Color", Color) = (1, 1, 1, 1)
        [HideInInspector][NoScaleOffset]unity_Lightmaps("unity_Lightmaps", 2DArray) = "" {}
        [HideInInspector][NoScaleOffset]unity_LightmapsInd("unity_LightmapsInd", 2DArray) = "" {}
        [HideInInspector][NoScaleOffset]unity_ShadowMasks("unity_ShadowMasks", 2DArray) = "" {}
    }
    SubShader
    {
        Tags
        {
            "RenderPipeline"="UniversalPipeline"
            "RenderType"="Transparent"
            "UniversalMaterialType" = "Unlit"
            "Queue"="Transparent"
            // DisableBatching: <None>
            "ShaderGraphShader"="true"
            "ShaderGraphTargetId"="UniversalSpriteUnlitSubTarget"
        }
        Pass
        {
            Name "Sprite Unlit"
            Tags
            {
                "LightMode" = "Universal2D"
            }
            
            Stencil
            {
                Ref 1
                Comp Always
                Pass Replace
            }
        
        // Render State
        Cull Off
        Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
        ZTest LEqual
        ZTest LEqual
        ZTest LEqual
        ZTest LEqual
        ZTest LEqual
        ZTest LEqual
        ZTest LEqual
        ZTest LEqual
        ZTest LEqual
        ZTest LEqual
        ZWrite Off
        ZWrite Off
        ZWrite Off
        ZWrite Off
        ZWrite Off
        ZWrite On
        ZWrite On
        ZWrite On
        ZWrite Off
        ZWrite Off
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 2.0
        #pragma exclude_renderers d3d11_9x
        #pragma multi_compile_instancing
        #pragma vertex vert
        #pragma fragment frag
        
        // Keywords
        #pragma multi_compile_fragment _ DEBUG_DISPLAY
        #pragma multi_compile_vertex _ SKINNED_SPRITE
        // GraphKeywords: <None>
        
        // Defines
        
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define ATTRIBUTES_NEED_COLOR
        #define FEATURES_GRAPH_VERTEX_NORMAL_OUTPUT
        #define FEATURES_GRAPH_VERTEX_TANGENT_OUTPUT
        #define VARYINGS_NEED_POSITION_WS
        #define VARYINGS_NEED_NORMAL_WS
        #define VARYINGS_NEED_TEXCOORD0
        #define VARYINGS_NEED_COLOR
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_SPRITEUNLIT
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Fog.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/DebugMipmapStreamingMacros.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Shaders/2D/Include/Core2D.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv0 : TEXCOORD0;
             float4 color : COLOR;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(ATTRIBUTES_NEED_INSTANCEID)
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 positionWS;
             float3 normalWS;
             float4 texCoord0;
             float4 color;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float3 WorldSpacePosition;
             float4 uv0;
             float3 TimeParameters;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float4 texCoord0 : INTERP0;
             float4 color : INTERP1;
             float3 positionWS : INTERP2;
             float3 normalWS : INTERP3;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.texCoord0.xyzw = input.texCoord0;
            output.color.xyzw = input.color;
            output.positionWS.xyz = input.positionWS;
            output.normalWS.xyz = input.normalWS;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.texCoord0 = input.texCoord0.xyzw;
            output.color = input.color.xyzw;
            output.positionWS = input.positionWS.xyz;
            output.normalWS = input.normalWS.xyz;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _MainTex_TexelSize;
        float _Noise_Scale;
        float _TorchNoiseStrength;
        float _Noise_Speed;
        float _Threshold;
        float _Warp_Strength;
        float _Warp_Scale;
        float _Abberation_Intensity;
        float _Cutoff;
        UNITY_TEXTURE_STREAMING_DEBUG_VARS;
        CBUFFER_END
        
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_MainTex);
        SAMPLER(sampler_MainTex);
        float2 _TorchWorldPos;
        float2 _TorchPointDir;
        float _ConeAngle;
        float _TorchEnabled;
        
        // Graph Includes
        #include_with_pragmas "Packages/com.jimmycushnie.noisynodes/NoiseShader/HLSL/Voronoi3D.hlsl"
        #include_with_pragmas "Packages/com.jimmycushnie.noisynodes/NoiseShader/HLSL/SimplexNoise3D.hlsl"
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Subtract_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A - B;
        }
        
        void Unity_Length_float4(float4 In, out float Out)
        {
            Out = length(In);
        }
        
        void Unity_Step_float(float Edge, float In, out float Out)
        {
            Out = step(Edge, In);
        }
        
        void Unity_Subtract_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A - B;
        }
        
        void Unity_DotProduct_float2(float2 A, float2 B, out float Out)
        {
            Out = dot(A, B);
        }
        
        void Unity_Length_float2(float2 In, out float Out)
        {
            Out = length(In);
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }
        
        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }
        
        void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }
        
        struct Bindings_Voronoinoise3D_92001a1a051ec8247a12e151ca32427b_float
        {
        };
        
        void SG_Voronoinoise3D_92001a1a051ec8247a12e151ca32427b_float(float3 Vector3_375394F7, float Vector1_B47BD908, float Vector1_AEE7F28E, Bindings_Voronoinoise3D_92001a1a051ec8247a12e151ca32427b_float IN, out float Value_1, out float Cells_2)
        {
        float3 _Property_c0874fd2920f9c8baf4b91be875c7ebb_Out_0_Vector3 = Vector3_375394F7;
        float _Property_1d30cf63fc420f8f99a0cbe60bb88392_Out_0_Float = Vector1_B47BD908;
        float _Property_01df2bf4a6ebe48c8c34049cb8b5c130_Out_0_Float = Vector1_AEE7F28E;
        float _Voronoi3DCustomFunction_f3778cac851e5b82b5979141914b8445_Value_3_Float;
        float _Voronoi3DCustomFunction_f3778cac851e5b82b5979141914b8445_Cells_4_Float;
        Voronoi3D_float(_Property_c0874fd2920f9c8baf4b91be875c7ebb_Out_0_Vector3, _Property_1d30cf63fc420f8f99a0cbe60bb88392_Out_0_Float, _Property_01df2bf4a6ebe48c8c34049cb8b5c130_Out_0_Float, _Voronoi3DCustomFunction_f3778cac851e5b82b5979141914b8445_Value_3_Float, _Voronoi3DCustomFunction_f3778cac851e5b82b5979141914b8445_Cells_4_Float);
        Value_1 = _Voronoi3DCustomFunction_f3778cac851e5b82b5979141914b8445_Value_3_Float;
        Cells_2 = _Voronoi3DCustomFunction_f3778cac851e5b82b5979141914b8445_Cells_4_Float;
        }
        
        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
        }
        
        void Unity_Multiply_float3_float3(float3 A, float3 B, out float3 Out)
        {
        Out = A * B;
        }
        
        struct Bindings_Simplexnoise3D_b3b7f0d9d78bece4587dc8496c4ed47b_float
        {
        };
        
        void SG_Simplexnoise3D_b3b7f0d9d78bece4587dc8496c4ed47b_float(float3 Vector3_7940555B, float Vector1_D4A5C52D, Bindings_Simplexnoise3D_b3b7f0d9d78bece4587dc8496c4ed47b_float IN, out float Value_0)
        {
        float3 _Property_44999cc87708de82a26b39ae1da975ec_Out_0_Vector3 = Vector3_7940555B;
        float _Property_31805413f7564f8da25bf75c2a6983b0_Out_0_Float = Vector1_D4A5C52D;
        float3 _Multiply_1d17f1db9ddb2d8481679237f2442ac2_Out_2_Vector3;
        Unity_Multiply_float3_float3(_Property_44999cc87708de82a26b39ae1da975ec_Out_0_Vector3, (_Property_31805413f7564f8da25bf75c2a6983b0_Out_0_Float.xxx), _Multiply_1d17f1db9ddb2d8481679237f2442ac2_Out_2_Vector3);
        float _SimplexNoise3DCustomFunction_1d714aea6ba122808f5efcabfce18252_Out_1_Float;
        SimplexNoise3D_float(_Multiply_1d17f1db9ddb2d8481679237f2442ac2_Out_2_Vector3, _SimplexNoise3DCustomFunction_1d714aea6ba122808f5efcabfce18252_Out_1_Float);
        float _Remap_4e5d05a6e861b582b5e910962a3ffd60_Out_3_Float;
        Unity_Remap_float(_SimplexNoise3DCustomFunction_1d714aea6ba122808f5efcabfce18252_Out_1_Float, float2 (-1, 1), float2 (0, 1), _Remap_4e5d05a6e861b582b5e910962a3ffd60_Out_3_Float);
        Value_0 = _Remap_4e5d05a6e861b582b5e910962a3ffd60_Out_3_Float;
        }
        
        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }
        
        void Unity_Comparison_Greater_float(float A, float B, out float Out)
        {
            Out = A > B ? 1 : 0;
        }
        
        void Unity_And_float(float A, float B, out float Out)
        {
            Out = A && B;
        }
        
        void Unity_Branch_float(float Predicate, float True, float False, out float Out)
        {
            Out = Predicate ? True : False;
        }
        
        void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float3 BaseColor;
            float Alpha;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            UnityTexture2D _Property_9da0b2bc8c884590abd2996a28f14783_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_MainTex);
            float4 _SampleTexture2D_f271227fcd0e4b51a6327802cec29d72_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_9da0b2bc8c884590abd2996a28f14783_Out_0_Texture2D.tex, _Property_9da0b2bc8c884590abd2996a28f14783_Out_0_Texture2D.samplerstate, _Property_9da0b2bc8c884590abd2996a28f14783_Out_0_Texture2D.GetTransformedUV(IN.uv0.xy) );
            float _SampleTexture2D_f271227fcd0e4b51a6327802cec29d72_R_4_Float = _SampleTexture2D_f271227fcd0e4b51a6327802cec29d72_RGBA_0_Vector4.r;
            float _SampleTexture2D_f271227fcd0e4b51a6327802cec29d72_G_5_Float = _SampleTexture2D_f271227fcd0e4b51a6327802cec29d72_RGBA_0_Vector4.g;
            float _SampleTexture2D_f271227fcd0e4b51a6327802cec29d72_B_6_Float = _SampleTexture2D_f271227fcd0e4b51a6327802cec29d72_RGBA_0_Vector4.b;
            float _SampleTexture2D_f271227fcd0e4b51a6327802cec29d72_A_7_Float = _SampleTexture2D_f271227fcd0e4b51a6327802cec29d72_RGBA_0_Vector4.a;
            float _Property_2a75182591204a34887f8c0852a6d7c5_Out_0_Boolean = _TorchEnabled;
            float _Property_b235dec23c7244ee96802a2291b1ecd2_Out_0_Float = _Cutoff;
            float4 _UV_44cb21489bee4382b69b741257b9b83c_Out_0_Vector4 = IN.uv0;
            float4 _Subtract_2437e7a503d248449d7aa4baa1aeda12_Out_2_Vector4;
            Unity_Subtract_float4(_UV_44cb21489bee4382b69b741257b9b83c_Out_0_Vector4, float4(0.5, 0.5, 1, 1), _Subtract_2437e7a503d248449d7aa4baa1aeda12_Out_2_Vector4);
            float _Length_e1f9513bf75a4e9e9dbeeed7c69964b1_Out_1_Float;
            Unity_Length_float4(_Subtract_2437e7a503d248449d7aa4baa1aeda12_Out_2_Vector4, _Length_e1f9513bf75a4e9e9dbeeed7c69964b1_Out_1_Float);
            float _Step_7c5418391b9c49248e4bc367843fa597_Out_2_Float;
            Unity_Step_float(_Property_b235dec23c7244ee96802a2291b1ecd2_Out_0_Float, _Length_e1f9513bf75a4e9e9dbeeed7c69964b1_Out_1_Float, _Step_7c5418391b9c49248e4bc367843fa597_Out_2_Float);
            float2 _Property_7033a961d17048b0ab681ea9a8de15dd_Out_0_Vector2 = _TorchWorldPos;
            float2 _Subtract_53cbbd021eb04323905291953ce2bf0b_Out_2_Vector2;
            Unity_Subtract_float2((IN.WorldSpacePosition.xy), _Property_7033a961d17048b0ab681ea9a8de15dd_Out_0_Vector2, _Subtract_53cbbd021eb04323905291953ce2bf0b_Out_2_Vector2);
            float2 _Property_3f205fc181f74ccbb4158016995d0d6f_Out_0_Vector2 = _TorchPointDir;
            float _DotProduct_98b628519f13442ca29c540730032133_Out_2_Float;
            Unity_DotProduct_float2(_Subtract_53cbbd021eb04323905291953ce2bf0b_Out_2_Vector2, _Property_3f205fc181f74ccbb4158016995d0d6f_Out_0_Vector2, _DotProduct_98b628519f13442ca29c540730032133_Out_2_Float);
            float _Length_9d91b71764ca46d5a6d4f0cfa754d2bb_Out_1_Float;
            Unity_Length_float2(_Subtract_53cbbd021eb04323905291953ce2bf0b_Out_2_Vector2, _Length_9d91b71764ca46d5a6d4f0cfa754d2bb_Out_1_Float);
            float _Length_9a332ec75df64ba992de1c2b3dd39e3a_Out_1_Float;
            Unity_Length_float2(_Property_3f205fc181f74ccbb4158016995d0d6f_Out_0_Vector2, _Length_9a332ec75df64ba992de1c2b3dd39e3a_Out_1_Float);
            float _Multiply_24b3d100c67d40a693a4182ef01451ee_Out_2_Float;
            Unity_Multiply_float_float(_Length_9d91b71764ca46d5a6d4f0cfa754d2bb_Out_1_Float, _Length_9a332ec75df64ba992de1c2b3dd39e3a_Out_1_Float, _Multiply_24b3d100c67d40a693a4182ef01451ee_Out_2_Float);
            float _Divide_a91708cba40243e08d4219249db86c65_Out_2_Float;
            Unity_Divide_float(_DotProduct_98b628519f13442ca29c540730032133_Out_2_Float, _Multiply_24b3d100c67d40a693a4182ef01451ee_Out_2_Float, _Divide_a91708cba40243e08d4219249db86c65_Out_2_Float);
            float _Property_7e8351790b1945e3bedb4ed0ce5af20e_Out_0_Float = _ConeAngle;
            float _Property_7e4150e0dd7b4a15b2c7c9d48cbe0987_Out_0_Float = _ConeAngle;
            float _Add_12bf6727cd124131a5ac7e2844aea423_Out_2_Float;
            Unity_Add_float(_Property_7e4150e0dd7b4a15b2c7c9d48cbe0987_Out_0_Float, float(0.1), _Add_12bf6727cd124131a5ac7e2844aea423_Out_2_Float);
            float2 _Vector2_10b46480a0894d3b998ae1fa779a5ff4_Out_0_Vector2 = float2(_Property_7e8351790b1945e3bedb4ed0ce5af20e_Out_0_Float, _Add_12bf6727cd124131a5ac7e2844aea423_Out_2_Float);
            float _Remap_724e812769644b63a2060d37e7afbdae_Out_3_Float;
            Unity_Remap_float(_Divide_a91708cba40243e08d4219249db86c65_Out_2_Float, _Vector2_10b46480a0894d3b998ae1fa779a5ff4_Out_0_Vector2, float2 (0, 1), _Remap_724e812769644b63a2060d37e7afbdae_Out_3_Float);
            float _Multiply_69a6ec8992034d6794dc6830d8797195_Out_2_Float;
            Unity_Multiply_float_float(_Step_7c5418391b9c49248e4bc367843fa597_Out_2_Float, _Remap_724e812769644b63a2060d37e7afbdae_Out_3_Float, _Multiply_69a6ec8992034d6794dc6830d8797195_Out_2_Float);
            float _Property_dfa3069e428d48c2a00288fb727d87aa_Out_0_Float = _TorchNoiseStrength;
            float _Split_73f51655f05748e9bafdfa82c53a6756_R_1_Float = IN.WorldSpacePosition[0];
            float _Split_73f51655f05748e9bafdfa82c53a6756_G_2_Float = IN.WorldSpacePosition[1];
            float _Split_73f51655f05748e9bafdfa82c53a6756_B_3_Float = IN.WorldSpacePosition[2];
            float _Split_73f51655f05748e9bafdfa82c53a6756_A_4_Float = 0;
            float _Property_2af28184bb9342ae91b1f54e7e73c995_Out_0_Float = _Noise_Speed;
            float _Multiply_ac67735ad1e642988ed3ce9b37d72d0a_Out_2_Float;
            Unity_Multiply_float_float(_Property_2af28184bb9342ae91b1f54e7e73c995_Out_0_Float, IN.TimeParameters.x, _Multiply_ac67735ad1e642988ed3ce9b37d72d0a_Out_2_Float);
            float3 _Vector3_1b110a8e5c6d410db18c670e3000b981_Out_0_Vector3 = float3(_Split_73f51655f05748e9bafdfa82c53a6756_R_1_Float, _Split_73f51655f05748e9bafdfa82c53a6756_G_2_Float, _Multiply_ac67735ad1e642988ed3ce9b37d72d0a_Out_2_Float);
            float _Property_e46a47d2ad964f1991ec5f4f47ba0e4c_Out_0_Float = _Warp_Scale;
            Bindings_Voronoinoise3D_92001a1a051ec8247a12e151ca32427b_float _Voronoinoise3D_de2a85142ed344d0a735380b5b3964b9;
            float _Voronoinoise3D_de2a85142ed344d0a735380b5b3964b9_Value_1_Float;
            float _Voronoinoise3D_de2a85142ed344d0a735380b5b3964b9_Cells_2_Float;
            SG_Voronoinoise3D_92001a1a051ec8247a12e151ca32427b_float(_Vector3_1b110a8e5c6d410db18c670e3000b981_Out_0_Vector3, float(10), _Property_e46a47d2ad964f1991ec5f4f47ba0e4c_Out_0_Float, _Voronoinoise3D_de2a85142ed344d0a735380b5b3964b9, _Voronoinoise3D_de2a85142ed344d0a735380b5b3964b9_Value_1_Float, _Voronoinoise3D_de2a85142ed344d0a735380b5b3964b9_Cells_2_Float);
            float _Property_2ae067af17f5451e8839bd295fd143da_Out_0_Float = _Warp_Strength;
            float _Multiply_a138b9bfcd6b4aafa72ec02a7e70affc_Out_2_Float;
            Unity_Multiply_float_float(_Voronoinoise3D_de2a85142ed344d0a735380b5b3964b9_Value_1_Float, _Property_2ae067af17f5451e8839bd295fd143da_Out_0_Float, _Multiply_a138b9bfcd6b4aafa72ec02a7e70affc_Out_2_Float);
            float3 _Add_5657652b57de46d59a3acf09df734a88_Out_2_Vector3;
            Unity_Add_float3(_Vector3_1b110a8e5c6d410db18c670e3000b981_Out_0_Vector3, (_Multiply_a138b9bfcd6b4aafa72ec02a7e70affc_Out_2_Float.xxx), _Add_5657652b57de46d59a3acf09df734a88_Out_2_Vector3);
            float _Property_47bf2f5b46d344768eedf93a37be6926_Out_0_Float = _Noise_Scale;
            Bindings_Simplexnoise3D_b3b7f0d9d78bece4587dc8496c4ed47b_float _Simplexnoise3D_22a26c000d084fac88791e2e272a3627;
            float _Simplexnoise3D_22a26c000d084fac88791e2e272a3627_Value_0_Float;
            SG_Simplexnoise3D_b3b7f0d9d78bece4587dc8496c4ed47b_float(_Add_5657652b57de46d59a3acf09df734a88_Out_2_Vector3, _Property_47bf2f5b46d344768eedf93a37be6926_Out_0_Float, _Simplexnoise3D_22a26c000d084fac88791e2e272a3627, _Simplexnoise3D_22a26c000d084fac88791e2e272a3627_Value_0_Float);
            float _Multiply_5d2a615d591846639a86f8c99ad1d74f_Out_2_Float;
            Unity_Multiply_float_float(_Simplexnoise3D_22a26c000d084fac88791e2e272a3627_Value_0_Float, 2, _Multiply_5d2a615d591846639a86f8c99ad1d74f_Out_2_Float);
            float _Multiply_435d201b79e84b93ba9550b17093a7a3_Out_2_Float;
            Unity_Multiply_float_float(_Property_dfa3069e428d48c2a00288fb727d87aa_Out_0_Float, _Multiply_5d2a615d591846639a86f8c99ad1d74f_Out_2_Float, _Multiply_435d201b79e84b93ba9550b17093a7a3_Out_2_Float);
            float _Subtract_c100a05a73374ad49444d48d36b9e8eb_Out_2_Float;
            Unity_Subtract_float(_Multiply_69a6ec8992034d6794dc6830d8797195_Out_2_Float, _Multiply_435d201b79e84b93ba9550b17093a7a3_Out_2_Float, _Subtract_c100a05a73374ad49444d48d36b9e8eb_Out_2_Float);
            float _Property_ae17d459cf4b4ab990efe381eea06168_Out_0_Float = _Threshold;
            float _Comparison_4f7234cc3f94421391353a7e6e0f5ba2_Out_2_Boolean;
            Unity_Comparison_Greater_float(_Subtract_c100a05a73374ad49444d48d36b9e8eb_Out_2_Float, _Property_ae17d459cf4b4ab990efe381eea06168_Out_0_Float, _Comparison_4f7234cc3f94421391353a7e6e0f5ba2_Out_2_Boolean);
            float _And_4fbdfcb10ecf498b9738783eeab3d100_Out_2_Boolean;
            Unity_And_float(_Property_2a75182591204a34887f8c0852a6d7c5_Out_0_Boolean, _Comparison_4f7234cc3f94421391353a7e6e0f5ba2_Out_2_Boolean, _And_4fbdfcb10ecf498b9738783eeab3d100_Out_2_Boolean);
            float _Branch_9b1eb1627cd34dab9ff125d0f7d8fe61_Out_3_Float;
            Unity_Branch_float(_And_4fbdfcb10ecf498b9738783eeab3d100_Out_2_Boolean, float(1), float(0), _Branch_9b1eb1627cd34dab9ff125d0f7d8fe61_Out_3_Float);
            float4 _Multiply_e4d7081d402f4f628e64811486134ac6_Out_2_Vector4;
            Unity_Multiply_float4_float4(_SampleTexture2D_f271227fcd0e4b51a6327802cec29d72_RGBA_0_Vector4, (_Branch_9b1eb1627cd34dab9ff125d0f7d8fe61_Out_3_Float.xxxx), _Multiply_e4d7081d402f4f628e64811486134ac6_Out_2_Vector4);
            float _Split_5694b20622c5400a95c05d1aad050fcd_R_1_Float = _Multiply_e4d7081d402f4f628e64811486134ac6_Out_2_Vector4[0];
            float _Split_5694b20622c5400a95c05d1aad050fcd_G_2_Float = _Multiply_e4d7081d402f4f628e64811486134ac6_Out_2_Vector4[1];
            float _Split_5694b20622c5400a95c05d1aad050fcd_B_3_Float = _Multiply_e4d7081d402f4f628e64811486134ac6_Out_2_Vector4[2];
            float _Split_5694b20622c5400a95c05d1aad050fcd_A_4_Float = _Multiply_e4d7081d402f4f628e64811486134ac6_Out_2_Vector4[3];
            surface.BaseColor = (_Multiply_e4d7081d402f4f628e64811486134ac6_Out_2_Vector4.xyz);
            surface.Alpha = _Split_5694b20622c5400a95c05d1aad050fcd_A_4_Float;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
        #if UNITY_ANY_INSTANCING_ENABLED
        #else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
        #endif
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
        #if VFX_USE_GRAPH_VALUES
            uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
            /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
        #endif
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
        
        
            output.WorldSpacePosition = input.positionWS;
        
            #if UNITY_UV_STARTS_AT_TOP
            #else
            #endif
        
        
            output.uv0 = input.texCoord0;
        #if UNITY_ANY_INSTANCING_ENABLED
        #else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
        #endif
            output.TimeParameters = _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/2D/ShaderGraph/Includes/SpriteUnlitPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "SceneSelectionPass"
            Tags
            {
                "LightMode" = "SceneSelectionPass"
            }
        
        // Render State
        Cull Off
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 2.0
        #pragma exclude_renderers d3d11_9x
        #pragma multi_compile_instancing
        #pragma vertex vert
        #pragma fragment frag
        
        // Keywords
        // PassKeywords: <None>
        // GraphKeywords: <None>
        
        // Defines
        
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define FEATURES_GRAPH_VERTEX_NORMAL_OUTPUT
        #define FEATURES_GRAPH_VERTEX_TANGENT_OUTPUT
        #define VARYINGS_NEED_POSITION_WS
        #define VARYINGS_NEED_TEXCOORD0
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_DEPTHONLY
        #define SCENESELECTIONPASS 1
        
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/DebugMipmapStreamingMacros.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv0 : TEXCOORD0;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(ATTRIBUTES_NEED_INSTANCEID)
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 positionWS;
             float4 texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float3 WorldSpacePosition;
             float4 uv0;
             float3 TimeParameters;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float4 texCoord0 : INTERP0;
             float3 positionWS : INTERP1;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.texCoord0.xyzw = input.texCoord0;
            output.positionWS.xyz = input.positionWS;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.texCoord0 = input.texCoord0.xyzw;
            output.positionWS = input.positionWS.xyz;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _MainTex_TexelSize;
        float _Noise_Scale;
        float _TorchNoiseStrength;
        float _Noise_Speed;
        float _Threshold;
        float _Warp_Strength;
        float _Warp_Scale;
        float _Abberation_Intensity;
        float _Cutoff;
        UNITY_TEXTURE_STREAMING_DEBUG_VARS;
        CBUFFER_END
        
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_MainTex);
        SAMPLER(sampler_MainTex);
        float2 _TorchWorldPos;
        float2 _TorchPointDir;
        float _ConeAngle;
        float _TorchEnabled;
        
        // Graph Includes
        #include_with_pragmas "Packages/com.jimmycushnie.noisynodes/NoiseShader/HLSL/Voronoi3D.hlsl"
        #include_with_pragmas "Packages/com.jimmycushnie.noisynodes/NoiseShader/HLSL/SimplexNoise3D.hlsl"
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Subtract_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A - B;
        }
        
        void Unity_Length_float4(float4 In, out float Out)
        {
            Out = length(In);
        }
        
        void Unity_Step_float(float Edge, float In, out float Out)
        {
            Out = step(Edge, In);
        }
        
        void Unity_Subtract_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A - B;
        }
        
        void Unity_DotProduct_float2(float2 A, float2 B, out float Out)
        {
            Out = dot(A, B);
        }
        
        void Unity_Length_float2(float2 In, out float Out)
        {
            Out = length(In);
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }
        
        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }
        
        void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }
        
        struct Bindings_Voronoinoise3D_92001a1a051ec8247a12e151ca32427b_float
        {
        };
        
        void SG_Voronoinoise3D_92001a1a051ec8247a12e151ca32427b_float(float3 Vector3_375394F7, float Vector1_B47BD908, float Vector1_AEE7F28E, Bindings_Voronoinoise3D_92001a1a051ec8247a12e151ca32427b_float IN, out float Value_1, out float Cells_2)
        {
        float3 _Property_c0874fd2920f9c8baf4b91be875c7ebb_Out_0_Vector3 = Vector3_375394F7;
        float _Property_1d30cf63fc420f8f99a0cbe60bb88392_Out_0_Float = Vector1_B47BD908;
        float _Property_01df2bf4a6ebe48c8c34049cb8b5c130_Out_0_Float = Vector1_AEE7F28E;
        float _Voronoi3DCustomFunction_f3778cac851e5b82b5979141914b8445_Value_3_Float;
        float _Voronoi3DCustomFunction_f3778cac851e5b82b5979141914b8445_Cells_4_Float;
        Voronoi3D_float(_Property_c0874fd2920f9c8baf4b91be875c7ebb_Out_0_Vector3, _Property_1d30cf63fc420f8f99a0cbe60bb88392_Out_0_Float, _Property_01df2bf4a6ebe48c8c34049cb8b5c130_Out_0_Float, _Voronoi3DCustomFunction_f3778cac851e5b82b5979141914b8445_Value_3_Float, _Voronoi3DCustomFunction_f3778cac851e5b82b5979141914b8445_Cells_4_Float);
        Value_1 = _Voronoi3DCustomFunction_f3778cac851e5b82b5979141914b8445_Value_3_Float;
        Cells_2 = _Voronoi3DCustomFunction_f3778cac851e5b82b5979141914b8445_Cells_4_Float;
        }
        
        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
        }
        
        void Unity_Multiply_float3_float3(float3 A, float3 B, out float3 Out)
        {
        Out = A * B;
        }
        
        struct Bindings_Simplexnoise3D_b3b7f0d9d78bece4587dc8496c4ed47b_float
        {
        };
        
        void SG_Simplexnoise3D_b3b7f0d9d78bece4587dc8496c4ed47b_float(float3 Vector3_7940555B, float Vector1_D4A5C52D, Bindings_Simplexnoise3D_b3b7f0d9d78bece4587dc8496c4ed47b_float IN, out float Value_0)
        {
        float3 _Property_44999cc87708de82a26b39ae1da975ec_Out_0_Vector3 = Vector3_7940555B;
        float _Property_31805413f7564f8da25bf75c2a6983b0_Out_0_Float = Vector1_D4A5C52D;
        float3 _Multiply_1d17f1db9ddb2d8481679237f2442ac2_Out_2_Vector3;
        Unity_Multiply_float3_float3(_Property_44999cc87708de82a26b39ae1da975ec_Out_0_Vector3, (_Property_31805413f7564f8da25bf75c2a6983b0_Out_0_Float.xxx), _Multiply_1d17f1db9ddb2d8481679237f2442ac2_Out_2_Vector3);
        float _SimplexNoise3DCustomFunction_1d714aea6ba122808f5efcabfce18252_Out_1_Float;
        SimplexNoise3D_float(_Multiply_1d17f1db9ddb2d8481679237f2442ac2_Out_2_Vector3, _SimplexNoise3DCustomFunction_1d714aea6ba122808f5efcabfce18252_Out_1_Float);
        float _Remap_4e5d05a6e861b582b5e910962a3ffd60_Out_3_Float;
        Unity_Remap_float(_SimplexNoise3DCustomFunction_1d714aea6ba122808f5efcabfce18252_Out_1_Float, float2 (-1, 1), float2 (0, 1), _Remap_4e5d05a6e861b582b5e910962a3ffd60_Out_3_Float);
        Value_0 = _Remap_4e5d05a6e861b582b5e910962a3ffd60_Out_3_Float;
        }
        
        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }
        
        void Unity_Comparison_Greater_float(float A, float B, out float Out)
        {
            Out = A > B ? 1 : 0;
        }
        
        void Unity_And_float(float A, float B, out float Out)
        {
            Out = A && B;
        }
        
        void Unity_Branch_float(float Predicate, float True, float False, out float Out)
        {
            Out = Predicate ? True : False;
        }
        
        void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float Alpha;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            UnityTexture2D _Property_9da0b2bc8c884590abd2996a28f14783_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_MainTex);
            float4 _SampleTexture2D_f271227fcd0e4b51a6327802cec29d72_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_9da0b2bc8c884590abd2996a28f14783_Out_0_Texture2D.tex, _Property_9da0b2bc8c884590abd2996a28f14783_Out_0_Texture2D.samplerstate, _Property_9da0b2bc8c884590abd2996a28f14783_Out_0_Texture2D.GetTransformedUV(IN.uv0.xy) );
            float _SampleTexture2D_f271227fcd0e4b51a6327802cec29d72_R_4_Float = _SampleTexture2D_f271227fcd0e4b51a6327802cec29d72_RGBA_0_Vector4.r;
            float _SampleTexture2D_f271227fcd0e4b51a6327802cec29d72_G_5_Float = _SampleTexture2D_f271227fcd0e4b51a6327802cec29d72_RGBA_0_Vector4.g;
            float _SampleTexture2D_f271227fcd0e4b51a6327802cec29d72_B_6_Float = _SampleTexture2D_f271227fcd0e4b51a6327802cec29d72_RGBA_0_Vector4.b;
            float _SampleTexture2D_f271227fcd0e4b51a6327802cec29d72_A_7_Float = _SampleTexture2D_f271227fcd0e4b51a6327802cec29d72_RGBA_0_Vector4.a;
            float _Property_2a75182591204a34887f8c0852a6d7c5_Out_0_Boolean = _TorchEnabled;
            float _Property_b235dec23c7244ee96802a2291b1ecd2_Out_0_Float = _Cutoff;
            float4 _UV_44cb21489bee4382b69b741257b9b83c_Out_0_Vector4 = IN.uv0;
            float4 _Subtract_2437e7a503d248449d7aa4baa1aeda12_Out_2_Vector4;
            Unity_Subtract_float4(_UV_44cb21489bee4382b69b741257b9b83c_Out_0_Vector4, float4(0.5, 0.5, 1, 1), _Subtract_2437e7a503d248449d7aa4baa1aeda12_Out_2_Vector4);
            float _Length_e1f9513bf75a4e9e9dbeeed7c69964b1_Out_1_Float;
            Unity_Length_float4(_Subtract_2437e7a503d248449d7aa4baa1aeda12_Out_2_Vector4, _Length_e1f9513bf75a4e9e9dbeeed7c69964b1_Out_1_Float);
            float _Step_7c5418391b9c49248e4bc367843fa597_Out_2_Float;
            Unity_Step_float(_Property_b235dec23c7244ee96802a2291b1ecd2_Out_0_Float, _Length_e1f9513bf75a4e9e9dbeeed7c69964b1_Out_1_Float, _Step_7c5418391b9c49248e4bc367843fa597_Out_2_Float);
            float2 _Property_7033a961d17048b0ab681ea9a8de15dd_Out_0_Vector2 = _TorchWorldPos;
            float2 _Subtract_53cbbd021eb04323905291953ce2bf0b_Out_2_Vector2;
            Unity_Subtract_float2((IN.WorldSpacePosition.xy), _Property_7033a961d17048b0ab681ea9a8de15dd_Out_0_Vector2, _Subtract_53cbbd021eb04323905291953ce2bf0b_Out_2_Vector2);
            float2 _Property_3f205fc181f74ccbb4158016995d0d6f_Out_0_Vector2 = _TorchPointDir;
            float _DotProduct_98b628519f13442ca29c540730032133_Out_2_Float;
            Unity_DotProduct_float2(_Subtract_53cbbd021eb04323905291953ce2bf0b_Out_2_Vector2, _Property_3f205fc181f74ccbb4158016995d0d6f_Out_0_Vector2, _DotProduct_98b628519f13442ca29c540730032133_Out_2_Float);
            float _Length_9d91b71764ca46d5a6d4f0cfa754d2bb_Out_1_Float;
            Unity_Length_float2(_Subtract_53cbbd021eb04323905291953ce2bf0b_Out_2_Vector2, _Length_9d91b71764ca46d5a6d4f0cfa754d2bb_Out_1_Float);
            float _Length_9a332ec75df64ba992de1c2b3dd39e3a_Out_1_Float;
            Unity_Length_float2(_Property_3f205fc181f74ccbb4158016995d0d6f_Out_0_Vector2, _Length_9a332ec75df64ba992de1c2b3dd39e3a_Out_1_Float);
            float _Multiply_24b3d100c67d40a693a4182ef01451ee_Out_2_Float;
            Unity_Multiply_float_float(_Length_9d91b71764ca46d5a6d4f0cfa754d2bb_Out_1_Float, _Length_9a332ec75df64ba992de1c2b3dd39e3a_Out_1_Float, _Multiply_24b3d100c67d40a693a4182ef01451ee_Out_2_Float);
            float _Divide_a91708cba40243e08d4219249db86c65_Out_2_Float;
            Unity_Divide_float(_DotProduct_98b628519f13442ca29c540730032133_Out_2_Float, _Multiply_24b3d100c67d40a693a4182ef01451ee_Out_2_Float, _Divide_a91708cba40243e08d4219249db86c65_Out_2_Float);
            float _Property_7e8351790b1945e3bedb4ed0ce5af20e_Out_0_Float = _ConeAngle;
            float _Property_7e4150e0dd7b4a15b2c7c9d48cbe0987_Out_0_Float = _ConeAngle;
            float _Add_12bf6727cd124131a5ac7e2844aea423_Out_2_Float;
            Unity_Add_float(_Property_7e4150e0dd7b4a15b2c7c9d48cbe0987_Out_0_Float, float(0.1), _Add_12bf6727cd124131a5ac7e2844aea423_Out_2_Float);
            float2 _Vector2_10b46480a0894d3b998ae1fa779a5ff4_Out_0_Vector2 = float2(_Property_7e8351790b1945e3bedb4ed0ce5af20e_Out_0_Float, _Add_12bf6727cd124131a5ac7e2844aea423_Out_2_Float);
            float _Remap_724e812769644b63a2060d37e7afbdae_Out_3_Float;
            Unity_Remap_float(_Divide_a91708cba40243e08d4219249db86c65_Out_2_Float, _Vector2_10b46480a0894d3b998ae1fa779a5ff4_Out_0_Vector2, float2 (0, 1), _Remap_724e812769644b63a2060d37e7afbdae_Out_3_Float);
            float _Multiply_69a6ec8992034d6794dc6830d8797195_Out_2_Float;
            Unity_Multiply_float_float(_Step_7c5418391b9c49248e4bc367843fa597_Out_2_Float, _Remap_724e812769644b63a2060d37e7afbdae_Out_3_Float, _Multiply_69a6ec8992034d6794dc6830d8797195_Out_2_Float);
            float _Property_dfa3069e428d48c2a00288fb727d87aa_Out_0_Float = _TorchNoiseStrength;
            float _Split_73f51655f05748e9bafdfa82c53a6756_R_1_Float = IN.WorldSpacePosition[0];
            float _Split_73f51655f05748e9bafdfa82c53a6756_G_2_Float = IN.WorldSpacePosition[1];
            float _Split_73f51655f05748e9bafdfa82c53a6756_B_3_Float = IN.WorldSpacePosition[2];
            float _Split_73f51655f05748e9bafdfa82c53a6756_A_4_Float = 0;
            float _Property_2af28184bb9342ae91b1f54e7e73c995_Out_0_Float = _Noise_Speed;
            float _Multiply_ac67735ad1e642988ed3ce9b37d72d0a_Out_2_Float;
            Unity_Multiply_float_float(_Property_2af28184bb9342ae91b1f54e7e73c995_Out_0_Float, IN.TimeParameters.x, _Multiply_ac67735ad1e642988ed3ce9b37d72d0a_Out_2_Float);
            float3 _Vector3_1b110a8e5c6d410db18c670e3000b981_Out_0_Vector3 = float3(_Split_73f51655f05748e9bafdfa82c53a6756_R_1_Float, _Split_73f51655f05748e9bafdfa82c53a6756_G_2_Float, _Multiply_ac67735ad1e642988ed3ce9b37d72d0a_Out_2_Float);
            float _Property_e46a47d2ad964f1991ec5f4f47ba0e4c_Out_0_Float = _Warp_Scale;
            Bindings_Voronoinoise3D_92001a1a051ec8247a12e151ca32427b_float _Voronoinoise3D_de2a85142ed344d0a735380b5b3964b9;
            float _Voronoinoise3D_de2a85142ed344d0a735380b5b3964b9_Value_1_Float;
            float _Voronoinoise3D_de2a85142ed344d0a735380b5b3964b9_Cells_2_Float;
            SG_Voronoinoise3D_92001a1a051ec8247a12e151ca32427b_float(_Vector3_1b110a8e5c6d410db18c670e3000b981_Out_0_Vector3, float(10), _Property_e46a47d2ad964f1991ec5f4f47ba0e4c_Out_0_Float, _Voronoinoise3D_de2a85142ed344d0a735380b5b3964b9, _Voronoinoise3D_de2a85142ed344d0a735380b5b3964b9_Value_1_Float, _Voronoinoise3D_de2a85142ed344d0a735380b5b3964b9_Cells_2_Float);
            float _Property_2ae067af17f5451e8839bd295fd143da_Out_0_Float = _Warp_Strength;
            float _Multiply_a138b9bfcd6b4aafa72ec02a7e70affc_Out_2_Float;
            Unity_Multiply_float_float(_Voronoinoise3D_de2a85142ed344d0a735380b5b3964b9_Value_1_Float, _Property_2ae067af17f5451e8839bd295fd143da_Out_0_Float, _Multiply_a138b9bfcd6b4aafa72ec02a7e70affc_Out_2_Float);
            float3 _Add_5657652b57de46d59a3acf09df734a88_Out_2_Vector3;
            Unity_Add_float3(_Vector3_1b110a8e5c6d410db18c670e3000b981_Out_0_Vector3, (_Multiply_a138b9bfcd6b4aafa72ec02a7e70affc_Out_2_Float.xxx), _Add_5657652b57de46d59a3acf09df734a88_Out_2_Vector3);
            float _Property_47bf2f5b46d344768eedf93a37be6926_Out_0_Float = _Noise_Scale;
            Bindings_Simplexnoise3D_b3b7f0d9d78bece4587dc8496c4ed47b_float _Simplexnoise3D_22a26c000d084fac88791e2e272a3627;
            float _Simplexnoise3D_22a26c000d084fac88791e2e272a3627_Value_0_Float;
            SG_Simplexnoise3D_b3b7f0d9d78bece4587dc8496c4ed47b_float(_Add_5657652b57de46d59a3acf09df734a88_Out_2_Vector3, _Property_47bf2f5b46d344768eedf93a37be6926_Out_0_Float, _Simplexnoise3D_22a26c000d084fac88791e2e272a3627, _Simplexnoise3D_22a26c000d084fac88791e2e272a3627_Value_0_Float);
            float _Multiply_5d2a615d591846639a86f8c99ad1d74f_Out_2_Float;
            Unity_Multiply_float_float(_Simplexnoise3D_22a26c000d084fac88791e2e272a3627_Value_0_Float, 2, _Multiply_5d2a615d591846639a86f8c99ad1d74f_Out_2_Float);
            float _Multiply_435d201b79e84b93ba9550b17093a7a3_Out_2_Float;
            Unity_Multiply_float_float(_Property_dfa3069e428d48c2a00288fb727d87aa_Out_0_Float, _Multiply_5d2a615d591846639a86f8c99ad1d74f_Out_2_Float, _Multiply_435d201b79e84b93ba9550b17093a7a3_Out_2_Float);
            float _Subtract_c100a05a73374ad49444d48d36b9e8eb_Out_2_Float;
            Unity_Subtract_float(_Multiply_69a6ec8992034d6794dc6830d8797195_Out_2_Float, _Multiply_435d201b79e84b93ba9550b17093a7a3_Out_2_Float, _Subtract_c100a05a73374ad49444d48d36b9e8eb_Out_2_Float);
            float _Property_ae17d459cf4b4ab990efe381eea06168_Out_0_Float = _Threshold;
            float _Comparison_4f7234cc3f94421391353a7e6e0f5ba2_Out_2_Boolean;
            Unity_Comparison_Greater_float(_Subtract_c100a05a73374ad49444d48d36b9e8eb_Out_2_Float, _Property_ae17d459cf4b4ab990efe381eea06168_Out_0_Float, _Comparison_4f7234cc3f94421391353a7e6e0f5ba2_Out_2_Boolean);
            float _And_4fbdfcb10ecf498b9738783eeab3d100_Out_2_Boolean;
            Unity_And_float(_Property_2a75182591204a34887f8c0852a6d7c5_Out_0_Boolean, _Comparison_4f7234cc3f94421391353a7e6e0f5ba2_Out_2_Boolean, _And_4fbdfcb10ecf498b9738783eeab3d100_Out_2_Boolean);
            float _Branch_9b1eb1627cd34dab9ff125d0f7d8fe61_Out_3_Float;
            Unity_Branch_float(_And_4fbdfcb10ecf498b9738783eeab3d100_Out_2_Boolean, float(1), float(0), _Branch_9b1eb1627cd34dab9ff125d0f7d8fe61_Out_3_Float);
            float4 _Multiply_e4d7081d402f4f628e64811486134ac6_Out_2_Vector4;
            Unity_Multiply_float4_float4(_SampleTexture2D_f271227fcd0e4b51a6327802cec29d72_RGBA_0_Vector4, (_Branch_9b1eb1627cd34dab9ff125d0f7d8fe61_Out_3_Float.xxxx), _Multiply_e4d7081d402f4f628e64811486134ac6_Out_2_Vector4);
            float _Split_5694b20622c5400a95c05d1aad050fcd_R_1_Float = _Multiply_e4d7081d402f4f628e64811486134ac6_Out_2_Vector4[0];
            float _Split_5694b20622c5400a95c05d1aad050fcd_G_2_Float = _Multiply_e4d7081d402f4f628e64811486134ac6_Out_2_Vector4[1];
            float _Split_5694b20622c5400a95c05d1aad050fcd_B_3_Float = _Multiply_e4d7081d402f4f628e64811486134ac6_Out_2_Vector4[2];
            float _Split_5694b20622c5400a95c05d1aad050fcd_A_4_Float = _Multiply_e4d7081d402f4f628e64811486134ac6_Out_2_Vector4[3];
            surface.Alpha = _Split_5694b20622c5400a95c05d1aad050fcd_A_4_Float;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
        #if UNITY_ANY_INSTANCING_ENABLED
        #else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
        #endif
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
        #if VFX_USE_GRAPH_VALUES
            uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
            /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
        #endif
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
        
        
            output.WorldSpacePosition = input.positionWS;
        
            #if UNITY_UV_STARTS_AT_TOP
            #else
            #endif
        
        
            output.uv0 = input.texCoord0;
        #if UNITY_ANY_INSTANCING_ENABLED
        #else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
        #endif
            output.TimeParameters = _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/SelectionPickingPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "ScenePickingPass"
            Tags
            {
                "LightMode" = "Picking"
            }
        
        // Render State
        Cull Back
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 2.0
        #pragma exclude_renderers d3d11_9x
        #pragma multi_compile_instancing
        #pragma vertex vert
        #pragma fragment frag
        
        // Keywords
        // PassKeywords: <None>
        // GraphKeywords: <None>
        
        // Defines
        
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define FEATURES_GRAPH_VERTEX_NORMAL_OUTPUT
        #define FEATURES_GRAPH_VERTEX_TANGENT_OUTPUT
        #define VARYINGS_NEED_POSITION_WS
        #define VARYINGS_NEED_TEXCOORD0
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_DEPTHONLY
        #define SCENEPICKINGPASS 1
        
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/DebugMipmapStreamingMacros.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv0 : TEXCOORD0;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(ATTRIBUTES_NEED_INSTANCEID)
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 positionWS;
             float4 texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float3 WorldSpacePosition;
             float4 uv0;
             float3 TimeParameters;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float4 texCoord0 : INTERP0;
             float3 positionWS : INTERP1;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.texCoord0.xyzw = input.texCoord0;
            output.positionWS.xyz = input.positionWS;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.texCoord0 = input.texCoord0.xyzw;
            output.positionWS = input.positionWS.xyz;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _MainTex_TexelSize;
        float _Noise_Scale;
        float _TorchNoiseStrength;
        float _Noise_Speed;
        float _Threshold;
        float _Warp_Strength;
        float _Warp_Scale;
        float _Abberation_Intensity;
        float _Cutoff;
        UNITY_TEXTURE_STREAMING_DEBUG_VARS;
        CBUFFER_END
        
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_MainTex);
        SAMPLER(sampler_MainTex);
        float2 _TorchWorldPos;
        float2 _TorchPointDir;
        float _ConeAngle;
        float _TorchEnabled;
        
        // Graph Includes
        #include_with_pragmas "Packages/com.jimmycushnie.noisynodes/NoiseShader/HLSL/Voronoi3D.hlsl"
        #include_with_pragmas "Packages/com.jimmycushnie.noisynodes/NoiseShader/HLSL/SimplexNoise3D.hlsl"
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Subtract_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A - B;
        }
        
        void Unity_Length_float4(float4 In, out float Out)
        {
            Out = length(In);
        }
        
        void Unity_Step_float(float Edge, float In, out float Out)
        {
            Out = step(Edge, In);
        }
        
        void Unity_Subtract_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A - B;
        }
        
        void Unity_DotProduct_float2(float2 A, float2 B, out float Out)
        {
            Out = dot(A, B);
        }
        
        void Unity_Length_float2(float2 In, out float Out)
        {
            Out = length(In);
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }
        
        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }
        
        void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }
        
        struct Bindings_Voronoinoise3D_92001a1a051ec8247a12e151ca32427b_float
        {
        };
        
        void SG_Voronoinoise3D_92001a1a051ec8247a12e151ca32427b_float(float3 Vector3_375394F7, float Vector1_B47BD908, float Vector1_AEE7F28E, Bindings_Voronoinoise3D_92001a1a051ec8247a12e151ca32427b_float IN, out float Value_1, out float Cells_2)
        {
        float3 _Property_c0874fd2920f9c8baf4b91be875c7ebb_Out_0_Vector3 = Vector3_375394F7;
        float _Property_1d30cf63fc420f8f99a0cbe60bb88392_Out_0_Float = Vector1_B47BD908;
        float _Property_01df2bf4a6ebe48c8c34049cb8b5c130_Out_0_Float = Vector1_AEE7F28E;
        float _Voronoi3DCustomFunction_f3778cac851e5b82b5979141914b8445_Value_3_Float;
        float _Voronoi3DCustomFunction_f3778cac851e5b82b5979141914b8445_Cells_4_Float;
        Voronoi3D_float(_Property_c0874fd2920f9c8baf4b91be875c7ebb_Out_0_Vector3, _Property_1d30cf63fc420f8f99a0cbe60bb88392_Out_0_Float, _Property_01df2bf4a6ebe48c8c34049cb8b5c130_Out_0_Float, _Voronoi3DCustomFunction_f3778cac851e5b82b5979141914b8445_Value_3_Float, _Voronoi3DCustomFunction_f3778cac851e5b82b5979141914b8445_Cells_4_Float);
        Value_1 = _Voronoi3DCustomFunction_f3778cac851e5b82b5979141914b8445_Value_3_Float;
        Cells_2 = _Voronoi3DCustomFunction_f3778cac851e5b82b5979141914b8445_Cells_4_Float;
        }
        
        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
        }
        
        void Unity_Multiply_float3_float3(float3 A, float3 B, out float3 Out)
        {
        Out = A * B;
        }
        
        struct Bindings_Simplexnoise3D_b3b7f0d9d78bece4587dc8496c4ed47b_float
        {
        };
        
        void SG_Simplexnoise3D_b3b7f0d9d78bece4587dc8496c4ed47b_float(float3 Vector3_7940555B, float Vector1_D4A5C52D, Bindings_Simplexnoise3D_b3b7f0d9d78bece4587dc8496c4ed47b_float IN, out float Value_0)
        {
        float3 _Property_44999cc87708de82a26b39ae1da975ec_Out_0_Vector3 = Vector3_7940555B;
        float _Property_31805413f7564f8da25bf75c2a6983b0_Out_0_Float = Vector1_D4A5C52D;
        float3 _Multiply_1d17f1db9ddb2d8481679237f2442ac2_Out_2_Vector3;
        Unity_Multiply_float3_float3(_Property_44999cc87708de82a26b39ae1da975ec_Out_0_Vector3, (_Property_31805413f7564f8da25bf75c2a6983b0_Out_0_Float.xxx), _Multiply_1d17f1db9ddb2d8481679237f2442ac2_Out_2_Vector3);
        float _SimplexNoise3DCustomFunction_1d714aea6ba122808f5efcabfce18252_Out_1_Float;
        SimplexNoise3D_float(_Multiply_1d17f1db9ddb2d8481679237f2442ac2_Out_2_Vector3, _SimplexNoise3DCustomFunction_1d714aea6ba122808f5efcabfce18252_Out_1_Float);
        float _Remap_4e5d05a6e861b582b5e910962a3ffd60_Out_3_Float;
        Unity_Remap_float(_SimplexNoise3DCustomFunction_1d714aea6ba122808f5efcabfce18252_Out_1_Float, float2 (-1, 1), float2 (0, 1), _Remap_4e5d05a6e861b582b5e910962a3ffd60_Out_3_Float);
        Value_0 = _Remap_4e5d05a6e861b582b5e910962a3ffd60_Out_3_Float;
        }
        
        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }
        
        void Unity_Comparison_Greater_float(float A, float B, out float Out)
        {
            Out = A > B ? 1 : 0;
        }
        
        void Unity_And_float(float A, float B, out float Out)
        {
            Out = A && B;
        }
        
        void Unity_Branch_float(float Predicate, float True, float False, out float Out)
        {
            Out = Predicate ? True : False;
        }
        
        void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float Alpha;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            UnityTexture2D _Property_9da0b2bc8c884590abd2996a28f14783_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_MainTex);
            float4 _SampleTexture2D_f271227fcd0e4b51a6327802cec29d72_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_9da0b2bc8c884590abd2996a28f14783_Out_0_Texture2D.tex, _Property_9da0b2bc8c884590abd2996a28f14783_Out_0_Texture2D.samplerstate, _Property_9da0b2bc8c884590abd2996a28f14783_Out_0_Texture2D.GetTransformedUV(IN.uv0.xy) );
            float _SampleTexture2D_f271227fcd0e4b51a6327802cec29d72_R_4_Float = _SampleTexture2D_f271227fcd0e4b51a6327802cec29d72_RGBA_0_Vector4.r;
            float _SampleTexture2D_f271227fcd0e4b51a6327802cec29d72_G_5_Float = _SampleTexture2D_f271227fcd0e4b51a6327802cec29d72_RGBA_0_Vector4.g;
            float _SampleTexture2D_f271227fcd0e4b51a6327802cec29d72_B_6_Float = _SampleTexture2D_f271227fcd0e4b51a6327802cec29d72_RGBA_0_Vector4.b;
            float _SampleTexture2D_f271227fcd0e4b51a6327802cec29d72_A_7_Float = _SampleTexture2D_f271227fcd0e4b51a6327802cec29d72_RGBA_0_Vector4.a;
            float _Property_2a75182591204a34887f8c0852a6d7c5_Out_0_Boolean = _TorchEnabled;
            float _Property_b235dec23c7244ee96802a2291b1ecd2_Out_0_Float = _Cutoff;
            float4 _UV_44cb21489bee4382b69b741257b9b83c_Out_0_Vector4 = IN.uv0;
            float4 _Subtract_2437e7a503d248449d7aa4baa1aeda12_Out_2_Vector4;
            Unity_Subtract_float4(_UV_44cb21489bee4382b69b741257b9b83c_Out_0_Vector4, float4(0.5, 0.5, 1, 1), _Subtract_2437e7a503d248449d7aa4baa1aeda12_Out_2_Vector4);
            float _Length_e1f9513bf75a4e9e9dbeeed7c69964b1_Out_1_Float;
            Unity_Length_float4(_Subtract_2437e7a503d248449d7aa4baa1aeda12_Out_2_Vector4, _Length_e1f9513bf75a4e9e9dbeeed7c69964b1_Out_1_Float);
            float _Step_7c5418391b9c49248e4bc367843fa597_Out_2_Float;
            Unity_Step_float(_Property_b235dec23c7244ee96802a2291b1ecd2_Out_0_Float, _Length_e1f9513bf75a4e9e9dbeeed7c69964b1_Out_1_Float, _Step_7c5418391b9c49248e4bc367843fa597_Out_2_Float);
            float2 _Property_7033a961d17048b0ab681ea9a8de15dd_Out_0_Vector2 = _TorchWorldPos;
            float2 _Subtract_53cbbd021eb04323905291953ce2bf0b_Out_2_Vector2;
            Unity_Subtract_float2((IN.WorldSpacePosition.xy), _Property_7033a961d17048b0ab681ea9a8de15dd_Out_0_Vector2, _Subtract_53cbbd021eb04323905291953ce2bf0b_Out_2_Vector2);
            float2 _Property_3f205fc181f74ccbb4158016995d0d6f_Out_0_Vector2 = _TorchPointDir;
            float _DotProduct_98b628519f13442ca29c540730032133_Out_2_Float;
            Unity_DotProduct_float2(_Subtract_53cbbd021eb04323905291953ce2bf0b_Out_2_Vector2, _Property_3f205fc181f74ccbb4158016995d0d6f_Out_0_Vector2, _DotProduct_98b628519f13442ca29c540730032133_Out_2_Float);
            float _Length_9d91b71764ca46d5a6d4f0cfa754d2bb_Out_1_Float;
            Unity_Length_float2(_Subtract_53cbbd021eb04323905291953ce2bf0b_Out_2_Vector2, _Length_9d91b71764ca46d5a6d4f0cfa754d2bb_Out_1_Float);
            float _Length_9a332ec75df64ba992de1c2b3dd39e3a_Out_1_Float;
            Unity_Length_float2(_Property_3f205fc181f74ccbb4158016995d0d6f_Out_0_Vector2, _Length_9a332ec75df64ba992de1c2b3dd39e3a_Out_1_Float);
            float _Multiply_24b3d100c67d40a693a4182ef01451ee_Out_2_Float;
            Unity_Multiply_float_float(_Length_9d91b71764ca46d5a6d4f0cfa754d2bb_Out_1_Float, _Length_9a332ec75df64ba992de1c2b3dd39e3a_Out_1_Float, _Multiply_24b3d100c67d40a693a4182ef01451ee_Out_2_Float);
            float _Divide_a91708cba40243e08d4219249db86c65_Out_2_Float;
            Unity_Divide_float(_DotProduct_98b628519f13442ca29c540730032133_Out_2_Float, _Multiply_24b3d100c67d40a693a4182ef01451ee_Out_2_Float, _Divide_a91708cba40243e08d4219249db86c65_Out_2_Float);
            float _Property_7e8351790b1945e3bedb4ed0ce5af20e_Out_0_Float = _ConeAngle;
            float _Property_7e4150e0dd7b4a15b2c7c9d48cbe0987_Out_0_Float = _ConeAngle;
            float _Add_12bf6727cd124131a5ac7e2844aea423_Out_2_Float;
            Unity_Add_float(_Property_7e4150e0dd7b4a15b2c7c9d48cbe0987_Out_0_Float, float(0.1), _Add_12bf6727cd124131a5ac7e2844aea423_Out_2_Float);
            float2 _Vector2_10b46480a0894d3b998ae1fa779a5ff4_Out_0_Vector2 = float2(_Property_7e8351790b1945e3bedb4ed0ce5af20e_Out_0_Float, _Add_12bf6727cd124131a5ac7e2844aea423_Out_2_Float);
            float _Remap_724e812769644b63a2060d37e7afbdae_Out_3_Float;
            Unity_Remap_float(_Divide_a91708cba40243e08d4219249db86c65_Out_2_Float, _Vector2_10b46480a0894d3b998ae1fa779a5ff4_Out_0_Vector2, float2 (0, 1), _Remap_724e812769644b63a2060d37e7afbdae_Out_3_Float);
            float _Multiply_69a6ec8992034d6794dc6830d8797195_Out_2_Float;
            Unity_Multiply_float_float(_Step_7c5418391b9c49248e4bc367843fa597_Out_2_Float, _Remap_724e812769644b63a2060d37e7afbdae_Out_3_Float, _Multiply_69a6ec8992034d6794dc6830d8797195_Out_2_Float);
            float _Property_dfa3069e428d48c2a00288fb727d87aa_Out_0_Float = _TorchNoiseStrength;
            float _Split_73f51655f05748e9bafdfa82c53a6756_R_1_Float = IN.WorldSpacePosition[0];
            float _Split_73f51655f05748e9bafdfa82c53a6756_G_2_Float = IN.WorldSpacePosition[1];
            float _Split_73f51655f05748e9bafdfa82c53a6756_B_3_Float = IN.WorldSpacePosition[2];
            float _Split_73f51655f05748e9bafdfa82c53a6756_A_4_Float = 0;
            float _Property_2af28184bb9342ae91b1f54e7e73c995_Out_0_Float = _Noise_Speed;
            float _Multiply_ac67735ad1e642988ed3ce9b37d72d0a_Out_2_Float;
            Unity_Multiply_float_float(_Property_2af28184bb9342ae91b1f54e7e73c995_Out_0_Float, IN.TimeParameters.x, _Multiply_ac67735ad1e642988ed3ce9b37d72d0a_Out_2_Float);
            float3 _Vector3_1b110a8e5c6d410db18c670e3000b981_Out_0_Vector3 = float3(_Split_73f51655f05748e9bafdfa82c53a6756_R_1_Float, _Split_73f51655f05748e9bafdfa82c53a6756_G_2_Float, _Multiply_ac67735ad1e642988ed3ce9b37d72d0a_Out_2_Float);
            float _Property_e46a47d2ad964f1991ec5f4f47ba0e4c_Out_0_Float = _Warp_Scale;
            Bindings_Voronoinoise3D_92001a1a051ec8247a12e151ca32427b_float _Voronoinoise3D_de2a85142ed344d0a735380b5b3964b9;
            float _Voronoinoise3D_de2a85142ed344d0a735380b5b3964b9_Value_1_Float;
            float _Voronoinoise3D_de2a85142ed344d0a735380b5b3964b9_Cells_2_Float;
            SG_Voronoinoise3D_92001a1a051ec8247a12e151ca32427b_float(_Vector3_1b110a8e5c6d410db18c670e3000b981_Out_0_Vector3, float(10), _Property_e46a47d2ad964f1991ec5f4f47ba0e4c_Out_0_Float, _Voronoinoise3D_de2a85142ed344d0a735380b5b3964b9, _Voronoinoise3D_de2a85142ed344d0a735380b5b3964b9_Value_1_Float, _Voronoinoise3D_de2a85142ed344d0a735380b5b3964b9_Cells_2_Float);
            float _Property_2ae067af17f5451e8839bd295fd143da_Out_0_Float = _Warp_Strength;
            float _Multiply_a138b9bfcd6b4aafa72ec02a7e70affc_Out_2_Float;
            Unity_Multiply_float_float(_Voronoinoise3D_de2a85142ed344d0a735380b5b3964b9_Value_1_Float, _Property_2ae067af17f5451e8839bd295fd143da_Out_0_Float, _Multiply_a138b9bfcd6b4aafa72ec02a7e70affc_Out_2_Float);
            float3 _Add_5657652b57de46d59a3acf09df734a88_Out_2_Vector3;
            Unity_Add_float3(_Vector3_1b110a8e5c6d410db18c670e3000b981_Out_0_Vector3, (_Multiply_a138b9bfcd6b4aafa72ec02a7e70affc_Out_2_Float.xxx), _Add_5657652b57de46d59a3acf09df734a88_Out_2_Vector3);
            float _Property_47bf2f5b46d344768eedf93a37be6926_Out_0_Float = _Noise_Scale;
            Bindings_Simplexnoise3D_b3b7f0d9d78bece4587dc8496c4ed47b_float _Simplexnoise3D_22a26c000d084fac88791e2e272a3627;
            float _Simplexnoise3D_22a26c000d084fac88791e2e272a3627_Value_0_Float;
            SG_Simplexnoise3D_b3b7f0d9d78bece4587dc8496c4ed47b_float(_Add_5657652b57de46d59a3acf09df734a88_Out_2_Vector3, _Property_47bf2f5b46d344768eedf93a37be6926_Out_0_Float, _Simplexnoise3D_22a26c000d084fac88791e2e272a3627, _Simplexnoise3D_22a26c000d084fac88791e2e272a3627_Value_0_Float);
            float _Multiply_5d2a615d591846639a86f8c99ad1d74f_Out_2_Float;
            Unity_Multiply_float_float(_Simplexnoise3D_22a26c000d084fac88791e2e272a3627_Value_0_Float, 2, _Multiply_5d2a615d591846639a86f8c99ad1d74f_Out_2_Float);
            float _Multiply_435d201b79e84b93ba9550b17093a7a3_Out_2_Float;
            Unity_Multiply_float_float(_Property_dfa3069e428d48c2a00288fb727d87aa_Out_0_Float, _Multiply_5d2a615d591846639a86f8c99ad1d74f_Out_2_Float, _Multiply_435d201b79e84b93ba9550b17093a7a3_Out_2_Float);
            float _Subtract_c100a05a73374ad49444d48d36b9e8eb_Out_2_Float;
            Unity_Subtract_float(_Multiply_69a6ec8992034d6794dc6830d8797195_Out_2_Float, _Multiply_435d201b79e84b93ba9550b17093a7a3_Out_2_Float, _Subtract_c100a05a73374ad49444d48d36b9e8eb_Out_2_Float);
            float _Property_ae17d459cf4b4ab990efe381eea06168_Out_0_Float = _Threshold;
            float _Comparison_4f7234cc3f94421391353a7e6e0f5ba2_Out_2_Boolean;
            Unity_Comparison_Greater_float(_Subtract_c100a05a73374ad49444d48d36b9e8eb_Out_2_Float, _Property_ae17d459cf4b4ab990efe381eea06168_Out_0_Float, _Comparison_4f7234cc3f94421391353a7e6e0f5ba2_Out_2_Boolean);
            float _And_4fbdfcb10ecf498b9738783eeab3d100_Out_2_Boolean;
            Unity_And_float(_Property_2a75182591204a34887f8c0852a6d7c5_Out_0_Boolean, _Comparison_4f7234cc3f94421391353a7e6e0f5ba2_Out_2_Boolean, _And_4fbdfcb10ecf498b9738783eeab3d100_Out_2_Boolean);
            float _Branch_9b1eb1627cd34dab9ff125d0f7d8fe61_Out_3_Float;
            Unity_Branch_float(_And_4fbdfcb10ecf498b9738783eeab3d100_Out_2_Boolean, float(1), float(0), _Branch_9b1eb1627cd34dab9ff125d0f7d8fe61_Out_3_Float);
            float4 _Multiply_e4d7081d402f4f628e64811486134ac6_Out_2_Vector4;
            Unity_Multiply_float4_float4(_SampleTexture2D_f271227fcd0e4b51a6327802cec29d72_RGBA_0_Vector4, (_Branch_9b1eb1627cd34dab9ff125d0f7d8fe61_Out_3_Float.xxxx), _Multiply_e4d7081d402f4f628e64811486134ac6_Out_2_Vector4);
            float _Split_5694b20622c5400a95c05d1aad050fcd_R_1_Float = _Multiply_e4d7081d402f4f628e64811486134ac6_Out_2_Vector4[0];
            float _Split_5694b20622c5400a95c05d1aad050fcd_G_2_Float = _Multiply_e4d7081d402f4f628e64811486134ac6_Out_2_Vector4[1];
            float _Split_5694b20622c5400a95c05d1aad050fcd_B_3_Float = _Multiply_e4d7081d402f4f628e64811486134ac6_Out_2_Vector4[2];
            float _Split_5694b20622c5400a95c05d1aad050fcd_A_4_Float = _Multiply_e4d7081d402f4f628e64811486134ac6_Out_2_Vector4[3];
            surface.Alpha = _Split_5694b20622c5400a95c05d1aad050fcd_A_4_Float;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
        #if UNITY_ANY_INSTANCING_ENABLED
        #else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
        #endif
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
        #if VFX_USE_GRAPH_VALUES
            uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
            /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
        #endif
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
        
        
            output.WorldSpacePosition = input.positionWS;
        
            #if UNITY_UV_STARTS_AT_TOP
            #else
            #endif
        
        
            output.uv0 = input.texCoord0;
        #if UNITY_ANY_INSTANCING_ENABLED
        #else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
        #endif
            output.TimeParameters = _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/SelectionPickingPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }

// Stencil write pass: write 1 where sprite is visible (alpha > 0.5)
Pass {
    Name "StencilWriteVisible"
    Tags {}
    
    ColorMask 0
    ZWrite Off
    Cull Off
    
    Stencil {
        Ref 1
        Comp Always
        Pass Replace
    }
    
    HLSLPROGRAM
    #pragma target 4.0
    #pragma vertex vert_stencil
    #pragma fragment frag_stencil_visible
    
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
    
    TEXTURE2D(_MainTex); SAMPLER(sampler_MainTex);
    
    struct Attributes { float4 positionOS : POSITION; float2 uv : TEXCOORD0; };
    struct Varyings { float4 positionCS : SV_POSITION; float2 uv : TEXCOORD0; };
    
    Varyings vert_stencil(Attributes IN) {
        Varyings OUT;
        OUT.positionCS = TransformObjectToHClip(IN.positionOS.xyz);
        OUT.uv = IN.uv;
        return OUT;
    }
    
    float4 frag_stencil_visible(Varyings IN) : SV_Target {
        float4 col = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, IN.uv);
        clip(col.a - 0.001); // discard transparent pixels
        return float4(0,0,0,0);
    }
    ENDHLSL
}

// Stencil write pass: write 2 where sprite is transparent (alpha == 0)
Pass {
    Name "StencilWriteTransparent"
    Tags {}
    
    ColorMask 0
    ZWrite Off
    Cull Off
    
    Stencil {
        Ref 2
        Comp Always
        Pass Replace
    }
    
    HLSLPROGRAM
    #pragma target 4.0
    #pragma vertex vert_stencil
    #pragma fragment frag_stencil_transparent
    
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
    
    TEXTURE2D(_MainTex); SAMPLER(sampler_MainTex);
    
    struct Attributes { float4 positionOS : POSITION; float2 uv : TEXCOORD0; };
    struct Varyings { float4 positionCS : SV_POSITION; float2 uv : TEXCOORD0; };
    
    Varyings vert_stencil(Attributes IN) {
        Varyings OUT;
        OUT.positionCS = TransformObjectToHClip(IN.positionOS.xyz);
        OUT.uv = IN.uv;
        return OUT;
    }
    
    float4 frag_stencil_transparent(Varyings IN) : SV_Target {
        float4 col = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, IN.uv);
        clip(0.001 - col.a); // discard opaque pixels (keep only transparent)
        return float4(0,0,0,0);
    }
    ENDHLSL
}

        Pass
        {
            Name "Sprite Unlit"
            Tags
            {
                "LightMode" = "UniversalForward"
            }
        
        // Render State
        Cull Off
        Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
        ZTest LEqual
        ZTest LEqual
        ZTest LEqual
        ZTest LEqual
        ZTest LEqual
        ZTest LEqual
        ZTest LEqual
        ZTest LEqual
        ZTest LEqual
        ZTest LEqual
        ZWrite Off
        ZWrite Off
        ZWrite Off
        ZWrite Off
        ZWrite Off
        ZWrite On
        ZWrite On
        ZWrite On
        ZWrite Off
        ZWrite Off
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 2.0
        #pragma exclude_renderers d3d11_9x
        #pragma multi_compile_instancing
        #pragma vertex vert
        #pragma fragment frag
        
        // Keywords
        #pragma multi_compile_fragment _ DEBUG_DISPLAY
        #pragma multi_compile_vertex _ SKINNED_SPRITE
        // GraphKeywords: <None>
        
        // Defines
        
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define ATTRIBUTES_NEED_COLOR
        #define FEATURES_GRAPH_VERTEX_NORMAL_OUTPUT
        #define FEATURES_GRAPH_VERTEX_TANGENT_OUTPUT
        #define VARYINGS_NEED_POSITION_WS
        #define VARYINGS_NEED_NORMAL_WS
        #define VARYINGS_NEED_TEXCOORD0
        #define VARYINGS_NEED_COLOR
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_SPRITEFORWARD
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Fog.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/DebugMipmapStreamingMacros.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Shaders/2D/Include/Core2D.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv0 : TEXCOORD0;
             float4 color : COLOR;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(ATTRIBUTES_NEED_INSTANCEID)
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 positionWS;
             float3 normalWS;
             float4 texCoord0;
             float4 color;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float3 WorldSpacePosition;
             float4 uv0;
             float3 TimeParameters;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float4 texCoord0 : INTERP0;
             float4 color : INTERP1;
             float3 positionWS : INTERP2;
             float3 normalWS : INTERP3;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.texCoord0.xyzw = input.texCoord0;
            output.color.xyzw = input.color;
            output.positionWS.xyz = input.positionWS;
            output.normalWS.xyz = input.normalWS;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.texCoord0 = input.texCoord0.xyzw;
            output.color = input.color.xyzw;
            output.positionWS = input.positionWS.xyz;
            output.normalWS = input.normalWS.xyz;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _MainTex_TexelSize;
        float _Noise_Scale;
        float _TorchNoiseStrength;
        float _Noise_Speed;
        float _Threshold;
        float _Warp_Strength;
        float _Warp_Scale;
        float _Abberation_Intensity;
        float _Cutoff;
        UNITY_TEXTURE_STREAMING_DEBUG_VARS;
        CBUFFER_END
        
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_MainTex);
        SAMPLER(sampler_MainTex);
        float2 _TorchWorldPos;
        float2 _TorchPointDir;
        float _ConeAngle;
        float _TorchEnabled;
        
        // Graph Includes
        #include_with_pragmas "Packages/com.jimmycushnie.noisynodes/NoiseShader/HLSL/Voronoi3D.hlsl"
        #include_with_pragmas "Packages/com.jimmycushnie.noisynodes/NoiseShader/HLSL/SimplexNoise3D.hlsl"
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Subtract_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A - B;
        }
        
        void Unity_Length_float4(float4 In, out float Out)
        {
            Out = length(In);
        }
        
        void Unity_Step_float(float Edge, float In, out float Out)
        {
            Out = step(Edge, In);
        }
        
        void Unity_Subtract_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A - B;
        }
        
        void Unity_DotProduct_float2(float2 A, float2 B, out float Out)
        {
            Out = dot(A, B);
        }
        
        void Unity_Length_float2(float2 In, out float Out)
        {
            Out = length(In);
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }
        
        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }
        
        void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }
        
        struct Bindings_Voronoinoise3D_92001a1a051ec8247a12e151ca32427b_float
        {
        };
        
        void SG_Voronoinoise3D_92001a1a051ec8247a12e151ca32427b_float(float3 Vector3_375394F7, float Vector1_B47BD908, float Vector1_AEE7F28E, Bindings_Voronoinoise3D_92001a1a051ec8247a12e151ca32427b_float IN, out float Value_1, out float Cells_2)
        {
        float3 _Property_c0874fd2920f9c8baf4b91be875c7ebb_Out_0_Vector3 = Vector3_375394F7;
        float _Property_1d30cf63fc420f8f99a0cbe60bb88392_Out_0_Float = Vector1_B47BD908;
        float _Property_01df2bf4a6ebe48c8c34049cb8b5c130_Out_0_Float = Vector1_AEE7F28E;
        float _Voronoi3DCustomFunction_f3778cac851e5b82b5979141914b8445_Value_3_Float;
        float _Voronoi3DCustomFunction_f3778cac851e5b82b5979141914b8445_Cells_4_Float;
        Voronoi3D_float(_Property_c0874fd2920f9c8baf4b91be875c7ebb_Out_0_Vector3, _Property_1d30cf63fc420f8f99a0cbe60bb88392_Out_0_Float, _Property_01df2bf4a6ebe48c8c34049cb8b5c130_Out_0_Float, _Voronoi3DCustomFunction_f3778cac851e5b82b5979141914b8445_Value_3_Float, _Voronoi3DCustomFunction_f3778cac851e5b82b5979141914b8445_Cells_4_Float);
        Value_1 = _Voronoi3DCustomFunction_f3778cac851e5b82b5979141914b8445_Value_3_Float;
        Cells_2 = _Voronoi3DCustomFunction_f3778cac851e5b82b5979141914b8445_Cells_4_Float;
        }
        
        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
        }
        
        void Unity_Multiply_float3_float3(float3 A, float3 B, out float3 Out)
        {
        Out = A * B;
        }
        
        struct Bindings_Simplexnoise3D_b3b7f0d9d78bece4587dc8496c4ed47b_float
        {
        };
        
        void SG_Simplexnoise3D_b3b7f0d9d78bece4587dc8496c4ed47b_float(float3 Vector3_7940555B, float Vector1_D4A5C52D, Bindings_Simplexnoise3D_b3b7f0d9d78bece4587dc8496c4ed47b_float IN, out float Value_0)
        {
        float3 _Property_44999cc87708de82a26b39ae1da975ec_Out_0_Vector3 = Vector3_7940555B;
        float _Property_31805413f7564f8da25bf75c2a6983b0_Out_0_Float = Vector1_D4A5C52D;
        float3 _Multiply_1d17f1db9ddb2d8481679237f2442ac2_Out_2_Vector3;
        Unity_Multiply_float3_float3(_Property_44999cc87708de82a26b39ae1da975ec_Out_0_Vector3, (_Property_31805413f7564f8da25bf75c2a6983b0_Out_0_Float.xxx), _Multiply_1d17f1db9ddb2d8481679237f2442ac2_Out_2_Vector3);
        float _SimplexNoise3DCustomFunction_1d714aea6ba122808f5efcabfce18252_Out_1_Float;
        SimplexNoise3D_float(_Multiply_1d17f1db9ddb2d8481679237f2442ac2_Out_2_Vector3, _SimplexNoise3DCustomFunction_1d714aea6ba122808f5efcabfce18252_Out_1_Float);
        float _Remap_4e5d05a6e861b582b5e910962a3ffd60_Out_3_Float;
        Unity_Remap_float(_SimplexNoise3DCustomFunction_1d714aea6ba122808f5efcabfce18252_Out_1_Float, float2 (-1, 1), float2 (0, 1), _Remap_4e5d05a6e861b582b5e910962a3ffd60_Out_3_Float);
        Value_0 = _Remap_4e5d05a6e861b582b5e910962a3ffd60_Out_3_Float;
        }
        
        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }
        
        void Unity_Comparison_Greater_float(float A, float B, out float Out)
        {
            Out = A > B ? 1 : 0;
        }
        
        void Unity_And_float(float A, float B, out float Out)
        {
            Out = A && B;
        }
        
        void Unity_Branch_float(float Predicate, float True, float False, out float Out)
        {
            Out = Predicate ? True : False;
        }
        
        void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float3 BaseColor;
            float Alpha;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            UnityTexture2D _Property_9da0b2bc8c884590abd2996a28f14783_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_MainTex);
            float4 _SampleTexture2D_f271227fcd0e4b51a6327802cec29d72_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_9da0b2bc8c884590abd2996a28f14783_Out_0_Texture2D.tex, _Property_9da0b2bc8c884590abd2996a28f14783_Out_0_Texture2D.samplerstate, _Property_9da0b2bc8c884590abd2996a28f14783_Out_0_Texture2D.GetTransformedUV(IN.uv0.xy) );
            float _SampleTexture2D_f271227fcd0e4b51a6327802cec29d72_R_4_Float = _SampleTexture2D_f271227fcd0e4b51a6327802cec29d72_RGBA_0_Vector4.r;
            float _SampleTexture2D_f271227fcd0e4b51a6327802cec29d72_G_5_Float = _SampleTexture2D_f271227fcd0e4b51a6327802cec29d72_RGBA_0_Vector4.g;
            float _SampleTexture2D_f271227fcd0e4b51a6327802cec29d72_B_6_Float = _SampleTexture2D_f271227fcd0e4b51a6327802cec29d72_RGBA_0_Vector4.b;
            float _SampleTexture2D_f271227fcd0e4b51a6327802cec29d72_A_7_Float = _SampleTexture2D_f271227fcd0e4b51a6327802cec29d72_RGBA_0_Vector4.a;
            float _Property_2a75182591204a34887f8c0852a6d7c5_Out_0_Boolean = _TorchEnabled;
            float _Property_b235dec23c7244ee96802a2291b1ecd2_Out_0_Float = _Cutoff;
            float4 _UV_44cb21489bee4382b69b741257b9b83c_Out_0_Vector4 = IN.uv0;
            float4 _Subtract_2437e7a503d248449d7aa4baa1aeda12_Out_2_Vector4;
            Unity_Subtract_float4(_UV_44cb21489bee4382b69b741257b9b83c_Out_0_Vector4, float4(0.5, 0.5, 1, 1), _Subtract_2437e7a503d248449d7aa4baa1aeda12_Out_2_Vector4);
            float _Length_e1f9513bf75a4e9e9dbeeed7c69964b1_Out_1_Float;
            Unity_Length_float4(_Subtract_2437e7a503d248449d7aa4baa1aeda12_Out_2_Vector4, _Length_e1f9513bf75a4e9e9dbeeed7c69964b1_Out_1_Float);
            float _Step_7c5418391b9c49248e4bc367843fa597_Out_2_Float;
            Unity_Step_float(_Property_b235dec23c7244ee96802a2291b1ecd2_Out_0_Float, _Length_e1f9513bf75a4e9e9dbeeed7c69964b1_Out_1_Float, _Step_7c5418391b9c49248e4bc367843fa597_Out_2_Float);
            float2 _Property_7033a961d17048b0ab681ea9a8de15dd_Out_0_Vector2 = _TorchWorldPos;
            float2 _Subtract_53cbbd021eb04323905291953ce2bf0b_Out_2_Vector2;
            Unity_Subtract_float2((IN.WorldSpacePosition.xy), _Property_7033a961d17048b0ab681ea9a8de15dd_Out_0_Vector2, _Subtract_53cbbd021eb04323905291953ce2bf0b_Out_2_Vector2);
            float2 _Property_3f205fc181f74ccbb4158016995d0d6f_Out_0_Vector2 = _TorchPointDir;
            float _DotProduct_98b628519f13442ca29c540730032133_Out_2_Float;
            Unity_DotProduct_float2(_Subtract_53cbbd021eb04323905291953ce2bf0b_Out_2_Vector2, _Property_3f205fc181f74ccbb4158016995d0d6f_Out_0_Vector2, _DotProduct_98b628519f13442ca29c540730032133_Out_2_Float);
            float _Length_9d91b71764ca46d5a6d4f0cfa754d2bb_Out_1_Float;
            Unity_Length_float2(_Subtract_53cbbd021eb04323905291953ce2bf0b_Out_2_Vector2, _Length_9d91b71764ca46d5a6d4f0cfa754d2bb_Out_1_Float);
            float _Length_9a332ec75df64ba992de1c2b3dd39e3a_Out_1_Float;
            Unity_Length_float2(_Property_3f205fc181f74ccbb4158016995d0d6f_Out_0_Vector2, _Length_9a332ec75df64ba992de1c2b3dd39e3a_Out_1_Float);
            float _Multiply_24b3d100c67d40a693a4182ef01451ee_Out_2_Float;
            Unity_Multiply_float_float(_Length_9d91b71764ca46d5a6d4f0cfa754d2bb_Out_1_Float, _Length_9a332ec75df64ba992de1c2b3dd39e3a_Out_1_Float, _Multiply_24b3d100c67d40a693a4182ef01451ee_Out_2_Float);
            float _Divide_a91708cba40243e08d4219249db86c65_Out_2_Float;
            Unity_Divide_float(_DotProduct_98b628519f13442ca29c540730032133_Out_2_Float, _Multiply_24b3d100c67d40a693a4182ef01451ee_Out_2_Float, _Divide_a91708cba40243e08d4219249db86c65_Out_2_Float);
            float _Property_7e8351790b1945e3bedb4ed0ce5af20e_Out_0_Float = _ConeAngle;
            float _Property_7e4150e0dd7b4a15b2c7c9d48cbe0987_Out_0_Float = _ConeAngle;
            float _Add_12bf6727cd124131a5ac7e2844aea423_Out_2_Float;
            Unity_Add_float(_Property_7e4150e0dd7b4a15b2c7c9d48cbe0987_Out_0_Float, float(0.1), _Add_12bf6727cd124131a5ac7e2844aea423_Out_2_Float);
            float2 _Vector2_10b46480a0894d3b998ae1fa779a5ff4_Out_0_Vector2 = float2(_Property_7e8351790b1945e3bedb4ed0ce5af20e_Out_0_Float, _Add_12bf6727cd124131a5ac7e2844aea423_Out_2_Float);
            float _Remap_724e812769644b63a2060d37e7afbdae_Out_3_Float;
            Unity_Remap_float(_Divide_a91708cba40243e08d4219249db86c65_Out_2_Float, _Vector2_10b46480a0894d3b998ae1fa779a5ff4_Out_0_Vector2, float2 (0, 1), _Remap_724e812769644b63a2060d37e7afbdae_Out_3_Float);
            float _Multiply_69a6ec8992034d6794dc6830d8797195_Out_2_Float;
            Unity_Multiply_float_float(_Step_7c5418391b9c49248e4bc367843fa597_Out_2_Float, _Remap_724e812769644b63a2060d37e7afbdae_Out_3_Float, _Multiply_69a6ec8992034d6794dc6830d8797195_Out_2_Float);
            float _Property_dfa3069e428d48c2a00288fb727d87aa_Out_0_Float = _TorchNoiseStrength;
            float _Split_73f51655f05748e9bafdfa82c53a6756_R_1_Float = IN.WorldSpacePosition[0];
            float _Split_73f51655f05748e9bafdfa82c53a6756_G_2_Float = IN.WorldSpacePosition[1];
            float _Split_73f51655f05748e9bafdfa82c53a6756_B_3_Float = IN.WorldSpacePosition[2];
            float _Split_73f51655f05748e9bafdfa82c53a6756_A_4_Float = 0;
            float _Property_2af28184bb9342ae91b1f54e7e73c995_Out_0_Float = _Noise_Speed;
            float _Multiply_ac67735ad1e642988ed3ce9b37d72d0a_Out_2_Float;
            Unity_Multiply_float_float(_Property_2af28184bb9342ae91b1f54e7e73c995_Out_0_Float, IN.TimeParameters.x, _Multiply_ac67735ad1e642988ed3ce9b37d72d0a_Out_2_Float);
            float3 _Vector3_1b110a8e5c6d410db18c670e3000b981_Out_0_Vector3 = float3(_Split_73f51655f05748e9bafdfa82c53a6756_R_1_Float, _Split_73f51655f05748e9bafdfa82c53a6756_G_2_Float, _Multiply_ac67735ad1e642988ed3ce9b37d72d0a_Out_2_Float);
            float _Property_e46a47d2ad964f1991ec5f4f47ba0e4c_Out_0_Float = _Warp_Scale;
            Bindings_Voronoinoise3D_92001a1a051ec8247a12e151ca32427b_float _Voronoinoise3D_de2a85142ed344d0a735380b5b3964b9;
            float _Voronoinoise3D_de2a85142ed344d0a735380b5b3964b9_Value_1_Float;
            float _Voronoinoise3D_de2a85142ed344d0a735380b5b3964b9_Cells_2_Float;
            SG_Voronoinoise3D_92001a1a051ec8247a12e151ca32427b_float(_Vector3_1b110a8e5c6d410db18c670e3000b981_Out_0_Vector3, float(10), _Property_e46a47d2ad964f1991ec5f4f47ba0e4c_Out_0_Float, _Voronoinoise3D_de2a85142ed344d0a735380b5b3964b9, _Voronoinoise3D_de2a85142ed344d0a735380b5b3964b9_Value_1_Float, _Voronoinoise3D_de2a85142ed344d0a735380b5b3964b9_Cells_2_Float);
            float _Property_2ae067af17f5451e8839bd295fd143da_Out_0_Float = _Warp_Strength;
            float _Multiply_a138b9bfcd6b4aafa72ec02a7e70affc_Out_2_Float;
            Unity_Multiply_float_float(_Voronoinoise3D_de2a85142ed344d0a735380b5b3964b9_Value_1_Float, _Property_2ae067af17f5451e8839bd295fd143da_Out_0_Float, _Multiply_a138b9bfcd6b4aafa72ec02a7e70affc_Out_2_Float);
            float3 _Add_5657652b57de46d59a3acf09df734a88_Out_2_Vector3;
            Unity_Add_float3(_Vector3_1b110a8e5c6d410db18c670e3000b981_Out_0_Vector3, (_Multiply_a138b9bfcd6b4aafa72ec02a7e70affc_Out_2_Float.xxx), _Add_5657652b57de46d59a3acf09df734a88_Out_2_Vector3);
            float _Property_47bf2f5b46d344768eedf93a37be6926_Out_0_Float = _Noise_Scale;
            Bindings_Simplexnoise3D_b3b7f0d9d78bece4587dc8496c4ed47b_float _Simplexnoise3D_22a26c000d084fac88791e2e272a3627;
            float _Simplexnoise3D_22a26c000d084fac88791e2e272a3627_Value_0_Float;
            SG_Simplexnoise3D_b3b7f0d9d78bece4587dc8496c4ed47b_float(_Add_5657652b57de46d59a3acf09df734a88_Out_2_Vector3, _Property_47bf2f5b46d344768eedf93a37be6926_Out_0_Float, _Simplexnoise3D_22a26c000d084fac88791e2e272a3627, _Simplexnoise3D_22a26c000d084fac88791e2e272a3627_Value_0_Float);
            float _Multiply_5d2a615d591846639a86f8c99ad1d74f_Out_2_Float;
            Unity_Multiply_float_float(_Simplexnoise3D_22a26c000d084fac88791e2e272a3627_Value_0_Float, 2, _Multiply_5d2a615d591846639a86f8c99ad1d74f_Out_2_Float);
            float _Multiply_435d201b79e84b93ba9550b17093a7a3_Out_2_Float;
            Unity_Multiply_float_float(_Property_dfa3069e428d48c2a00288fb727d87aa_Out_0_Float, _Multiply_5d2a615d591846639a86f8c99ad1d74f_Out_2_Float, _Multiply_435d201b79e84b93ba9550b17093a7a3_Out_2_Float);
            float _Subtract_c100a05a73374ad49444d48d36b9e8eb_Out_2_Float;
            Unity_Subtract_float(_Multiply_69a6ec8992034d6794dc6830d8797195_Out_2_Float, _Multiply_435d201b79e84b93ba9550b17093a7a3_Out_2_Float, _Subtract_c100a05a73374ad49444d48d36b9e8eb_Out_2_Float);
            float _Property_ae17d459cf4b4ab990efe381eea06168_Out_0_Float = _Threshold;
            float _Comparison_4f7234cc3f94421391353a7e6e0f5ba2_Out_2_Boolean;
            Unity_Comparison_Greater_float(_Subtract_c100a05a73374ad49444d48d36b9e8eb_Out_2_Float, _Property_ae17d459cf4b4ab990efe381eea06168_Out_0_Float, _Comparison_4f7234cc3f94421391353a7e6e0f5ba2_Out_2_Boolean);
            float _And_4fbdfcb10ecf498b9738783eeab3d100_Out_2_Boolean;
            Unity_And_float(_Property_2a75182591204a34887f8c0852a6d7c5_Out_0_Boolean, _Comparison_4f7234cc3f94421391353a7e6e0f5ba2_Out_2_Boolean, _And_4fbdfcb10ecf498b9738783eeab3d100_Out_2_Boolean);
            float _Branch_9b1eb1627cd34dab9ff125d0f7d8fe61_Out_3_Float;
            Unity_Branch_float(_And_4fbdfcb10ecf498b9738783eeab3d100_Out_2_Boolean, float(1), float(0), _Branch_9b1eb1627cd34dab9ff125d0f7d8fe61_Out_3_Float);
            float4 _Multiply_e4d7081d402f4f628e64811486134ac6_Out_2_Vector4;
            Unity_Multiply_float4_float4(_SampleTexture2D_f271227fcd0e4b51a6327802cec29d72_RGBA_0_Vector4, (_Branch_9b1eb1627cd34dab9ff125d0f7d8fe61_Out_3_Float.xxxx), _Multiply_e4d7081d402f4f628e64811486134ac6_Out_2_Vector4);
            float _Split_5694b20622c5400a95c05d1aad050fcd_R_1_Float = _Multiply_e4d7081d402f4f628e64811486134ac6_Out_2_Vector4[0];
            float _Split_5694b20622c5400a95c05d1aad050fcd_G_2_Float = _Multiply_e4d7081d402f4f628e64811486134ac6_Out_2_Vector4[1];
            float _Split_5694b20622c5400a95c05d1aad050fcd_B_3_Float = _Multiply_e4d7081d402f4f628e64811486134ac6_Out_2_Vector4[2];
            float _Split_5694b20622c5400a95c05d1aad050fcd_A_4_Float = _Multiply_e4d7081d402f4f628e64811486134ac6_Out_2_Vector4[3];
            surface.BaseColor = (_Multiply_e4d7081d402f4f628e64811486134ac6_Out_2_Vector4.xyz);
            surface.Alpha = _Split_5694b20622c5400a95c05d1aad050fcd_A_4_Float;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
        #if UNITY_ANY_INSTANCING_ENABLED
        #else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
        #endif
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
        #if VFX_USE_GRAPH_VALUES
            uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
            /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
        #endif
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
        
        
            output.WorldSpacePosition = input.positionWS;
        
            #if UNITY_UV_STARTS_AT_TOP
            #else
            #endif
        
        
            output.uv0 = input.texCoord0;
        #if UNITY_ANY_INSTANCING_ENABLED
        #else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
        #endif
            output.TimeParameters = _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/2D/ShaderGraph/Includes/SpriteUnlitPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
    }
    CustomEditor "UnityEditor.ShaderGraph.GenericShaderGraphMaterialGUI"
    CustomEditorForRenderPipeline "UnityEditor.ShaderGraphSpriteGUI" "UnityEngine.Rendering.Universal.UniversalRenderPipelineAsset"
    FallBack "Hidden/Shader Graph/FallbackError"
}