/*
5.8 GHz prime-focus dish feed -- parametric fabrication STARTING POINT.
Units: mm. OpenSCAD 2021.01+. No external libraries.

DISH: 406.4 diameter, focal length 152.4 measured from dish VERTEX
(bottom/center surface), NOT rim plane. Depth = 67.73; f/D = 0.375.
Rim half-angle from focus = 2 atan(D/(4f)) = 67.38 deg.
This deep dish needs a very broad feed (~134.76 deg total rim angle).
Compact apertures below are initial design candidates, not simulated or
measured matches. Flare angle is NOT radiation beamwidth. No guaranteed
edge taper, return loss, gain, polarization purity, or phase center.
Start with an approximately -10 dB edge illumination target; evaluate both
principal planes in EM simulation and tune aperture/length accordingly.
Simple smooth horns can have unequal E/H patterns; a scalar/corrugated
feed may ultimately illuminate this deep reflector more efficiently.

CONNECTION: choose round or rectangular. This selects a native conical or
pyramidal horn, not an unvalidated rectangular-to-circular mode converter.
Tube slides into rear socket from negative Z and BUTTS against stop z=0.
Horn bore at stop equals nominal tube ID. Socket clearance is PER SIDE.
Tube must seat fully with a continuous conductive RF joint at the stop.
Slip fit alone is not an RF seal or a structural mast joint. Use external
retention and suitable conductive bonding/flange construction. No screws
penetrate the bore. Square-corner rectangular approximation: measure actual
extrusion corner radii and adapt socket if necessary.

FABRICATION: metal, or a prototype with continuous, adequately thick,
low-resistance metal lining including socket/stop. Bare printed plastic is
NOT a waveguide. Dimensions are finished conductive surfaces; allow for
plating thickness. wall is radial / X-Y thickness, not normal to flare.
No launcher, radome, weather seal, RF bend, or structural mount is included.

POINTING: mouth (+Z) must face dish vertex. A vertical mast needs a designed
bend/routing arrangement; straight horn does not automatically aim at dish.
Place measured phase center at focus. Aperture plane is NOT necessarily
phase center. Start near aperture and provide +/-25 mm axial adjustment;
optimize on-axis received power and check matching. show_dish uses a USER
phase_center_back_mm assumption, only for visualization.

USAGE: F5 preview; F6 render; export STL with view_mode="part".
view_mode="cutaway" removes front half for inspection only.
view_mode="comparison" displays both candidates; not one fabrication part.
show_tube/show_dish are preview-only (%) references, excluded from STL.

Theory references:
https://www.ece.mcmaster.ca/faculty/nikolova/antenna_dload/current_lectures/L18_Horns.pdf
https://elmag.fel.cvut.cz/sites/default/files/users/hazdrap/files/Horn_antennas.pdf
*/

/* [Selection] */
connection = "round"; // [round,rectangular]
view_mode = "part"; // [part,cutaway,comparison]
show_tube = true;
show_dish = false;

/* [Dish and RF] */
frequency_GHz = 5.8;
dish_diameter = 406.4;
focal_length = 152.4;
// Assumed distance behind mouth toward tube; NOT calculated phase center
phase_center_back_mm = 10;

/* [Tubing outside dimensions] */
round_od = 38.1;
round_wall = 1.651;
rect_width = 50.8;
rect_height = 25.4;
rect_wall = 3.175;

/* [Horn finished inside dimensions] */
round_aperture = 50;
rect_aperture_width = 55;
rect_aperture_height = 40;
flare_length = 40;
straight_throat_length = 12;

/* [Mechanical] */
wall = 2.5;
socket_length = 25;
socket_clearance = 0.15;
socket_wall = 3;

/* [Hidden] */
$fn = 128;
eps = 0.02;
round_id = round_od-2*round_wall;
rect_a = rect_width-2*rect_wall;
rect_b = rect_height-2*rect_wall;
mouth_z = straight_throat_length+flare_length;
lambda0 = 299.792458/frequency_GHz;
depth = dish_diameter*dish_diameter/(16*focal_length);
rim_angle = 2*atan(dish_diameter/(4*focal_length));
assert(connection=="round" || connection=="rectangular");
assert(wall>0 && socket_wall>0 && socket_length>0 && socket_clearance>=0);
assert(round_id>0 && rect_a>rect_b && rect_b>0);
assert(flare_length>0 && straight_throat_length>0);
assert(round_aperture>=round_id && rect_aperture_width>=rect_a && rect_aperture_height>=rect_b);
echo(f_D=focal_length/dish_diameter, dish_depth_mm=depth, rim_half_angle_deg=rim_angle);
echo(round_cutoffs_GHz=[1.841184*299.792458/(PI*round_id),2.404826*299.792458/(PI*round_id)]);
echo(rect_cutoffs_GHz=[299.792458/(2*rect_a),min(299.792458/rect_a,299.792458/(2*rect_b))]);

module profile(kind, w, h) {
    if(kind=="round") circle(d=w);
    else square([w,h],center=true);
}
module prism(kind,w,h,z,length) {
    translate([0,0,z]) linear_extrude(height=length) profile(kind,w,h);
}
module taper(kind,w,h,W,H,z,length) {
    translate([0,0,z]) linear_extrude(height=length,scale=[W/w,H/h]) profile(kind,w,h);
}
module horn(kind) {
    a=kind=="round"?round_id:rect_a;
    b=kind=="round"?round_id:rect_b;
    A=kind=="round"?round_aperture:rect_aperture_width;
    B=kind=="round"?round_aperture:rect_aperture_height;
    ow=kind=="round"?round_od:rect_width;
    oh=kind=="round"?round_od:rect_height;
    difference() {
        union() {
            // Socket overlaps throat externally, leaving a tube end stop.
            prism(kind,ow+2*(socket_clearance+socket_wall),oh+2*(socket_clearance+socket_wall),-socket_length,socket_length+3);
            prism(kind,a+2*wall,b+2*wall,0,straight_throat_length+eps);
            taper(kind,a+2*wall,b+2*wall,A+2*wall,B+2*wall,straight_throat_length,flare_length);
        }
        prism(kind,ow+2*socket_clearance,oh+2*socket_clearance,-socket_length-eps,socket_length+eps);
        prism(kind,a,b,-eps,straight_throat_length+2*eps);
        taper(kind,a,b,A,B,straight_throat_length,flare_length);
        prism(kind,A,B,mouth_z-eps,2*eps);
    }
}
module tube(kind) {
    ow=kind=="round"?round_od:rect_width;
    oh=kind=="round"?round_od:rect_height;
    a=kind=="round"?round_id:rect_a;
    b=kind=="round"?round_id:rect_b;
    difference() {
        prism(kind,ow,oh,-socket_length-40,socket_length+40);
        prism(kind,a,b,-socket_length-41,socket_length+42);
    }
}
module dish_reference() {
    // Local dish coordinate s points from vertex toward feed (-global Z).
    vertex_z=mouth_z-phase_center_back_mm+focal_length;
    translate([0,0,vertex_z]) rotate([180,0,0]) rotate_extrude($fn=160)
        polygon(concat(
            [for(i=[0:80]) let(r=dish_diameter/2*i/80) [r,r*r/(4*focal_length)]],
            [for(i=[80:-1:0]) let(r=dish_diameter/2*i/80) [r,r*r/(4*focal_length)-2]]));
}
module display_one(kind) {
    color("Silver") difference() {
        horn(kind);
        if(view_mode=="cutaway") translate([-200,-200,-100]) cube([400,200,300]);
    }
    if(show_tube) %color("SteelBlue",0.35) tube(kind);
}
if(view_mode=="comparison") {
    translate([-45,0,0]) display_one("round");
    translate([45,0,0]) display_one("rectangular");
} else display_one(connection);
if(show_dish && view_mode!="comparison") %color("LightSlateGray",0.3) dish_reference();
