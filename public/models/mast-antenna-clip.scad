// Mast antenna wire clip — print flat in PETG or another flexible filament.
// The C-shaped body grips round tubing; thread a small zip tie through the side eyelet.
// Tube diameter is the tubing's outside diameter in millimeters.
tube_diameter = 50.8; // [25.4:0.1:76.2]
clip_width = 18; // [12:1:25]
wall = 3.4; // [2.5:0.1:4.5]
clearance = 0.6; // [0.2:0.1:1.2]
opening_angle = 85; // [65:5:105]
zip_tie_slot_width = 5; // [3:0.5:6]
edge_chamfer = 0.8; // [0.3:0.1:1.2]

$fn = 128;
inner_radius = tube_diameter * 1.0 / 2 + clearance;
outer_radius = inner_radius + wall;
loop_x = -outer_radius - 11;

module clamp_profile() {
    difference() {
        circle(r=outer_radius);
        circle(r=inner_radius);
        // Mouth faces +X, leaving a flexible C-shaped wrap.
        polygon(points=[
            [0,0],
            [outer_radius*3*cos(-opening_angle/2), outer_radius*3*sin(-opening_angle/2)],
            [outer_radius*3*cos(opening_angle/2), outer_radius*3*sin(opening_angle/2)]
        ]);
    }
}

module side_eyelet() {
    hull() {
        translate([-outer_radius-1,0]) circle(r=wall);
        translate([loop_x,0]) circle(r=7);
    }
}

module clip_profile() {
    difference() {
        union() {
            clamp_profile();
            side_eyelet();
        }
        translate([loop_x,0])
            square([zip_tie_slot_width,4.5],center=true);
    }
}

// A double cone rounds no faces: its straight sides make a 45-degree bevel
// around both faces, including the mouth and zip tie opening.
module bevel_kernel() {
    cylinder(h=edge_chamfer,r1=0,r2=edge_chamfer,$fn=24);
    translate([0,0,edge_chamfer])
        cylinder(h=edge_chamfer,r1=edge_chamfer,r2=0,$fn=24);
}

minkowski() {
    linear_extrude(height=clip_width-2*edge_chamfer)
        offset(delta=-edge_chamfer)
            clip_profile();
    bevel_kernel();
}
