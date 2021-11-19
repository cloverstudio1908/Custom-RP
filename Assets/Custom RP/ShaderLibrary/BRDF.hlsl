#ifndef CUSTOM_BRDF_INCLUDED
#define CUSTOM_BRDF_INCLUDED

#define MIN_REFLECTIVITY 0.04

struct BRDF
{
    float3 diffuse;
    float3 specular;
    float roughness;
};

float Square(float v)
{
    return v * v;
}

float SpecularStrength(Surface surface, BRDF brdf, Light light)
{
    float3 h = SafeNormalize(light.direction + surface.viewDir);
    float nh2 = Square(saturate(dot(surface.normal, h)));
    float r2 = Square(brdf.roughness);
    float d2 = Square(nh2 * (r2 - 1.0) + 1.00001);
    float lh2 = Square(saturate(dot(light.direction, h)));
    float n = 4.0 * brdf.roughness + 2.0;
    return r2 / (d2 * max(0.1, lh2) * n);
}

float OneMinusReflectivity(float metallic)
{
    float range = 1.0 - MIN_REFLECTIVITY;
    return range * (1 - metallic);
}

BRDF GetBRDF(Surface surface)
{
    BRDF brdf;
    float oneMinusReflectivity = OneMinusReflectivity(surface.metallic);
    brdf.diffuse = surface.color * oneMinusReflectivity;
    brdf.specular = surface.color - brdf.diffuse;
    float perceptualRoughness = PerceptualSmoothnessToPerceptualRoughness(surface.smoothness);    
    brdf.roughness = PerceptualRoughnessToRoughness(perceptualRoughness);

    return brdf;
}

float3 DirectBRDF(Surface surface, BRDF brdf, Light light)
{
    return SpecularStrength(surface, brdf, light) * brdf.specular + brdf.diffuse;
}

#endif