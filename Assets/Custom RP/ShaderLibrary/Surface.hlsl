#ifndef CUSTOM_SURFACE_INCLUDED
#define CUSTOM_SURFACE_INCLUDED

struct Surface
{
    float3 normal;
    float3 viewDir;
    float3 color;
    float metallic;
    float smoothness;
};

#endif