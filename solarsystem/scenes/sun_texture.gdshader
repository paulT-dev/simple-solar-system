shader_type spatial;
render_mode unshaded, cull_back; // Eigenleuchten, keine PBR-Schattierung

uniform sampler2D noise_tex : source_color;
uniform vec3 base_color : source_color = vec3(1.0, 0.85, 0.4);
uniform float emission_strength : hint_range(0.0, 20.0) = 6.0;

// Muster-Parameter
uniform float time_scale = 0.15;    // Animationsgeschwindigkeit
uniform float granularity = 12.0;   // „Körnigkeit“ (Skalierung der Noise)
uniform float turbulence = 0.6;     // Anteil höherer Oktaven
uniform float spots = 0.28;         // Sonnenflecken-Intensität (dunkle Inseln)

// Rand-/Glüheffekte
uniform float limb_darkening = 0.55; // Randabdunklung (0..1)
uniform float rim_power = 2.2;       // Schärfe der Corona

// Hilfsfunktion: 2D-FBm aus Noise-Textur
float fbm(vec2 p) {
    float a = 0.0;
    float w = 0.5;
    for (int i = 0; i < 5; i++) {
        a += w * texture(noise_tex, p).r;
        p *= 2.0;
        w *= turbulence;
    }
    return a;
}

void fragment() {
    // UV der Kugel leicht kacheln + animieren
    vec2 uv = UV * granularity;
    uv += vec2(TIME * time_scale, TIME * 0.5 * time_scale);

    // Granulationsmuster
    float n = fbm(uv);

    // Sonnenflecken (dunkle Bereiche durch weiches Threshold)
    float spot_mask = smoothstep(spots, spots + 0.1, n); // 0->dunkel, 1->hell
    float surface = mix(0.6, 1.0, spot_mask);            // etwas abdunkeln

    // Randabdunklung (Limb darkening) & Corona-Randglühen
    // Rim = Nähe zum Rand (abhängig von Blickrichtung vs. Normalen)
    float rim = 1.0 - max(0.0, dot(NORMAL, VIEW));
    float limb = mix(1.0 - limb_darkening, 1.0, pow(1.0 - rim, 1.5));
    float corona = pow(rim, rim_power) * 0.8;

    vec3 col = base_color;

    // Emission: Grundemission * Oberfläche * Limb + Randglühen (Corona)
    vec3 emi = col * emission_strength * surface * limb + col * corona;

    EMISSION = emi;
    ALBEDO = col; // nur falls du unshaded mal ausschaltest
}