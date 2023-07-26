//
//  C7Kuwahara.metal
//  ATMetalBand
//
//  Created by Condy on 2022/2/14.
//

#include <metal_stdlib>
using namespace metal;

kernel void C7Kuwahara(texture2d<half, access::write> outputTexture [[texture(0)]],
                       texture2d<half, access::sample> inputTexture [[texture(1)]],
                       constant int *radiusPointer [[buffer(0)]],
                       uint2 grid [[thread_position_in_grid]]) {
    constexpr sampler quadSampler(mag_filter::linear, min_filter::linear);
    
    float2 uv = float2(float(grid.x) / outputTexture.get_width(), float(grid.y) / outputTexture.get_height());
    int radius = *radiusPointer;
    float n = float((radius + 1) * (radius + 1));
    int i; int j;
    float3 m0 = float3(0.0); float3 m1 = float3(0.0); float3 m2 = float3(0.0); float3 m3 = float3(0.0);
    float3 s0 = float3(0.0); float3 s1 = float3(0.0); float3 s2 = float3(0.0); float3 s3 = float3(0.0);
    float3 c;
    
    const float2 src_size = float2(1.0 / 768.0, 1.0 / 1024.0);
    
    for (j = -radius; j <= 0; ++j)  {
        for (i = -radius; i <= 0; ++i)  {
            c = float3(inputTexture.sample(quadSampler, uv + float2(i, j) * src_size).rgb);
            m0 += c;
            s0 += c * c;
        }
    }
    
    for (j = -radius; j <= 0; ++j)  {
        for (i = 0; i <= radius; ++i)  {
            c = float3(inputTexture.sample(quadSampler, uv + float2(i, j) * src_size).rgb);
            m1 += c;
            s1 += c * c;
        }
    }
    
    for (j = 0; j <= radius; ++j)  {
        for (i = 0; i <= radius; ++i)  {
            c = float3(inputTexture.sample(quadSampler, uv + float2(i, j) * src_size).rgb);
            m2 += c;
            s2 += c * c;
        }
    }
    
    for (j = 0; j <= radius; ++j)  {
        for (i = -radius; i <= 0; ++i)  {
            c = float3(inputTexture.sample(quadSampler, uv + float2(i, j) * src_size).rgb);
            m3 += c;
            s3 += c * c;
        }
    }
    
    float min_sigma2 = 1e+2;
    m0 /= n;
    s0 = abs(s0 / n - m0 * m0);
    
    float sigma2 = s0.r + s0.g + s0.b;
    if (sigma2 < min_sigma2) {
        min_sigma2 = sigma2;
        outputTexture.write(half4(half3(m0), 1), grid);
    }
    
    m1 /= n;
    s1 = abs(s1 / n - m1 * m1);
    
    sigma2 = s1.r + s1.g + s1.b;
    if (sigma2 < min_sigma2) {
        min_sigma2 = sigma2;
        outputTexture.write(half4(half3(m1), 1), grid);
    }
    
    m2 /= n;
    s2 = abs(s2 / n - m2 * m2);
    
    sigma2 = s2.r + s2.g + s2.b;
    if (sigma2 < min_sigma2) {
        min_sigma2 = sigma2;
        outputTexture.write(half4(half3(m2), 1), grid);
    }
    
    m3 /= n;
    s3 = abs(s3 / n - m3 * m3);
    
    sigma2 = s3.r + s3.g + s3.b;
    if (sigma2 < min_sigma2) {
        min_sigma2 = sigma2;
        outputTexture.write(half4(half3(m3), 1), grid);
    }
}
