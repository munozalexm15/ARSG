shader_type canvas_item;

#define iResolution 1.0 / SCREEN_PIXEL_SIZE
#define iTime TIME
#define fragColor COLOR
#define fragCoord FRAGCOORD

uniform sampler2D iChannel0;
uniform vec4 iMouse = vec4(0.);

// The MIT License
// Copyright © 2023 Gehtsiegarnixan
// Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions: The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software. THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
/*
This is a small trial to generate a feature similar to the Color Range Selection in 
Photoshop. The image shows the selected color from the image in the cursor, and then 
blends between this color and its inverse using the generated grayscale mask.

This shader has mouse controls that allow you to change the selected color using the 
mouse. Additionally, you can change the range and fuzziness of the selection in the 
global constants below, or set the target color directly.
*/

// how much deviation from the color is allowed that is still 100%
#define RANGE 0.1

// Softness of the fadout for the selected color
#define FUZZINESS 0.3

// Uncomment to use a specific color to isolate that may not be in the image
//#define REFERENCE_COLOR vec3(0.961,0.980,0.957)

// Generates a smooth mask of isolating a target color
float colorRange(vec3 pixelColor, vec3 targetColor, float range, float fuzziness) {
    // Calculate the Euclidean distance between pixelColor and targetColor
    float distance = length(pixelColor - targetColor);

    // Normalize the distance by the maximum possible distance
    float normalizedDistance = distance / sqrt(3.0);

    // Colors within Range become 1 and colors within Range+ Fuzziness fade to 0
    return smoothstep(range + fuzziness, range, normalizedDistance);
}

void fragment()
{
    // Normalized pixel coordinates (from 0 to 1)
    vec2 uv = UV;

    // Sample color Texture
    vec3 imageColor = texture(iChannel0, uv).xyz;
    
    #ifdef REFERENCE_COLOR
        // overwrite the reference color with a global constant
        vec3 referenceColor = REFERENCE_COLOR;
        
    #else
        // initilaize some variables 
        vec2 sampleCoords;
        vec2 cursor;
        
        // If the mouse was clicked, scale mouse coordinates to the 0-1 range of the screen
        if (iMouse.x > 0.0) {

            // set the sample position at mouse posiiton
            sampleCoords = iMouse.xy / iResolution.xy;
           
        } else {
            // If the mouse was not clicked, animate the direction vector
            float myTime = iTime * 0.05;
            sampleCoords = vec2(cos(myTime), sin(myTime))*0.2+0.5;        
        }
        
        vec2 coords = fragCoord.xy / iResolution.xy;
        
        // Generate Mouse coursor, x = mouse color, y = mouse weight 
        float mouseSize = 0.02;
        float mouseDist = length((coords - sampleCoords) * vec2(iResolution.x/iResolution.y, 1.));
        
        float aa = fwidth(mouseDist); // cheap anti-aliasing factor
        
        // Mask for the outline and the white center of the sphere cursor
        cursor.x = smoothstep(mouseSize*0.5 + aa, mouseSize*0.5 - aa, mouseDist);
        cursor.y = smoothstep(mouseSize + aa, mouseSize - aa, mouseDist);

        // sample the coordinates of the texture to find the reference color
        vec3 referenceColor = texture(iChannel0, sampleCoords).xyz;       
    #endif
    
    // Apply color range selection
    float mask = colorRange(imageColor, referenceColor, RANGE, FUZZINESS);
    
    // Use mask to make make of color and it's inverse
    vec3 color = mix(1.-referenceColor, referenceColor, mask);

    #ifndef REFERENCE_COLOR
        // Add mouse cursor
        color = mix(color, cursor.x * referenceColor, cursor.y);
    #endif
    
    // Output to screen
    fragColor = vec4(color,1);
}