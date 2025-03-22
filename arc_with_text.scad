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

module arc_sgement_max_180(radius, width, height, angle) {
    union() {
        difference() {
            // Outer cylinder
            cylinder(r = radius + width/2, h = height, $fn = 100);
            // Inner cylinder
            translate([0, 0, -1])
                cylinder(r = radius - width/2, h = height + 2, $fn = 100);
            
            // Cut off the unwanted portion of the circle
            translate([-radius-width, 0, -1])
                cube([(radius + width) * 2, (radius + width) * 2, height + 2]);
            
            // Rotate and cut to create the arc using adjusted angle
            rotate([0, 0, 180-angle])
                translate([-radius-width, 0, -1])
                    cube([(radius + width) * 2, (radius + width) * 2, height + 2]);
        }
    }
}

// Module to create an arc segment
module arc_segment(radius, width, height, angle) {  
    union() {         
        if(angle > 180) {
            arc_sgement_max_180(radius, width, height, 180);
            rotate([0, 0, 180-angle])
                arc_sgement_max_180(radius, width, height, 180-adjusted_angle);
        } else {
            arc_sgement_max_180(radius, width, height, angle);
        }

        

    }
}

// Module to create text on a curved path
module curved_text(radius, text, text_size, text_height, angle) {
    chars = len(text);
    angle_step = angle / chars;
    
    for (i = [0:chars-1]) {
    current_angle = (i+0.5) * -angle_step;
        rotate([0, 0, current_angle])  // Rotate to position
        translate([radius-text_size/2, 0, height])  // Move to arc
        rotate([0, 0, -90])  // Orient text tangent to arc
        linear_extrude(height = text_height)
        text(text[i], 
             size = text_size, 
             halign = "center", 
             valign = "baseline", 
             font = text_font,
             spacing = 1);
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
    
    curved_text(radius, text, text_size, text_height, adjusted_angle);
} 