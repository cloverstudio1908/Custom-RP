#ifndef CUSTOM_LIGHTING_INCLUDED
#define CUSTOM_LIGHTING_INCLUDED

float3 GetLighting(Surface surface, BRDF brdf)
{
    Light light = DirectionLight();    
    return (saturate(dot(surface.normal, light.direction)) * light.color) * DirectBRDF(surface, brdf, light);
}

#endif