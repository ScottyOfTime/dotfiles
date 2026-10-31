#version 300 es
// the whole screen as a crt: phosphor bloom, scanlines, a soft vignette
precision highp float;

in vec2 v_texcoord;
uniform sampler2D tex;
out vec4 fragColor;

void main() {
    vec2 px = 1.0 / vec2(textureSize(tex, 0));
    vec3 colour = texture(tex, v_texcoord).rgb;

    vec3 glow = vec3(0.0);
    for (int x = -1; x <= 1; x++)
        for (int y = -1; y <= 1; y++)
            glow += texture(tex, v_texcoord + vec2(x, y) * px * 2.0).rgb;
    glow /= 9.0;
    // light bleeds from bright pixels into darker neighbours only, so
    // text halos without washing out large light areas
    colour += max(glow - colour, 0.0) * 0.6;

    // a dark line every third physical row
    float scan = 0.5 + 0.5 * cos(gl_FragCoord.y * 2.0943951);
    colour *= mix(1.0, 0.8, scan);

    vec2 centred = v_texcoord * 2.0 - 1.0;
    colour *= mix(0.72, 1.0, smoothstep(1.45, 0.55, length(centred)));

    fragColor = vec4(colour * 1.06, 1.0);
}
