// Функция генерации случайных значений
float2 random2(float2 c) {
    float j = 4096.0 * sin(dot(c, float2(17.0, 59.4)));
    float2 r;
    r.x = frac(512.0 * j);
    j *= 0.125;
    r.y = frac(512.0 * j);
    return r - 0.5;
}

// Константы для простого шума
const float F2 = 0.5; // Константа для 2D
const float G2 = 0.25; // Константа для 2D

// Функция простого 2D шума
float simplex2d(float2 p) {
    float2 s = floor(p + dot(p, float2(F2)));
    float2 x = p - s + dot(s, float2(G2));
    
    float2 e = step(float2(0.0), x - x.y);
    float2 i1 = e * (1.0 - e.yx);
    float2 i2 = 1.0 - e.yx * (1.0 - e);
    
    float2 x1 = x - i1 + G2;
    float2 x2 = x - i2 + 2.0 * G2;
    
    float4 w, d;
    w.x = dot(x, x);
    w.y = dot(x1, x1);
    w.z = dot(x2, x2);
    
    w = max(0.6 - w, 0.0);
    
    d.x = dot(random2(s), x);
    d.y = dot(random2(s + i1), x1);
    d.z = dot(random2(s + i2), x2);
    
    w *= w;
    w *= w;
    d *= w;
    
    return dot(d, float4(52.0));
}

// Функция фрактального шума
float simplex2d_fractal(float2 m) {
    return 0.5333333 * simplex2d(m * float2(-0.37, 0.36))
         + 0.2666667 * simplex2d(2.0 * m * float2(-0.55, -0.39))
         + 0.1333333 * simplex2d(4.0 * m * float2(-0.71, 0.52))
         + 0.0666667 * simplex2d(8.0 * m);
}

// Основная функция, вызываемая из Shader Graph
void CustomFunction(float3 vertexNormalInput, float time, out float4 fragColor) {
    // Используем swizzle для получения 2D координат
    float2 p2 = vertexNormalInput.xy + float2(0.0, time * 0.025); // Добавляем время для анимации
    
    float value;
    
    // Используем 2D координаты для генерации шума
    if (vertexNormalInput.x <= 0.6) {
        value = simplex2d(p2 * 32.0);
    } else {
        value = simplex2d_fractal(p2 * 8.0 + 8.0);
    }
    
    value = 0.5 + 0.5 * value;
    value *= smoothstep(0.0, 0.005, abs(0.6 - vertexNormalInput.x));
    
    fragColor = float4(value, value, value, 1.0);
}