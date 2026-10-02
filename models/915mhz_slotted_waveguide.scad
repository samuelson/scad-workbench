/*
915 MHz selectable ROUND / RECTANGULAR longitudinal slotted waveguide.
Vertical Z axis; all units mm. Set waveguide_shape in Customizer.
Default rectangular bore is WR-975, 247.65 x 123.825 mm, TE10. Alternating
broad-wall offsets use the thin-wall Stevenson estimate (still requires tuning).
Round: finished inner diameter, TE11 calculations; angular offset is unvalidated.
Both profiles compensate coating and use automatic sections.
Round joints are full external sleeves. Rectangular couplers and cap skirts
grip only the broad walls (±Y), so the tube width fits a 256 mm bed.
Round-only settings: inner_diameter_mm, slot_angle_offset_deg, feed_angle_deg.
Rectangular-only settings: inner_width_mm, inner_depth_mm, rectangular_slot_offset_mm.
Rectangular feed enters the rear (-Y) broad wall at X=0.
Older STL bundles remain round-only; regenerate exports for rectangular mode.
PRELIMINARY RF GEOMETRY: circular TE11 design, not RF-validated.

inner_diameter_mm is the FINISHED METALLIZED AIR BORE. Printed bore diameter
is increased by twice coating_thickness_mm. wall_mm is printed plastic thickness.
Cutoff and guide wavelength use ONLY the finished bore, never outer diameter.
Slot length and width are nominal finished apertures. Slot cutters include coating
allowance assuming coating also covers slot edges. Masking/uneven coating changes this.
Caps' inner faces must be metallized, with their axial coating allowance modeled.

TE11 cutoff = 1.841184*c/(pi*D); next spatial mode TM01 = 2.404826*c/(pi*D).
TE11 has two degenerate polarizations: a circular bore alone does not lock the
field orientation. Radial feed at feed_angle_deg selects an initial orientation.
Alternating slots are placed either side of that orientation's longitudinal-current
null plane. Angular offset is a tunable guess, NOT rectangular Stevenson math.
No guaranteed azimuth pattern, gain, impedance, or 902-928 MHz bandwidth.
Vertical longitudinal slots radiate predominantly horizontal polarization.
Use EM simulation/VNA to tune angle, slot dimensions, probe and end short.
References:
https://www.microwaves101.com/uploads/TD-00036R-Ulis-waveguide-list.pdf
https://www.w1ghz.org/antbook/ch7_part1.pdf

PRINTING:
part="section", section_index=0..section_count-1; indices ascend bottom to top.
All section exports stand upright at Z=0. Seams are BETWEEN slot apertures.
Optional extra seam between feed and first slot reduces bottom-section height.
join_every_n_slots groups adjacent slot positions into larger prints.
part="coupler" exports one joint piece per seam. Round is a full sleeve.
Rectangular is a pair of broad-wall straps, outer_width in X, with wall and
clearance only in Y. Strap ends sit flush with the narrow walls.
Butt faces contact directly: joints align/support, with NO internal ledge.
Mark a common azimuth externally before assembly; do not rotate the sections.
Metallize inner bore AND butt faces; electrically bridge EVERY seam around its
full circumference using a suitable conductive bond/foil. An external plastic
sleeve alone does not provide RF continuity. Keep bridges flush inside the bore.
Metallize cap inner faces, bond to bore coating, and account for connector insulation.
Plastic and metallization processes need dimensional calibration.
Build volume is a 256 mm cube with 5 mm height reserve.
Rectangular tube outer is 253.75 x 129.93 mm; print upright with no brim.
Round printed OD is ~236 mm.
Automatic height splitting moves cuts into clear gaps; it never cuts slots.
Disable auto_height_split to use the original slot-grouping controls.
"layout" lays all tube sections out upright; caps/couplers exported separately.
Preview pin is illustrative and never included in STL output.
*/

/* [RF - finished conductive surfaces] */
waveguide_shape = "rectangular"; // [round,rectangular]
frequency_mhz = 915;
inner_width_mm = 247.65;
inner_depth_mm = 123.825;
// Zero selects thin-wall estimated offset; positive values override (mm).
rectangular_slot_offset_mm = 0;
inner_diameter_mm = 230;
slot_positions = 4; // [2:1:12]
slots_on_opposite_side = true;
slot_angle_offset_deg = 30; // [5:1:70]
slot_length_lambda0 = 0.48; // [0.44:0.001:0.52]
slot_width_mm = 16;
feed_angle_deg = 90;
upper_short_adjust_mm = 0;

/* [Printing and coating] */
wall_mm = 3;
coating_thickness_mm = 0.05;
cap_plate_mm = 3;
cap_socket_depth_mm = 15;
cap_radial_clearance_mm = 0.2;
feed_hole_diameter_mm = 16;
probe_length_mm = 65;
probe_diameter_mm = 3;

/* [Sections and joints] */
segmented = true;
auto_height_split = true;
print_height_reserve_mm = 5;
// One gives a seam in every slot-to-slot gap. Larger numbers group slots.
join_every_n_slots = 1; // [1:1:12]
split_feed_section = true;
section_index = 0; // [0:1:12]
coupler_length_mm = 24;
coupler_wall_mm = 3;
coupler_radial_clearance_mm = 0.25;
// Cube side. The height reserve leaves room for a raft or print tolerances.
printer_height_mm = 256;

/* [Display and export] */
part = "assembly"; // [assembly,body,section,layout,coupler,bottom_cap,top_cap]
show_couplers = true;
show_probe_preview = true;
resolution = 128; // [64,128,256]

/* [Hidden] */
$fn = resolution;
eps = 0.02;
c = 299792.458;
lambda0 = c/frequency_mhz;
is_round = waveguide_shape=="round";
fc = is_round ? 1.841184*c/(PI*inner_diameter_mm) : c/(2*inner_width_mm);
fc_next = is_round ? 2.404826*c/(PI*inner_diameter_mm) :
    min(c/inner_width_mm,c/(2*inner_depth_mm));
lambda_g = lambda0/sqrt(1-pow(fc/frequency_mhz,2));
spacing = lambda_g/2;
slot_length = slot_length_lambda0*lambda0;
feed_z = lambda_g/4;
first_slot = feed_z+lambda_g/2;
last_slot = first_slot+(slot_positions-1)*spacing;
height = last_slot+lambda_g/4+upper_short_adjust_mm;
printed_bore = inner_diameter_mm+2*coating_thickness_mm;
od = printed_bore+2*wall_mm;
printed_width = inner_width_mm+2*coating_thickness_mm;
printed_depth = inner_depth_mm+2*coating_thickness_mm;
outer_width = printed_width+2*wall_mm;
outer_depth = printed_depth+2*wall_mm;
span = is_round ? od : max(outer_width,outer_depth);
tube_x = is_round ? od : outer_width;
tube_y = is_round ? od : outer_depth;
coupler_x = is_round ? od+2*(coupler_radial_clearance_mm+coupler_wall_mm) : outer_width;
coupler_y = is_round ? coupler_x :
    outer_depth+2*(coupler_radial_clearance_mm+coupler_wall_mm);
cap_x = is_round ? od+2*(cap_radial_clearance_mm+wall_mm) : outer_width;
cap_y = is_round ? cap_x : outer_depth+2*(cap_radial_clearance_mm+wall_mm);
slot_count = slot_positions*(slots_on_opposite_side ? 2:1);
conductance_k = 2.09*inner_width_mm/inner_depth_mm*lambda_g/lambda0
    *pow(cos(90*lambda0/lambda_g),2);
rect_offset = rectangular_slot_offset_mm>0 ? rectangular_slot_offset_mm :
    inner_width_mm/180*asin(sqrt(min(1,1/(slot_count*conductance_k))));
cut_width = slot_width_mm+2*coating_thickness_mm;
cut_length = slot_length+2*coating_thickness_mm;
manual_seams = concat(
    split_feed_section ? [(feed_z+first_slot)/2] : [],
    [for(i=[0:slot_positions-2]) if((i+1)%join_every_n_slots==0)
        first_slot+(i+0.5)*spacing]);
// Keep each seam at least half a sleeve length + 2 mm away from openings.
seam_margin = coupler_length_mm/2+2;
protected_intervals = concat(
    [[feed_z-feed_hole_diameter_mm/2-seam_margin,
      feed_z+feed_hole_diameter_mm/2+seam_margin]],
    [for(i=[0:slot_positions-1])
      [first_slot+i*spacing-cut_length/2-seam_margin,
       first_slot+i*spacing+cut_length/2+seam_margin]]);
height_limit = printer_height_mm-print_height_reserve_mm;
function safe_cut(z,j=0) = j>=len(protected_intervals) ? z :
    (z>=protected_intervals[j][0] && z<=protected_intervals[j][1]
      ? protected_intervals[j][0] : safe_cut(z,j+1));
function auto_bounds(start=0,iteration=0) =
    assert(iteration<200,"Too many print sections.")
    height-start<=height_limit ? [start,height] :
    let(cut=safe_cut(start+height_limit))
    assert(cut>start+0.01,
      "An uninterrupted opening region exceeds print height; increase capacity or change RF geometry.")
    concat([start],auto_bounds(cut,iteration+1));
bounds = !segmented ? [0,height] : auto_height_split ? auto_bounds() :
    concat([0],manual_seams,[height]);
seams = [for(i=[1:len(bounds)-2]) bounds[i]];
section_count = len(bounds)-1;
function section_height(i) = bounds[i+1]-bounds[i];
function near_slot(z) = min([for(i=[0:slot_positions-1])
    abs(z-(first_slot+i*spacing))-cut_length/2]);

assert(printer_height_mm>print_height_reserve_mm && print_height_reserve_mm>=0);
assert(frequency_mhz>fc && frequency_mhz<fc_next,
    "Frequency must be above dominant-mode cutoff and below next spatial mode.");
assert(waveguide_shape=="round" || waveguide_shape=="rectangular");
assert(inner_width_mm>inner_depth_mm && inner_depth_mm>0);
if(!is_round) {
    assert(rectangular_slot_offset_mm>0 || slot_count*conductance_k>=1);
    assert(rect_offset>0 && rect_offset+cut_width/2<inner_width_mm/2);
}
assert(inner_diameter_mm>0 && wall_mm>0 && coating_thickness_mm>=0);
assert(slot_positions>=2 && floor(slot_positions)==slot_positions);
assert(join_every_n_slots>=1 && floor(join_every_n_slots)==join_every_n_slots);
assert(slot_angle_offset_deg>0 && slot_angle_offset_deg<90);
assert(slot_width_mm>0 && slot_length>slot_width_mm && cut_length<spacing);
assert(height-last_slot-cut_length/2>cap_socket_depth_mm,
    "Top cap socket overlaps a slot.");
assert(feed_z-feed_hole_diameter_mm/2>cap_socket_depth_mm);
assert(probe_length_mm>0 && probe_length_mm<(is_round ? inner_diameter_mm:inner_depth_mm));
assert(feed_hole_diameter_mm>probe_diameter_mm);
assert(cap_plate_mm>0 && cap_socket_depth_mm>0);
assert(cap_radial_clearance_mm>=0 && coupler_radial_clearance_mm>=0);
assert(coupler_wall_mm>0 && coupler_length_mm>0);
assert(tube_x<=printer_height_mm && tube_y<=printer_height_mm,
    str("Tube exceeds ",printer_height_mm," mm bed: ",tube_x," x ",tube_y," mm"));
assert(coupler_x<=printer_height_mm && coupler_y<=printer_height_mm,
    str("Coupler exceeds ",printer_height_mm," mm bed: ",coupler_x," x ",coupler_y," mm"));
assert(cap_x<=printer_height_mm && cap_y<=printer_height_mm,
    str("Cap exceeds ",printer_height_mm," mm bed: ",cap_x," x ",cap_y," mm"));
assert(section_index>=0 && section_index<section_count && floor(section_index)==section_index,
    "Section index out of range; see section_count in console.");
for(z=seams) {
    assert(near_slot(z)>coupler_length_mm/2,
        "Joint overlaps slot aperture; shorten coupler.");
    assert(abs(z-feed_z)>coupler_length_mm/2+feed_hole_diameter_mm/2,
        "Joint overlaps connector.");
}
if(is_round) echo("Finished RF bore, printed bore, printed OD mm",inner_diameter_mm,printed_bore,od);
echo("Profile; dominant and next-mode cutoffs MHz",waveguide_shape,fc,fc_next);
if(!is_round) echo("Finished width/depth; printed width/depth; slot offset mm",
    inner_width_mm,inner_depth_mm,printed_width,printed_depth,rect_offset);
echo("Tube outer and coupler span mm",tube_x,tube_y,coupler_x,coupler_y);
echo("Free-space wavelength, guide wavelength, slot spacing mm",lambda0,lambda_g,spacing);
echo("Slot finished length,width mm",slot_length,slot_width_mm);
if(is_round) echo("Angular offset deg",slot_angle_offset_deg);
echo("Body height, total height including printed cap plates mm",height,
    height+2*(cap_plate_mm+coating_thickness_mm));
echo("section_count; seam Z positions from lower RF short",section_count,seams);
for(i=[0:section_count-1]) {
    echo("Section index, start Z, print height",i,bounds[i],section_height(i));
    if(segmented) assert(section_height(i)<=height_limit+eps,
        "Section exceeds usable printer height; enable automatic splitting.");
}

// Longitudinal capsule cutter, radial extrusion through ONLY one tube wall.
module slot_cut(angle,z) {
    rotate([0,0,angle]) translate([printed_bore/2+wall_mm/2,0,z])
        rotate([0,90,0]) linear_extrude(height=wall_mm+4*cut_width,center=true)
            hull() for(v=[-1,1])
                translate([v*(cut_length-cut_width)/2,0]) circle(d=cut_width);
}
module radial_hole(angle,z,d) {
    rotate([0,0,angle]) translate([printed_bore/2+wall_mm/2,0,z])
        rotate([0,90,0]) cylinder(d=d,h=wall_mm+2*eps,center=true);
}
module profile_prism(h, expansion=0, bore=false) {
    if(is_round) cylinder(d=(bore ? printed_bore:od)+2*expansion,h=h);
    else {
        w=(bore ? printed_width:outer_width)+2*expansion;
        d=(bore ? printed_depth:outer_depth)+2*expansion;
        translate([-w/2,-d/2,0]) cube([w,d,h]);
    }
}
module rectangular_slot(x,y,z) {
    translate([x,y,z]) rotate([90,0,0])
        linear_extrude(height=wall_mm+2*eps,center=true)
            hull() for(v=[-1,1]) translate([0,v*(cut_length-cut_width)/2])
                circle(d=cut_width);
}
module body() {
    difference() {
        profile_prism(height);
        translate([0,0,-eps]) profile_prism(height+2*eps,bore=true);
        for(i=[0:slot_positions-1]) {
            angle = feed_angle_deg+(i%2==0 ? 1:-1)*slot_angle_offset_deg;
            if(is_round) {
                slot_cut(angle,first_slot+i*spacing);
                if(slots_on_opposite_side) slot_cut(angle+180,first_slot+i*spacing);
            } else {
                x=(i%2==0 ? 1:-1)*rect_offset;
                rectangular_slot(x,outer_depth/2-wall_mm/2,first_slot+i*spacing);
                if(slots_on_opposite_side)
                    rectangular_slot(x,-outer_depth/2+wall_mm/2,first_slot+i*spacing);
            }
        }
        if(is_round) radial_hole(feed_angle_deg,feed_z,feed_hole_diameter_mm);
        else translate([0,-outer_depth/2+wall_mm/2,feed_z]) rotate([90,0,0])
            cylinder(d=feed_hole_diameter_mm,h=wall_mm+2*eps,center=true);
    }
}
module section(i,local=true) {
    translate([0,0,local ? -bounds[i]:0]) intersection() {
        body();
        translate([-span,-span,bounds[i]]) cube([2*span,2*span,section_height(i)]);
    }
}
// External joint. Round: full slip sleeve. Rectangular: broad-wall straps.
// Neither changes the finished RF bore.
module coupler() {
    if(is_round) difference() {
        profile_prism(coupler_length_mm,coupler_radial_clearance_mm+coupler_wall_mm);
        translate([0,0,-eps]) profile_prism(coupler_length_mm+2*eps,coupler_radial_clearance_mm);
    } else {
        gap = outer_depth/2+coupler_radial_clearance_mm;
        for(s=[-1,1]) translate([-outer_width/2,s*gap-(s<0 ? coupler_wall_mm:0),0])
            cube([outer_width,coupler_wall_mm,coupler_length_mm]);
    }
}
// Coating grows onto the inside plate face. Assembly compensates axially.
module cap() {
    if(is_round) difference() {
        profile_prism(cap_plate_mm+cap_socket_depth_mm,cap_radial_clearance_mm+wall_mm);
        translate([0,0,cap_plate_mm]) profile_prism(cap_socket_depth_mm+eps,cap_radial_clearance_mm);
    } else {
        // Plate covers the tube end. Skirts continue past it on ±Y only.
        y_outer = outer_depth+2*(cap_radial_clearance_mm+wall_mm);
        y_socket = outer_depth+2*cap_radial_clearance_mm;
        difference() {
            translate([-outer_width/2,-y_outer/2,0])
                cube([outer_width,y_outer,cap_plate_mm+cap_socket_depth_mm]);
            translate([-outer_width/2-eps,-y_socket/2,cap_plate_mm])
                cube([outer_width+2*eps,y_socket,cap_socket_depth_mm+eps]);
        }
    }
}
module assembly() {
    if(segmented) for(i=[0:section_count-1])
        color(i%2==0 ? "silver":"lightgray") section(i,false);
    else color("silver") body();
    color("gray") translate([0,0,-cap_plate_mm-coating_thickness_mm]) cap();
    color("gray") translate([0,0,height+cap_plate_mm+coating_thickness_mm])
        rotate([180,0,0]) cap();
    if(segmented && show_couplers) for(z=seams)
        color("darkgray") translate([0,0,z-coupler_length_mm/2]) coupler();
    if($preview && show_probe_preview && !is_round)
        color("gold") translate([0,-inner_depth_mm/2,feed_z]) rotate([-90,0,0])
            cylinder(d=probe_diameter_mm,h=probe_length_mm);
    if($preview && show_probe_preview && is_round)
        color("gold") rotate([0,0,feed_angle_deg])
            translate([inner_diameter_mm/2,0,feed_z]) rotate([0,-90,0])
                cylinder(d=probe_diameter_mm,h=probe_length_mm);
}
if(part=="assembly") assembly();
else if(part=="body") body();
else if(part=="section") section(section_index);
else if(part=="layout") for(i=[0:section_count-1])
    translate([i*(span+15),0,0]) section(i);
else if(part=="coupler") coupler();
else if(part=="bottom_cap" || part=="top_cap") cap();
else assert(false,"Unknown part.");
