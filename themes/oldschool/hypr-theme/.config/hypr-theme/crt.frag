#version 300 es
// the whole screen as a crt: phosphor bloom, scanlines, a soft vignette
precision highp float;

in vec2 v_texcoord;
uniform sampler2D tex;
out vec4 fragColor;

void main() {
    vec2 px = 1.0 / vec2(textureSize(tex, 0));
    vec3 colour = texture(tex, v_texcoord).rgb;

    // a soft falloff: one ring of taps at a fixed distance draws a hard
    // outline around anything that changes brightness, like hover states
    vec3 glow = vec3(0.0);
    float weight = 0.0;
    for (int x = -2; x <= 2; x++)
        for (int y = -2; y <= 2; y++) {
            float w = exp(-float(x * x + y * y) / 3.0);
            glow += texture(tex, v_texcoord + vec2(x, y) * px * 1.2).rgb * w;
            weight += w;
        }
    glow /= weight;
    // light bleeds from bright pixels into darker neighbours only, so
    // text halos without washing out large light areas
    colour += max(glow - colour, 0.0) * 0.35;

    // a dark line every third physical row
    float scan = 0.5 + 0.5 * cos(gl_FragCoord.y * 2.0943951);
    colour *= mix(1.0, 0.8, scan);

    vec2 centred = v_texcoord * 2.0 - 1.0;
    colour *= mix(0.72, 1.0, smoothstep(1.45, 0.55, length(centred)));

    fragColor = vec4(colour * 1.06, 1.0);
}
