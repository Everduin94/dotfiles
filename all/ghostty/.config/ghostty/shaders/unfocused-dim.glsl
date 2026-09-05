// Reduce contrast by 12% when this Ghostty surface is not focused.
void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = fragCoord / iResolution.xy;
    vec4 terminal = texture2D(iChannel0, uv);

    if (iFocus == 0) {
        terminal.rgb = mix(terminal.rgb, iBackgroundColor, 0.12);
    }

    fragColor = terminal;
}
