#ifndef CUSTOM_LIGHT_INCLUDED
#define CUSTOM_LIGHT_INCLUDED

CBUFFER_START(_CustomLight)
    float3 _LightDir0;
    float3 _LightColor0;
CBUFFER_END

struct Light
{    
    float3 direction;
    float3 color;
};

Light DirectionLight()
{
    Light light;    
    light.direction = _LightDir0;    
    light.color = _LightColor0;
    return light;
}

#endif