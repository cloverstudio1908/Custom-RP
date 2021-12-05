using System;
using UnityEngine;

[Serializable]
public class ShadowSettings
{
    public enum TextureSize
    {
        _512 = 512,
        _1024 = 1024,
    }

    [Serializable]
    public struct Directional
    {
        public TextureSize atlasSize;
    }

    [Min(0f)]
    public float maxDistance = 100f;
    public Directional directional = new Directional()
    {
        atlasSize = TextureSize._1024,
    };
}
