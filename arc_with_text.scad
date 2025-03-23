// Parameters
radius = 152; // Radius of the arc
width = 10;   // Width/thickness of the arc
height = 1;  // Height of the arc
angle = 45;  // Angle of the arc segment (0-360)
text_size = 7; // Size of the text
text_height = 0.5; // Height of the raised text
text = "Shadowsun Aura"; // Text to display
text_font = "Arial"; // Simplified font name
show_center_line = true; // Whether to show the line to center
center_line_width = 10; // Width of the line to center
line_text = "6\""; // Text to display on the center line
line_text_size = 9; // Size of the line text

//TODO: Teh arc is centered at the radius, it shoudl ither be wholy inside or outside

include <arc_modules.scad>

// Module to create a pointy end
module pointy_end(radius, width, height, angle) {
    rotate([0, 0, angle])
    linear_extrude(height = height)
    polygon(points=[
        [radius - width/2, 0],
        [radius + width/2, 0],
        [radius, width]
    ]);
}

// Module to create center line with arrow and text
module center_line(radius, line_width, height, angle, line_text="", text_size=4) {
    mid_angle = -angle/2;
    point_length = line_width;  // Make point length proportional to line width
    
    rotate([0, 0, mid_angle])
    union() {
        // Main line
        linear_extrude(height = height)
        polygon(points=[
            [point_length, -line_width/2],
            [radius, -line_width/2],
            [radius, line_width/2],
            [point_length, line_width/2]
        ]);
        
        // Pointy end at center
        linear_extrude(height = height)
        polygon(points=[
            [point_length, line_width/2],
            [point_length, -line_width/2],
            [0, 0],  // Point at center
        ]);
        
        // Add text along the line if provided
        if (line_text != "") {
            text_pos = (radius + point_length) / 2;  // Position text in middle of line
            translate([text_pos, 0, height])
            rotate([0, 0, 0])  // Text aligned with the line
            linear_extrude(height = text_height)
            text(line_text, 
                 size = text_size, 
                 halign = "center", 
                 valign = "center", 
                 font = text_font,
                 spacing = 1);
        }
    }
}

// Create the final object
union() {
    // Calculate angle adjustment for pointy ends
    angle_adjustment = asin(width/(2*radius)) * 2;
    adjusted_angle = angle - angle_adjustment*2;
    
    // Add pointy ends
    pointy_end(radius, width, height, 0);  // Start point
    pointy_end(radius, -width, height, -adjusted_angle);  // End point
        
    arc_segment(radius, width, height, adjusted_angle);
    
    // Add center line if enabled
    if (show_center_line) {
        center_line(radius, center_line_width, height, adjusted_angle, line_text, line_text_size);
    }
    
    curved_text(radius, text, text_size, text_height, adjusted_angle, text_font);
} 