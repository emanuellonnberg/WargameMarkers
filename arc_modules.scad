// Parameters needed for the modules
$fn = 100;  // Resolution for cylinders


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
module curved_text(radius, text, text_size, text_height, angle, text_font) {
    chars = len(text);
    angle_step = angle / chars;
    
    for (i = [0:chars-1]) {
        current_angle = (i+0.5) * -angle_step;
        rotate([0, 0, current_angle])  // Rotate to position
        translate([radius-text_size/2, 0, height])  // Move to arc
        rotate([0, 0, -90])  // Orient text tangent to arc
        linear_extrude(height = text_height)
        //metrics = textmetrics(text[i], size=text_size, font=text_font);
        //metrics.width
        text(text[i], 
             size = text_size, 
             halign = "center", 
             valign = "baseline", 
             font = text_font,
             spacing = 1);
    }
} 