/*
915 MHz circular longitudinal slotted waveguide, vertical Z axis; all units mm.
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
part="coupler" exports a separate external sleeve; print one per seam.
Butt faces contact directly: sleeves align/support, with NO internal ledge.
Mark a common azimuth externally before assembly; do not rotate the sections.
Metallize inner bore AND butt faces; electrically bridge EVERY seam around its
full circumference using a suitable conductive bond/foil. An external plastic
sleeve alone does not provide RF continuity. Keep bridges flush inside the bore.
Metallize cap inner faces, bond to bore coating, and account for connector insulation.
Plastic and metallization processes need dimensional calibration.
Automatic sections fit a 250 mm build height with 5 mm height reserve.
Printed tube OD is ~236 mm; verify your printer also has sufficient XY area.
Automatic height splitting moves cuts into clear gaps; it never cuts slots.
Disable auto_height_split to use the original slot-grouping controls.
"layout" lays all tube sections out upright; caps/couplers exported separately.
Preview pin is illustrative and never included in STL output.
*/

/* [RF - finished conductive surfaces] */
frequency_mhz = 915;
inner_diameter_mm = 230;
slot_positions = 4; // [2:1:12]
slots_on_opposite_side = true;
slot_angle_offset_deg = 30; // [5:1:70]
slot_length_lambda0 = 0.48; // [0.44:0.001:0.52]
slot_width_mm = 8;
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
// Maximum Z capacity; reserve leaves room for a raft or print tolerances.
printer_height_mm = 250;

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
fc = 1.841184*c/(PI*inner_diameter_mm);
fc_next = 2.404826*c/(PI*inner_diameter_mm);
lambda_g = lambda0/sqrt(1-pow(fc/frequency_mhz,2));
spacing = lambda_g/2;
slot_length = slot_length_lambda0*lambda0;
feed_z = lambda_g/4;
first_slot = feed_z+lambda_g/2;
last_slot = first_slot+(slot_positions-1)*spacing;
height = last_slot+lambda_g/4+upper_short_adjust_mm;
printed_bore = inner_diameter_mm+2*coating_thickness_mm;
od = printed_bore+2*wall_mm;
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
    "Finished bore must support TE11 below TM01 cutoff.");
assert(inner_diameter_mm>0 && wall_mm>0 && coating_thickness_mm>=0);
assert(slot_positions>=2 && floor(slot_positions)==slot_positions);
assert(join_every_n_slots>=1 && floor(join_every_n_slots)==join_every_n_slots);
assert(slot_angle_offset_deg>0 && slot_angle_offset_deg<90);
assert(slot_width_mm>0 && slot_length>slot_width_mm && cut_length<spacing);
assert(height-last_slot-cut_length/2>cap_socket_depth_mm,
    "Top cap socket overlaps a slot.");
assert(feed_z-feed_hole_diameter_mm/2>cap_socket_depth_mm);
assert(probe_length_mm>0 && probe_length_mm<inner_diameter_mm);
assert(feed_hole_diameter_mm>probe_diameter_mm);
assert(cap_plate_mm>0 && cap_socket_depth_mm>0);
assert(cap_radial_clearance_mm>=0 && coupler_radial_clearance_mm>=0);
assert(coupler_wall_mm>0 && coupler_length_mm>0);
assert(section_index>=0 && section_index<section_count && floor(section_index)==section_index,
    "Section index out of range; see section_count in console.");
for(z=seams) {
    assert(near_slot(z)>coupler_length_mm/2,
        "Joint sleeve overlaps slot aperture; shorten coupler.");
    assert(abs(z-feed_z)>coupler_length_mm/2+feed_hole_diameter_mm/2,
        "Joint sleeve overlaps connector.");
}
echo("Finished RF bore, printed bore, printed OD mm",inner_diameter_mm,printed_bore,od);
echo("TE11, TM01 cutoffs MHz",fc,fc_next);
echo("Free-space wavelength, guide wavelength, slot spacing mm",lambda0,lambda_g,spacing);
echo("Slot finished length,width mm; angular offset deg",slot_length,slot_width_mm,slot_angle_offset_deg);
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
module body() {
    difference() {
        cylinder(d=od,h=height);
        translate([0,0,-eps]) cylinder(d=printed_bore,h=height+2*eps);
        for(i=[0:slot_positions-1]) {
            angle = feed_angle_deg+(i%2==0 ? 1:-1)*slot_angle_offset_deg;
            slot_cut(angle,first_slot+i*spacing);
            if(slots_on_opposite_side) slot_cut(angle+180,first_slot+i*spacing);
        }
        radial_hole(feed_angle_deg,feed_z,feed_hole_diameter_mm);
    }
}
module section(i,local=true) {
    translate([0,0,local ? -bounds[i]:0]) intersection() {
        body();
        translate([-od,-od,bounds[i]]) cube([2*od,2*od,section_height(i)]);
    }
}
// External slip sleeve: does not change the finished RF bore.
module coupler() {
    socket = od+2*coupler_radial_clearance_mm;
    difference() {
        cylinder(d=socket+2*coupler_wall_mm,h=coupler_length_mm);
        translate([0,0,-eps]) cylinder(d=socket,h=coupler_length_mm+2*eps);
    }
}
// Coating grows onto the inside plate face. Assembly compensates axially.
module cap() {
    socket = od+2*cap_radial_clearance_mm;
    difference() {
        cylinder(d=socket+2*wall_mm,h=cap_plate_mm+cap_socket_depth_mm);
        translate([0,0,cap_plate_mm]) cylinder(d=socket,h=cap_socket_depth_mm+eps);
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
    if($preview && show_probe_preview)
        color("gold") rotate([0,0,feed_angle_deg])
            translate([inner_diameter_mm/2,0,feed_z]) rotate([0,-90,0])
                cylinder(d=probe_diameter_mm,h=probe_length_mm);
}
if(part=="assembly") assembly();
else if(part=="body") body();
else if(part=="section") section(section_index);
else if(part=="layout") for(i=[0:section_count-1])
    translate([i*(od+15),0,0]) section(i);
else if(part=="coupler") coupler();
else if(part=="bottom_cap" || part=="top_cap") cap();
else assert(false,"Unknown part.");
