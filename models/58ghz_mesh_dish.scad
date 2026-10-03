// name: 5.8 GHz mesh dish
// description: 400 mm prime-focus mesh · pole clamp · four-piece print
//
// 5.8 GHz prime-focus dish. Units: mm. OpenSCAD 2021.01+. No libraries.
//
// The dish is a plastic substrate for conductive paint and electroplating.
// Mesh openings are sized on that substrate. The front lid is a radome and
// should be printed in an unplated low-loss plastic. The gasket is for TPU.
//
// Vertex at the origin, opening toward +Z, focus at z = focal_length.
// +Y is up when installed, so the hollow arm at 270° points down and its
// rim mouth drains water out.
//
// part selects the solid to export. Each quadrant seam is the plane of one
// side of that quadrant's arm, so the arm side and the dish cut lie on the
// print bed together. Along each cut the honeycomb is filled solid, flush
// with the back of the cells. The upright strip is the extra past the arm face.
// The bed strip crosses the arm and continues that same distance past it, so
// the assembled seam is centered on the arm. The four cuts leave a square hole
// at the hub. The pole bracket's plug fills that square, flush with the dish.

/* [Selection] */
part = "assembly"; // [assembly,quadrant_1,quadrant_2,quadrant_3,quadrant_4,front_lid,back_lid,gasket,pole_bracket]
fast_preview = false;

/* [Dish and RF] */
frequency_GHz = 5.8; // [5:0.1:6.5]
dish_diameter = 400; // [250:1:600]
focal_length = 150; // [80:1:300]
mesh_opening_lambda = 0.1; // [0.05:0.01:0.2]
mesh_rib = 1.2; // [0.8:0.1:2.5]
skin_thickness = 1.2; // [0.8:0.1:2.5]

/* [Structure] */
honey_pitch = 24; // [12:1:40]
honey_rib = 2.4; // [1.2:0.1:4]
honey_depth = 10; // [6:1:18]
hub_radius = 45; // [30:1:70]
hub_thickness = 12; // [8:1:20]
rim_width = 8; // [4:1:16]
rim_depth = 8; // [4:1:16]
printer_bed_mm = 256; // [180:1:400]
print_yaw = 0; // [0:1:90]

/* [Feed enclosure] */
enclosure_size = 50; // [36:1:80]
enclosure_wall = 2; // [1.6:0.1:4]
arm_width = 14; // [12:0.5:24]
arm_height = 6; // [4:0.5:12]
feed_bore_width = 8; // [4:0.5:14]
feed_bore_height = 3; // [2:0.5:8]
radome_thickness = 1.2; // [0.8:0.1:2.5]

/* [Pole bracket] */
pole_diameter = 32; // [20:0.5:60]
pole_clearance = 0.8; // [0.2:0.1:2]
clamp_band_width = 12.7; // [8:0.1:20]
clamp_slot = 2.5; // [1.5:0.1:4]
bolt_d = 5; // [3:0.1:8]
bolt_circle_r = 28; // [16:1:40]

/* [Hidden] */
$fn = 64;

lambda_mm = 299.792458 / frequency_GHz;
surface_opening = mesh_opening_lambda * lambda_mm;
rim_slope_deg = atan(dish_diameter / (4 * focal_length));
xy_opening = surface_opening * cos(rim_slope_deg);
xy_pitch = xy_opening + mesh_rib;
open_fraction = pow(surface_opening / (surface_opening + mesh_rib), 2);
dish_depth = dish_diameter * dish_diameter / (16 * focal_length);
dish_r = dish_diameter / 2;
grid_pitch = fast_preview ? max(xy_pitch * 4, 18) : xy_pitch;
grid_rib = fast_preview ? max(mesh_rib * 2, 2) : mesh_rib;
shell_fn = fast_preview ? 48 : 96;
shell_n = fast_preview ? 18 : 40;

inner_opening = enclosure_size - 16;
gasket_half = enclosure_size / 2 - 5;
post_r = 5;
hole_d = 3.2;
pilot_d = 2.5;
pilot_depth = 8;
csk_d = 6.4;
csk_h = (csk_d - hole_d) / 2;
groove_w = 1.8;
groove_d = 1.0;
gasket_w = 1.6;
gasket_h = 1.4;
lid_t = 3.2;
lip_t = 3;
honey_back = skin_thickness + honey_depth;
// Solid fill inside the honeycomb. The cut is one face of an arm. The upright
// strip is the extra past that face; the bed strip matches it on the far side.
upright_band = 4;
// Square plug is a hair under the hub gap so the quadrants close around it.
plug_fit = 0.4;
flange_t = 8;
clamp_pitch = 72;
cheek_y = clamp_band_width + 6;
pole_r = pole_diameter / 2 + pole_clearance;
flange_back = -hub_thickness - flange_t;
// 45° V opening away from the dish. Stair corners lie on the two faces.
// The third corner on each face is where the pole is tangent.
contact = pole_r / sqrt(2);
stair = contact / 3;
v_steps = 6;
v_wall = 4;
// Stairs begin on the underside of the flange. A web here left a thin
// rectangle across each clamp station.
z_apex = flange_back;
pole_cz = z_apex - pole_r * sqrt(2);
cheek_back = pole_cz;
v_half = v_steps * stair;
// Rectangular plate. Its corners are the outer corners of the two clamp stations.
flange_hx = v_half + v_wall;
flange_hy = clamp_pitch / 2 + cheek_y / 2;
plug_side = arm_width - plug_fit;

echo(lambda_mm=lambda_mm, surface_opening_mm=surface_opening, rim_slope_deg=rim_slope_deg);
echo(xy_opening_mm=xy_opening, xy_pitch_mm=xy_pitch, open_fraction=open_fraction);
echo(dish_depth_mm=dish_depth);

assert(xy_opening > 0.8, "Mesh opening is too small to print");
assert(mesh_rib >= 0.8, "Mesh rib is too thin to print");
assert(enclosure_size >= 36, "Enclosure is too small for the corner posts");
assert(feed_bore_width < arm_width - 2 && feed_bore_height < arm_height - 1, "Feed bore does not fit in the arm");
assert(gasket_half - groove_w / 2 > inner_opening / 2, "Gasket leaves the land");
assert((enclosure_size / 2) * sqrt(2) + arm_width < dish_r - rim_width, "Enclosure corner reaches the rim");
assert(bolt_circle_r * cos(45) + bolt_d / 2 < flange_hx - 2, "Bolt holes leave the flange");
assert(bolt_circle_r * sin(45) + bolt_d / 2 < flange_hy - 2, "Bolt holes leave the flange");
assert(bolt_circle_r - bolt_d / 2 > (arm_width / 2) * sqrt(2) + 1, "Bolt holes meet the hub gap");
assert(clamp_pitch / 2 - cheek_y / 2 > bolt_circle_r * sin(45) + bolt_d / 2 + 1, "Clamp cheek covers a bolt hole");
assert(plug_side > 4, "Hub plug is too small");

function z_of(r) = r * r / (4 * focal_length);
function ang_of(r) = atan(r / (2 * focal_length));
function back_pt(r, t) = let(a = ang_of(r)) [r + t * sin(a), z_of(r) - t * cos(a)];

function vsub(a, b) = [a[0] - b[0], a[1] - b[1], a[2] - b[2]];
function vadd(a, b) = [a[0] + b[0], a[1] + b[1], a[2] + b[2]];
function vmul(a, s) = [a[0] * s, a[1] * s, a[2] * s];
function dot(a, b) = a[0] * b[0] + a[1] * b[1] + a[2] * b[2];
function cross(a, b) = [a[1] * b[2] - a[2] * b[1], a[2] * b[0] - a[0] * b[2], a[0] * b[1] - a[1] * b[0]];
function vnorm(a) = sqrt(dot(a, a));
function unit(a) = vmul(a, 1 / vnorm(a));
function rot_z(a, p) = [p[0] * cos(a) - p[1] * sin(a), p[0] * sin(a) + p[1] * cos(a), p[2]];
function vmin(v, i = 0) = i + 1 >= len(v) ? v[i] : min(v[i], vmin(v, i + 1));
function vmax(v, i = 0) = i + 1 >= len(v) ? v[i] : max(v[i], vmax(v, i + 1));

function arm_theta(q) = q * 90;
function rim_pt(th) = let(r = dish_r - rim_width / 2) [r * cos(th), r * sin(th), z_of(r)];
function focus_pt(th) = let(r = enclosure_size / 2 * sqrt(2)) [r * cos(th), r * sin(th), focal_length];
function outer_pt(th) = let(r = enclosure_size / 2 * sqrt(2)) [r * cos(th), r * sin(th), focal_length + enclosure_size / 2];

function arm_u(th) = unit(vsub(focus_pt(th), rim_pt(th)));
function arm_az(th) = [-sin(th), cos(th), 0];
function arm_out(th) =
    let(
        u = arm_u(th),
        az = arm_az(th),
        n = unit(cross(az, u)),
        w = [0, 0, enclosure_size / 2]
    ) (dot(n, w) >= 0 ? n : vmul(n, -1));

function face_dist(th) = dot([0, 0, enclosure_size / 2], arm_out(th));
function arm_len(th) = vnorm(vsub(focus_pt(th), rim_pt(th)));

echo(arm_angle_deg=atan2(
    focus_pt(270)[2] - rim_pt(270)[2],
    dish_r - rim_width / 2 - enclosure_size / 2 * sqrt(2)
));
assert(arm_len(270) > 20, "Hollow arm is too short");
assert(arm_width / 2 >= post_r + 1, "Arm is too narrow for the seam to clear the corner post");

// The bed is one side face of the arm. Material is on the +up side of that plane.
function bed_up(q) =
    q == 0 ? [0, 1, 0] :
    q == 1 ? [-1, 0, 0] :
    q == 2 ? [0, -1, 0] : [1, 0, 0];

function basis(q) =
    let(up = bed_up(q), by = [0, 0, 1])
    [cross(by, up), by, up];

function to_flat(q, p) =
    let(b = basis(q))
    [dot(b[0], p), dot(b[1], p), dot(b[2], p)];

function to_print(q, p) = rot_z(print_yaw, to_flat(q, p));

function prism_corners(q) =
    let(
        th = arm_theta(q),
        u = arm_u(th),
        az = arm_az(th),
        outn = arm_out(th),
        len = arm_len(th),
        mid = vadd(rim_pt(th), vadd(vmul(u, len / 2), vmul(outn, face_dist(th) - arm_height / 2)))
    )
    [for (su = [-1, 1], saz = [-1, 1], so = [-1, 1])
        vadd(mid, vadd(
            vmul(u, su * (len + 6) / 2),
            vadd(vmul(az, saz * arm_width / 2), vmul(outn, so * arm_height / 2))
        ))];

function region_samples(q) =
    let(a = arm_width / 2, s = sqrt(max(dish_r * dish_r - a * a, 0)), d = dish_r * 0.7071)
    q == 0 ? [[a, -a], [s, -a], [a, s], [d, d]] :
    q == 1 ? [[a, a], [-s, a], [a, s], [-d, d]] :
    q == 2 ? [[-a, a], [-s, a], [-a, -s], [-d, -d]] :
    [[-a, -a], [s, -a], [-a, -s], [d, -d]];

function quad_samples(q) =
    let(th = arm_theta(q))
    concat(
        [for (xy = region_samples(q), z = [-hub_thickness, focal_length + enclosure_size / 2])
            [xy[0], xy[1], z]],
        [rim_pt(th), focus_pt(th), outer_pt(th)],
        prism_corners(q)
    );

function printed(q) = [for (p = quad_samples(q)) to_print(q, p)];
function span_of(pts, idx) = vmax([for (p = pts) p[idx]]) - vmin([for (p = pts) p[idx]]);
function min_z(q) = vmin([for (p = printed(q)) p[2]]);

module para_shell(t0, t1, r0, r1) {
    rotate_extrude($fn=shell_fn)
        polygon(concat(
            [for (i = [0:shell_n]) back_pt(r0 + (r1 - r0) * i / shell_n, t0)],
            [for (i = [shell_n:-1:0]) back_pt(r0 + (r1 - r0) * i / shell_n, t1)]
        ));
}

module square_grid(pitch, rib, r) {
    n = ceil(r / pitch);
    h = dish_depth + hub_thickness + 30;
    for (i = [-n:n]) {
        translate([i * pitch - rib / 2, -r - 1, -hub_thickness - 2])
            cube([rib, 2 * r + 2, h]);
        translate([-r - 1, i * pitch - rib / 2, -hub_thickness - 2])
            cube([2 * r + 2, rib, h]);
    }
}

module hex_grid(pitch, rib, r) {
    n = ceil((r + pitch) / pitch);
    h = dish_depth + hub_thickness + 30;
    for (a = [0, 60, 120], i = [-n:n])
        rotate([0, 0, a])
            translate([i * pitch - rib / 2, -r * 1.6, -hub_thickness - 2])
                cube([rib, r * 3.2, h]);
}

module mesh_skin() {
    intersection() {
        // Stop inside the rim and the hub so those solids contain this edge.
        para_shell(0, skin_thickness, hub_radius - 2, dish_r - rim_width + 2);
        square_grid(grid_pitch, grid_rib, dish_r + grid_pitch);
    }
}

module honeycomb() {
    intersection() {
        // Starts inside the skin and ends inside the rim, so no shared face.
        para_shell(0.5, honey_back, hub_radius - 2, dish_r - rim_width + 1);
        hex_grid(honey_pitch, honey_rib, dish_r);
    }
}

// Solid band over the hub edge, behind the front surface. Mesh ribs end here.
module hub_weld() {
    para_shell(0.5, honey_back + 1, hub_radius - 8, hub_radius + 4);
}

module rim_hoop() {
    // Proud of the mesh by 0.3 mm so the shared band is interior, not a coplanar face.
    para_shell(-0.3, max(rim_depth, honey_back) + 0.5, dish_r - rim_width, dish_r);
}

module hub_pad() {
    translate([0, 0, -hub_thickness])
        cylinder(r=hub_radius, h=hub_thickness + 0.2, $fn=shell_fn);
    para_shell(-0.3, hub_thickness, 0, hub_radius + 3);
}

module dish_body() {
    union() {
        mesh_skin();
        honeycomb();
        rim_hoop();
        hub_pad();
        hub_weld();
    }
}

// Two straight cuts, each coplanar with an arm side. They bound a square of
// side arm_width at the hub instead of meeting on the axis.
module quadrant_region(q) {
    a = arm_width / 2;
    span = dish_r + 8;
    z0 = -hub_thickness - 8;
    z1 = focal_length + enclosure_size + 4;
    h = z1 - z0;
    if (q == 0) translate([a, -a, z0]) cube([span, span, h]);
    else if (q == 1) translate([a - span, a, z0]) cube([span, span, h]);
    else if (q == 2) translate([-a - span, a - span, z0]) cube([span, span, h]);
    else translate([-a, -a - span, z0]) cube([span, span, h]);
}

module frame_cube(origin, ux, uy, uz, size) {
    multmatrix([
        [ux[0], uy[0], uz[0], origin[0]],
        [ux[1], uy[1], uz[1], origin[1]],
        [ux[2], uy[2], uz[2], origin[2]],
        [0, 0, 0, 1]
    ])
        translate([-size[0] / 2, -size[1] / 2, -size[2] / 2])
            cube(size);
}

module arm_prism(th) {
    u = arm_u(th);
    ay = vmul(arm_az(th), -1);
    outn = arm_out(th);
    dist = face_dist(th);
    len = arm_len(th);
    mid = vadd(rim_pt(th), vadd(vmul(u, len / 2), vmul(outn, dist - arm_height / 2)));
    // (u, az, outn) is left-handed, so the width axis is flipped to keep a positive volume.
    frame_cube(mid, u, ay, outn, [len + 6, arm_width, arm_height]);
}

module arm_foot(th) {
    u = arm_u(th);
    ay = vmul(arm_az(th), -1);
    outn = arm_out(th);
    along = face_dist(th) - arm_height / 2;
    // The prism sits on the outer plane. These roots bury that prism in the hoop and the corner post.
    hull() {
        frame_cube(vadd(rim_pt(th), vmul(outn, along)), u, ay, outn, [14, arm_width, arm_height]);
        translate(rim_pt(th))
            cube([28, 28, 32], center=true);
    }
    hull() {
        frame_cube(
            vadd(focus_pt(th), vadd(vmul(u, -8), vmul(outn, along))),
            u, ay, outn,
            [14, arm_width, arm_height]
        );
        translate(focus_pt(th)) cube(12, center=true);
        // The outer corner lies on the print face. Shift this root inward so it
        // cannot cross that face; an 8 mm cube centered on the corner would.
        translate(vadd(outer_pt(th), vmul(outn, -(4 * (abs(outn[0]) + abs(outn[1]) + abs(outn[2])) + 0.2))))
            cube(8, center=true);
    }
}

module arm_solid(th) {
    arm_prism(th);
    arm_foot(th);
}

// Bore through the hollow arm. The mouth is the rim end, which is the low
// end when the dish is installed. The enclosure end stops short of the
// corner post and turns through the side wall into the cavity.
module feed_void() {
    th = 270;
    u = arm_u(th);
    ay = vmul(arm_az(th), -1);
    outn = arm_out(th);
    dist = face_dist(th);
    len = arm_len(th);
    along = dist - arm_height / 2;
    // Center the bore toward the rim so it stays clear of the screw post.
    mid = vadd(rim_pt(th), vadd(vmul(u, len / 2 - 12), vmul(outn, along)));
    frame_cube(mid, u, ay, outn, [len + 8, feed_bore_width, feed_bore_height]);
    hull() {
        frame_cube(
            vadd(rim_pt(th), vadd(vmul(u, len - 22), vmul(outn, along))),
            u, ay, outn,
            [8, feed_bore_width, feed_bore_height]
        );
        translate(rot_z(45, [-10, -10, focal_length]))
            cube([feed_bore_width, feed_bore_width, feed_bore_height], center=true);
    }
}

module rounded_square(half, rad) {
    offset(r=rad) offset(delta=-rad) square([half * 2, half * 2], center=true);
}

module gasket_2d() {
    difference() {
        rounded_square(gasket_half + gasket_w / 2, 3);
        rounded_square(gasket_half - gasket_w / 2, 2.2);
    }
}

module groove_2d() {
    difference() {
        rounded_square(gasket_half + groove_w / 2, 3);
        rounded_square(gasket_half - groove_w / 2, 2.2);
    }
}

module corner_posts() {
    for (sx = [-1, 1], sy = [-1, 1])
        translate([sx * enclosure_size / 2, sy * enclosure_size / 2, 0])
            cylinder(h=enclosure_size, r=post_r, center=true, $fn=32);
}

module enclosure_local() {
    difference() {
        union() {
            difference() {
                cube([enclosure_size, enclosure_size, enclosure_size], center=true);
                cube([enclosure_size - 2 * enclosure_wall, enclosure_size - 2 * enclosure_wall, enclosure_size + 2], center=true);
            }
            for (s = [-1, 1])
                translate([0, 0, s * (enclosure_size / 2 - lip_t / 2)])
                    difference() {
                        cube([enclosure_size, enclosure_size, lip_t], center=true);
                        cube([inner_opening, inner_opening, lip_t + 2], center=true);
                    }
            corner_posts();
        }
        pilots();
    }
}

module pilots() {
    for (sx = [-1, 1], sy = [-1, 1], s = [-1, 1]) {
        z0 = s > 0 ? enclosure_size / 2 - pilot_depth : -enclosure_size / 2 - 0.05;
        translate([sx * enclosure_size / 2, sy * enclosure_size / 2, z0])
            cylinder(h=pilot_depth + 0.1, d=pilot_d, $fn=24);
    }
}

module enclosure_world() {
    translate([0, 0, focal_length])
        rotate([0, 0, 45])
            enclosure_local();
}

module lid_holes() {
    for (sx = [-1, 1], sy = [-1, 1]) {
        translate([sx * enclosure_size / 2, sy * enclosure_size / 2, -0.2])
            cylinder(h=lid_t + 0.4, d=hole_d, $fn=24);
        translate([sx * enclosure_size / 2, sy * enclosure_size / 2, lid_t - csk_h])
            cylinder(h=csk_h + 0.02, d1=hole_d, d2=csk_d, $fn=32);
    }
}

module lid(front) {
    difference() {
        union() {
            translate([-enclosure_size / 2, -enclosure_size / 2, 0])
                cube([enclosure_size, enclosure_size, lid_t]);
            for (sx = [-1, 1], sy = [-1, 1])
                translate([sx * enclosure_size / 2, sy * enclosure_size / 2, 0])
                    cylinder(h=lid_t, r=post_r, $fn=32);
        }
        translate([0, 0, -0.05])
            linear_extrude(groove_d + 0.05)
                groove_2d();
        lid_holes();
        if (front)
            translate([0, 0, radome_thickness])
                linear_extrude(lid_t)
                    square([inner_opening - 2, inner_opening - 2], center=true);
    }
}

module gasket() {
    linear_extrude(gasket_h)
        gasket_2d();
}

module place_front_lid() {
    translate([0, 0, focal_length])
        rotate([0, 0, 45])
            translate([0, 0, -enclosure_size / 2])
                mirror([0, 0, 1])
                    lid(true);
}

module place_back_lid() {
    translate([0, 0, focal_length])
        rotate([0, 0, 45])
            translate([0, 0, enclosure_size / 2])
                lid(false);
}

module place_gasket(s) {
    // s = -1 front, +1 back. The gasket sits on the land and stands proud toward the lid.
    translate([0, 0, focal_length + s * enclosure_size / 2])
        rotate([0, 0, 45])
            if (s > 0)
                gasket();
            else
                mirror([0, 0, 1]) gasket();
}

// The bed edge is the arm-side plane that sits on the printer. The other edge
// is the neighbor's arm-side plane. Normals point into this quadrant.
function edge_normal(q, bed) =
    bed ? (
        q == 0 ? [0, 1, 0] :
        q == 1 ? [-1, 0, 0] :
        q == 2 ? [0, -1, 0] : [1, 0, 0]
    ) : (
        q == 0 ? [1, 0, 0] :
        q == 1 ? [0, 1, 0] :
        q == 2 ? [-1, 0, 0] : [0, -1, 0]
    );

function edge_tangent(q, bed) =
    bed ? (
        q == 0 ? [1, 0, 0] :
        q == 1 ? [0, 1, 0] :
        q == 2 ? [-1, 0, 0] : [0, -1, 0]
    ) : (
        q == 0 ? [0, 1, 0] :
        q == 1 ? [-1, 0, 0] :
        q == 2 ? [0, -1, 0] : [1, 0, 0]
    );

function edge_corner(q) =
    let(a = arm_width / 2)
    q == 0 ? [a, -a, 0] :
    q == 1 ? [a, a, 0] :
    q == 2 ? [-a, a, 0] : [-a, -a, 0];

module edge_slab(q, bed, d0, d1) {
    n = edge_normal(q, bed);
    t = edge_tangent(q, bed);
    o = edge_corner(q);
    multmatrix([
        [n[0], t[0], 0, o[0]],
        [n[1], t[1], 0, o[1]],
        [0, 0, 1, -hub_thickness - 6],
        [0, 0, 0, 1]
    ])
        translate([d0, 0, 0])
            cube([d1 - d0, dish_r, dish_depth + hub_thickness + 40]);
}

// Fill the honeycomb along one cut. The band is the cell depth, not a shelf
// behind it. The bed edge stays on the print plane, crosses the arm, and
// continues upright_band past the far face. The upright edge is that same
// distance past the cut, plus 0.2 mm of overlap so the quadrants share volume.
module edge_binding(q, bed) {
    intersection() {
        para_shell(0.5, honey_back, hub_radius - 2, dish_r - rim_width + 1);
        if (bed)
            edge_slab(q, true, 0, arm_width + upright_band);
        else
            edge_slab(q, false, -0.2, upright_band);
    }
}

module quadrant_seams(q) {
    edge_binding(q, true);
    edge_binding(q, false);
}

function bolt_xy(i) = let(a = 45 + i * 90) [bolt_circle_r * cos(a), bolt_circle_r * sin(a)];

// Plain through-holes, one in each quadrant. They run from the hub back face
// out through the front face. Countersinks and threads come later.
module hub_bolt_holes() {
    for (i = [0:3]) {
        p = bolt_xy(i);
        translate([p[0], p[1], -hub_thickness - 2])
            cylinder(h=hub_thickness + 10, d=bolt_d, $fn=24);
    }
}

// Square left where the offset seams no longer meet.
module key_void() {
    translate([-arm_width / 2, -arm_width / 2, -hub_thickness - 4])
        cube([arm_width, arm_width, hub_thickness + 30]);
}

module quadrant_raw(q) {
    th = arm_theta(q);
    difference() {
        union() {
            intersection() {
                quadrant_region(q);
                union() {
                    dish_body();
                    enclosure_world();
                }
            }
            intersection() {
                quadrant_region(q);
                arm_solid(th);
            }
            quadrant_seams(q);
        }
        hub_bolt_holes();
        if (q == 3) feed_void();
    }
}

module lay_flat(q) {
    b = basis(q);
    multmatrix([
        [b[0][0], b[0][1], b[0][2], 0],
        [b[1][0], b[1][1], b[1][2], 0],
        [b[2][0], b[2][1], b[2][2], 0],
        [0, 0, 0, 1]
    ]) children();
}

module quadrant_print(q) {
    translate([0, 0, -min_z(q)])
        rotate([0, 0, print_yaw])
            lay_flat(q)
                quadrant_raw(q);
}

// One clamp station. The outside is a straight wall. The inside is a stair-step
// V opening away from the dish, and the pole sits in that V.
module clamp_station(station_y) {
    outer = v_half + v_wall;
    for (i = [0:v_steps - 1]) {
        z_top = z_apex - i * stair;
        inner = (i + 1) * stair;
        extra = i == 0 ? 0.2 : 0;
        translate([-outer, station_y - cheek_y / 2, z_top - stair])
            cube([outer - inner, cheek_y, stair + extra]);
        translate([inner, station_y - cheek_y / 2, z_top - stair])
            cube([outer - inner, cheek_y, stair + extra]);
    }
}

// Plug face is the reflector vertex. The flange and the clamp stations share
// the hub back face. Each station is a stair-step V the pole sits in. The
// clamp band passes through a slot between that face and the V, then around
// the pole.
module pole_bracket() {
    difference() {
        union() {
            translate([-plug_side / 2, -plug_side / 2, -hub_thickness - 0.2])
                cube([plug_side, plug_side, hub_thickness + 0.2]);
            translate([-flange_hx, -flange_hy, flange_back])
                cube([2 * flange_hx, 2 * flange_hy, flange_t]);
            for (s = [-1, 1])
                clamp_station(s * clamp_pitch / 2);
        }
        // Opens on the underside of the flange and clears the first step, so no
        // thin plate is left across the station.
        slot_h = max(clamp_slot, stair) + 0.2;
        for (s = [-1, 1])
            translate([0, s * clamp_pitch / 2, flange_back - (slot_h - 0.2) / 2])
                cube([2 * (v_half + v_wall) + 4, clamp_band_width + 1, slot_h], center=true);
        for (i = [0:3]) {
            p = bolt_xy(i);
            translate([p[0], p[1], flange_back - 1])
                cylinder(h=flange_t + 2, d=bolt_d, $fn=24);
        }
    }
}

// Flat back of the cradle on the bed. The plug points up.
module pole_bracket_print() {
    translate([0, 0, -cheek_back]) pole_bracket();
}

module assembly() {
    difference() {
        union() {
            dish_body();
            enclosure_world();
            for (q = [0:3]) {
                arm_solid(arm_theta(q));
                quadrant_seams(q);
            }
        }
        feed_void();
        key_void();
        hub_bolt_holes();
    }
    place_front_lid();
    place_back_lid();
    place_gasket(-1);
    place_gasket(1);
    pole_bracket();
}

function active_q() =
    part == "quadrant_1" ? 0 :
    part == "quadrant_2" ? 1 :
    part == "quadrant_3" ? 2 :
    part == "quadrant_4" ? 3 : -1;

if (active_q() >= 0) {
    span_x = span_of(printed(active_q()), 0);
    span_y = span_of(printed(active_q()), 1);
    span_z = span_of(printed(active_q()), 2);
    echo(print_span_mm=[span_x, span_y, span_z]);
    assert(span_x <= printer_bed_mm, str("Quadrant print span X ", span_x, " mm exceeds the bed"));
    assert(span_y <= printer_bed_mm, str("Quadrant print span Y ", span_y, " mm exceeds the bed"));
    assert(span_z <= printer_bed_mm, str("Quadrant print span Z ", span_z, " mm exceeds the bed"));
}

if (part == "assembly") assembly();
else if (part == "quadrant_1") quadrant_print(0);
else if (part == "quadrant_2") quadrant_print(1);
else if (part == "quadrant_3") quadrant_print(2);
else if (part == "quadrant_4") quadrant_print(3);
else if (part == "front_lid") lid(true);
else if (part == "back_lid") lid(false);
else if (part == "gasket") gasket();
else if (part == "pole_bracket") pole_bracket_print();
else assert(false, str("Unknown part ", part));
