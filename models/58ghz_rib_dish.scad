// name: 5.8 GHz rib dish
// description: 400 mm prime-focus rib frame · 15 mm hub and ribs
//
// 5.8 GHz prime-focus rib frame. Units: mm. OpenSCAD 2021.01+. No libraries.
// Vertex at the origin, opening toward +Z, focus at z = focal_length.
// Structure sits behind the paraboloid (toward -Z). No mesh or metal in the
// model. Eight identical radial ribs and eight identical rim arcs bolt to a
// one-piece hub. Rim arcs butt at each radial rib and bolt on from below.

/* [Selection] */
part = "assembly"; // [assembly, hub, radial_rib, rim_segment]
fast_preview = true;

/* [Dish] */
frequency_GHz = 5.8; // [5:0.1:6.5]
dish_diameter = 400; // [250:1:600]
focal_length = 150; // [80:1:300]

/* [Stock] */
hub_od_ratio = 0.28; // [0.16:0.01:0.45]
thickness = 15; // [8:0.5:32]
rim_w = 8; // [6:0.5:16]
rim_h = 8; // [6:0.5:16]
lap_w = 16; // [12:0.5:28]
lap_clear = 0.25; // [0.1:0.05:0.6]
printer_bed_mm = 256; // [180:1:400]

/* [Hidden] */
$fa = fast_preview ? 12 : 6;
$fs = fast_preview ? 2 : 0.8;

n_ribs = 8;
n_para = fast_preview ? 16 : 40;
eps = 0.2;
insert_d = 4.0;
insert_h = 4;
bolt_hole = 3.3;

lambda_mm = 299.792458 / frequency_GHz;
dish_r = dish_diameter / 2;
dish_depth = dish_diameter * dish_diameter / (16 * focal_length);
f_D = focal_length / dish_diameter;
hub_od = hub_od_ratio * dish_diameter;
hub_r = hub_od / 2;
hub_t = thickness;
rib_w = thickness;
rib_h = thickness;
rib_r0 = hub_r - lap_w;
rib_r1 = dish_r;
rim_r0 = dish_r - rim_w;
z_floor = dish_depth - rim_h;
rim_half_ang = 180 / n_ribs - atan(lap_clear / 2 / dish_r);
hub_hole_r = hub_r - lap_w / 2;
rim_hole_r = dish_r - rim_w / 2;
rim_bolt_off = min(4, rib_w / 2 - bolt_hole / 2 - 1.6);

function z_of(r) = r * r / (4 * focal_length);

function para_pts(r0, r1, dz) =
    [for (i = [0:n_para])
        let (r = r0 + (r1 - r0) * i / n_para)
            [r, z_of(r) + dz]];

function hub_print_h() = hub_t + z_of(hub_r);
function rib_print_x() = rib_r1 - rib_r0;
function rib_print_y() = z_of(rib_r1) - (z_of(rib_r0) - rib_h);
function rim_print_x() = dish_r - rim_r0 * cos(rim_half_ang);
function rim_print_y() = 2 * dish_r * sin(rim_half_ang);
function rim_insert_t() = z_of(rim_hole_r) - z_floor;

echo(lambda_mm=lambda_mm, dish_depth_mm=dish_depth, f_D=f_D);
echo(hub_od=hub_od, thickness=thickness, rim_w=rim_w, rim_h=rim_h);
echo(rib_print=[rib_print_x(), rib_print_y(), rib_w]);
echo(rim_print=[rim_print_x(), rim_print_y(), rim_h]);
echo(hub_print=[hub_od, hub_od, hub_print_h()]);

assert(rib_r0 > 8, "Hub is too small for the half-laps");
assert(thickness / 2 > insert_h + 0.6, "Stock is too thin for the hub lap");
assert(thickness > insert_h + 1, "Stock is too thin for the insert");
assert(lap_w > insert_d + 4, "Lap is too short for the insert");
assert(rim_w >= insert_d + 4, "Rim is too narrow for the bolt");
assert(thickness > bolt_hole + 0.4, "Stock is too thin for M3");
assert(2 * (rim_bolt_off + bolt_hole / 2 + 1.2) <= thickness, "Rib is too thin for two rim bolts");
assert(rim_h < thickness - 2, "L-notch leaves no tab on the rib");
assert(rim_insert_t() > insert_h + 0.6, "Rim is too thin at the insert");
assert(n_ribs * (rib_w + lap_clear + 2) < 2 * PI * hub_hole_r, "Hub laps overlap");
assert(rim_half_ang < 80, "Rim sector is too wide to print as a flat arc");
assert(hub_od <= printer_bed_mm, "Hub is wider than the printer");
assert(hub_print_h() <= printer_bed_mm, "Hub is taller than the printer");
assert(rib_print_x() <= printer_bed_mm, "Radial rib is longer than the printer");
assert(rib_print_y() <= printer_bed_mm, "Radial rib is taller than the printer");
assert(thickness <= printer_bed_mm, "Stock is thicker than the printer");
assert(rim_print_x() <= printer_bed_mm, "Rim segment is too wide for the printer");
assert(rim_print_y() <= printer_bed_mm, "Rim segment is too long for the printer");
assert(rim_h <= printer_bed_mm, "Rim segment is thicker than the printer");

module insert_bore() {
    cylinder(h=insert_h + 0.2, d=insert_d, $fn=24);
}

module through_bore(h) {
    cylinder(h=h, d=bolt_hole, $fn=24);
}

module rib_profile_2d() {
    polygon(concat(para_pts(rib_r0, rib_r1, 0), para_pts(rib_r1, rib_r0, -rib_h)));
}

module hub_lap_cut_2d() {
    r0 = rib_r0 - eps;
    r1 = hub_r + rib_w;
    polygon(concat(
        para_pts(r0, r1, -rib_h / 2),
        [[r1, z_of(r1) + 2], [r0, z_of(r0) + 2]]
    ));
}

// Front-half lap only inside the hub circle so the shoulder is cylindrical.
module hub_lap_cut() {
    intersection() {
        translate([0, 0, -eps])
            linear_extrude(rib_w + 2 * eps, convexity=4)
                hub_lap_cut_2d();
        translate([0, z_of(rib_r0) - rib_h - 4, rib_w / 2])
            rotate([-90, 0, 0])
                cylinder(h=rib_h + z_of(hub_r) + 8, r=hub_r);
    }
}

module rim_l_notch_2d() {
    translate([rim_r0 - eps, z_floor])
        square([rim_w + 2 * eps, rim_h + 4]);
}

module radial_rib() {
    difference() {
        linear_extrude(rib_w, convexity=6)
            rib_profile_2d();
        hub_lap_cut();
        translate([0, 0, -eps])
            linear_extrude(rib_w + 2 * eps, convexity=4)
                rim_l_notch_2d();
        translate([hub_hole_r, z_of(hub_hole_r) - rib_h - 1, rib_w / 2])
            rotate([-90, 0, 0])
                through_bore(rib_h / 2 + 2);
        for (s = [-1, 1])
            translate([rim_hole_r, z_of(rim_hole_r) - rib_h - 1, rib_w / 2 + s * rim_bolt_off])
                rotate([-90, 0, 0])
                    through_bore(z_floor - (z_of(rim_hole_r) - rib_h) + 2);
    }
}

module place_rib(az) {
    rotate([0, 0, az])
        rotate([90, 0, 0])
            translate([0, 0, -rib_w / 2])
                radial_rib();
}

module hub_profile_2d() {
    polygon(concat(
        [[0, -hub_t], [0, 0]],
        [for (i = [1:n_para]) let (r = hub_r * i / n_para) [r, z_of(r)]],
        [for (i = [n_para:-1:1]) let (r = hub_r * i / n_para) [r, z_of(r) - hub_t]]
    ));
}

module hub_pocket() {
    rotate([90, 0, 0])
        translate([0, 0, -(rib_w + lap_clear) / 2])
            linear_extrude(rib_w + lap_clear, convexity=4)
                polygon(concat(
                    para_pts(rib_r0 - lap_clear, hub_r + 2, -rib_h - eps),
                    para_pts(hub_r + 2, rib_r0 - lap_clear, -rib_h / 2 + lap_clear)
                ));
}

module hub_insert() {
    translate([hub_hole_r, 0, z_of(hub_hole_r) - rib_h / 2])
        insert_bore();
}

module hub() {
    difference() {
        rotate_extrude(convexity=8)
            hub_profile_2d();
        for (i = [0:n_ribs - 1])
            rotate([0, 0, i * 360 / n_ribs]) {
                hub_pocket();
                hub_insert();
            }
    }
}

module hub_print() {
    translate([0, 0, hub_t])
        hub();
}

module rim_profile_2d() {
    polygon(concat(
        [[rim_r0, z_floor], [dish_r, z_floor]],
        para_pts(dish_r, rim_r0, 0)
    ));
}

module rim_blank() {
    rotate([0, 0, -rim_half_ang])
        rotate_extrude(angle=2 * rim_half_ang, convexity=8)
            rim_profile_2d();
}

module rim_end_inserts() {
    rotate([0, 0, -180 / n_ribs])
        translate([rim_hole_r, rim_bolt_off, z_floor - 0.1])
            insert_bore();
    rotate([0, 0, 180 / n_ribs])
        translate([rim_hole_r, -rim_bolt_off, z_floor - 0.1])
            insert_bore();
}

module rim_segment() {
    difference() {
        rim_blank();
        rim_end_inserts();
    }
}

module rim_print() {
    translate([0, 0, -z_floor])
        rim_segment();
}

module place_rim(az) {
    rotate([0, 0, az + 180 / n_ribs])
        rim_segment();
}

module assembly() {
    hub();
    for (i = [0:n_ribs - 1]) {
        place_rib(i * 360 / n_ribs);
        place_rim(i * 360 / n_ribs);
    }
}

if (part == "hub")
    hub_print();
else if (part == "radial_rib")
    radial_rib();
else if (part == "rim_segment")
    rim_print();
else
    assembly();
