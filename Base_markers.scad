include <arc_modules.scad>

radius = 60; // Radius of the arc
width = 50;
height = 1;
text_and_svg_height=0.5;
angle = 20;
text = ["HIT", ""];  // Array of text lines💀
text_fonts = ["Impact", "Noto emoji"];
text_size = 6;
text_height = 1;
text_line_spacing = 1.2;  // Spacing between lines (multiplier of text_size)
text_offsets = [43, 0];    // X offset for each line
text_angles = [-90, -90];   // Rotation angle for each line
text_radii = [radius, radius];  // Radius for each line
corner_radius=0.5;
rounded_corners = false;
text_font = "Noto emoji";
svg_height = 1;  // Height of the SVG extrusion

// Define SVGs and their positions
// Each entry is [filename, angle_offset, scale_multiplier, x_offset, y_offset, rotation]
svgs = [
    ["T_au_logo.svg", 0, 0.6, 10, 0, -90],      // Center
    ["rolling-dices.svg", 0, 0.6, 28, 0, 0],  // Slightly left of center
    ["reroll.svg", 0, 4, 28, 0, 0]  // Slightly left of center
];

// Calculate SVG scaling based on arc dimensions
svg_scale = width / 512;  // Base scale to fit the arc width

// Create the final object
union() {
    if(rounded_corners) {
        minkowski() {
            difference() {
            arc_segment(radius+width/2, width, height, angle);
            translate([0,0,0.5]) 
                rotate([0,0, -1])
                    arc_segment(radius+width/2, width-2, height+1, angle-2);
            }
            sphere(corner_radius, $fn=64);
         }
     } else {
        difference() {
            arc_segment(radius+width/2, width, height, angle);
            translate([0,0,0.5]) 
                rotate([0,0, -1])
                    arc_segment(radius+width/2, width-2, height+1, angle-2);
        }
     }

    // Add SVGs
    for (svg = svgs) {
        translate([0, 0, text_and_svg_height])
        rotate([0, 0, -angle/2 + svg[1]])  // Center in arc + offset
        translate([radius + svg[3], svg[4], 0])  // Move to the arc radius + x/y offsets
        rotate([0, 0, svg[5]])  // Apply individual SVG rotation
        linear_extrude(height = svg_height)       
        scale([svg_scale * svg[2], svg_scale * svg[2], 1])
        import(svg[0], center=true);
    }

    // Add each line of text
    for (i = [0:len(text)-1]) {
        translate([0, 0, text_and_svg_height])
        rotate([0, 0, -angle/2])  // Center in arc
        translate([text_radii[i] + text_offsets[i], 0, 0])  // Move to the arc radius + line offset
        rotate([0, 0, text_angles[i]])  // Rotate text according to angle array
        linear_extrude(height = text_height)
        text(text[i], size = text_size, font = text_fonts[i], halign = "center", valign = "center");
    }
}