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
// Depth of the box along +Z. The dish-facing opening stays at the focus.
enclosure_height = 50; // [24:1:120]
enclosure_wall = 2; // [1.6:0.1:4]
arm_width = 20; // [16:0.5:36]
arm_height = 20; // [16:0.5:36]
feed_bore_width = 14; // [12:0.1:24]
feed_bore_height = 14; // [12:0.1:24]
radome_thickness = 1.2; // [0.8:0.1:2.5]

/* [Pole bracket] */
pole_diameter = 32; // [20:0.5:60]
pole_clearance = 0.8; // [0.2:0.1:2]
// Included angle of the pole V. 90° is the 45° stair faces. Larger is a wider V.
v_included = 90; // [60:1:130]
clamp_band_width = 12.7; // [8:0.1:20]
clamp_slot = 2.5; // [1.5:0.1:4]
// Distance between the two hose-clamp stations along the pole, not the V width.
clamp_pitch = 72; // [50:1:140]
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
rim_back_t = max(rim_depth, honey_back) + 0.5;
rim_xy = dish_r + (rim_back_t + 0.5) * sin(rim_slope_deg);
// Solid fill inside the honeycomb. The cut is one face of an arm. The upright
// strip is the extra past that face; the bed strip matches it on the far side.
upright_band = 4;
// Square plug is a hair under the hub gap so the quadrants close around it.
plug_fit = 0.4;
flange_t = 8;
cheek_y = clamp_band_width + 6;
pole_r = pole_diameter / 2 + pole_clearance;
flange_back = -hub_thickness - flange_t;
v_angle = v_included / 2;
v_steps = 6;
v_wall = 4;
// Stairs begin on the underside of the flange. Corners lie on the two faces.
// Depth runs to the pole center so the hose clamp can wrap the tube.
z_apex = flange_back;
v_depth = pole_r / sin(v_angle);
stair_x = v_depth * tan(v_angle) / v_steps;
stair_z = v_depth / v_steps;
pole_cz = z_apex - v_depth;
cheek_back = pole_cz;
v_half = v_steps * stair_x;
min_clamp_pitch = 2 * (bolt_circle_r * sin(45) + bolt_d / 2 + 1) + cheek_y;
station_pitch = max(clamp_pitch, min_clamp_pitch);
// Rectangular plate. Its corners are the outer corners of the two clamp stations.
flange_hx = v_half + v_wall;
flange_hy = station_pitch / 2 + cheek_y / 2;
plug_side = arm_width - plug_fit;

echo(lambda_mm=lambda_mm, surface_opening_mm=surface_opening, rim_slope_deg=rim_slope_deg);
echo(xy_opening_mm=xy_opening, xy_pitch_mm=xy_pitch, open_fraction=open_fraction);
echo(dish_depth_mm=dish_depth);

assert(xy_opening > 0.8, "Mesh opening is too small to print");
assert(mesh_rib >= 0.8, "Mesh rib is too thin to print");
assert(enclosure_size >= 36, "Enclosure is too small for the corner posts");
assert(enclosure_height >= 2 * (lip_t + 4), "Enclosure is too short for the lid lands");
assert(arm_width - feed_bore_width >= 4 && arm_height - feed_bore_height >= 4, "Feed bore does not leave a wall in the arm");
assert(gasket_half - groove_w / 2 > inner_opening / 2, "Gasket leaves the land");
assert((enclosure_size / 2) * sqrt(2) + arm_width < dish_r - rim_width, "Enclosure corner reaches the rim");
assert(bolt_circle_r * cos(45) + bolt_d / 2 < flange_hx - 2, "Bolt holes leave the flange");
assert(bolt_circle_r * sin(45) + bolt_d / 2 < flange_hy - 2, "Bolt holes leave the flange");
assert(bolt_circle_r - bolt_d / 2 > (arm_width / 2) * sqrt(2) + 1, "Bolt holes meet the hub gap");
assert(plug_side > 4, "Hub plug is too small");
if (clamp_pitch < min_clamp_pitch)
    echo(str("clamp_pitch raised to ", station_pitch, " mm so the stations clear the bolt holes"));

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
function rim_outer(th) = [dish_r * cos(th), dish_r * sin(th), z_of(dish_r)];
function focus_pt(th) = let(r = enclosure_size / 2) [r * cos(th), r * sin(th), focal_length];
function outer_pt(th) = let(r = enclosure_size / 2) [r * cos(th), r * sin(th), focal_length + enclosure_height];

function arm_radial(th) = [cos(th), sin(th), 0];
function arm_az(th) = [-sin(th), cos(th), 0];

function arm_encl(th) = [focus_pt(th)[0], focus_pt(th)[1], focal_length + arm_height / 2];
// Chord of the rim circle: the arm's outer vertical edges sit on r = dish_r.
// Centerline is inboard so the 20 mm section is not centered on the hoop.
function arm_rim_r() = sqrt(max(dish_r * dish_r - (arm_width / 2) * (arm_width / 2), 0));
function arm_rim(th) =
    let(r = arm_rim_r())
    [r * cos(th), r * sin(th), z_of(dish_r) - arm_height / 2];
function arm_u(th) = unit(vsub(arm_encl(th), arm_rim(th)));
function arm_len(th) = vnorm(vsub(arm_encl(th), arm_rim(th)));
function arm_mid(th, extra_encl = 4, extra_rim = 0) =
    vadd(arm_rim(th), vmul(arm_u(th), (arm_len(th) + extra_encl - extra_rim) / 2));

echo(arm_angle_deg=atan2(
    arm_encl(270)[2] - arm_rim(270)[2],
    dish_r - enclosure_size / 2
));
assert(arm_len(270) > 20, "Hollow arm is too short");
assert(enclosure_size > arm_width + 4, "Arm is wider than the enclosure face");
assert(enclosure_height >= arm_height, "Enclosure is shorter than the arm");

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
        extra_rim = 2,
        len = arm_len(th) + 4 + extra_rim,
        mid = arm_mid(th, 4, extra_rim)
    )
    [for (su = [-1, 1], saz = [-1, 1], sz = [-1, 1])
        vadd(mid, vadd(
            vmul(u, su * len / 2),
            vadd(vmul(az, saz * arm_width / 2), [0, 0, sz * arm_height / 2])
        ))];

function region_samples(q) =
    let(
        a = arm_width / 2,
        s = sqrt(max(rim_xy * rim_xy - a * a, 0)),
        d = rim_xy * 0.7071
    )
    q == 0 ? [[a, -a], [s, -a], [a, s], [d, d]] :
    q == 1 ? [[a, a], [-s, a], [a, s], [-d, d]] :
    q == 2 ? [[-a, a], [-s, a], [-a, -s], [-d, -d]] :
    [[-a, -a], [s, -a], [-a, -s], [d, -d]];

function quad_samples(q) =
    let(th = arm_theta(q))
    concat(
        [for (xy = region_samples(q), z = [-hub_thickness, focal_length + enclosure_height])
            [xy[0], xy[1], z]],
        [rim_outer(th), focus_pt(th), outer_pt(th)],
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
    para_shell(-0.3, rim_back_t, dish_r - rim_width, dish_r);
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
// The rim's back face sits outside dish_r by t*sin(slope), and the cube is
// offset by a, so dish_r+8 left a flat chord on the far arc.
module quadrant_region(q) {
    a = arm_width / 2;
    span = rim_xy + a + 4;
    z0 = -hub_thickness - 8;
    z1 = focal_length + enclosure_height + 4;
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

module arm_clip(th) {
    overlap = 1.2;
    s = enclosure_size / 2 - overlap;
    if (th == 0)
        translate([s, -500, -200]) cube([1000, 1000, 1000]);
    else if (th == 90)
        translate([-500, s, -200]) cube([1000, 1000, 1000]);
    else if (th == 180)
        translate([-s - 1000, -500, -200]) cube([1000, 1000, 1000]);
    else
        translate([-500, -s - 1000, -200]) cube([1000, 1000, 1000]);
}

module arm_blank(th, w, h, extra_encl, extra_rim) {
    u = arm_u(th);
    dist = arm_len(th);
    frame_cube(
        arm_mid(th, extra_encl, extra_rim),
        u, arm_az(th), [0, 0, 1],
        [dist + extra_encl + extra_rim, w, h]
    );
}

module arm_rim_clip() {
    translate([0, 0, -500])
        cylinder(h=1000, r=dish_r, $fn=shell_fn);
}

// Volume behind the rim/honeycomb back. The arm may not occupy this.
module behind_dish_back() {
    para_shell(rim_back_t, rim_back_t + 80, dish_r - rim_width - 12, dish_r + 8);
}

module arm_prism(th) {
    difference() {
        intersection() {
            arm_blank(th, arm_width, arm_height, 4, 2);
            arm_clip(th);
            arm_rim_clip();
        }
        behind_dish_back();
    }
}

module arm_solid(th) {
    arm_prism(th);
}

// Conduit through the quadrant-4 arm. Same section as the arm, open into the
// enclosure and out the back of the rim past the mesh.
module feed_void() {
    extra_rim = rim_width + honey_back + 20;
    arm_blank(
        270, feed_bore_width, feed_bore_height,
        enclosure_wall + 10, extra_rim
    );
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
            cylinder(h=enclosure_height, r=post_r, center=true, $fn=32);
}

module enclosure_local() {
    difference() {
        union() {
            difference() {
                cube([enclosure_size, enclosure_size, enclosure_height], center=true);
                cube([enclosure_size - 2 * enclosure_wall, enclosure_size - 2 * enclosure_wall, enclosure_height + 2], center=true);
            }
            for (s = [-1, 1])
                translate([0, 0, s * (enclosure_height / 2 - lip_t / 2)])
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
        z0 = s > 0 ? enclosure_height / 2 - pilot_depth : -enclosure_height / 2 - 0.05;
        translate([sx * enclosure_size / 2, sy * enclosure_size / 2, z0])
            cylinder(h=pilot_depth + 0.1, d=pilot_d, $fn=24);
    }
}

module enclosure_world() {
    translate([0, 0, focal_length + enclosure_height / 2])
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
        mirror([0, 0, 1])
            lid(true);
}

module place_back_lid() {
    translate([0, 0, focal_length + enclosure_height])
        lid(false);
}

module place_gasket(s) {
    // s = -1 front, +1 back. The gasket sits on the land and stands proud toward the lid.
    translate([0, 0, focal_length + (s > 0 ? enclosure_height : 0)])
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
            cube([d1 - d0, rim_xy + arm_width / 2 + 4, dish_depth + hub_thickness + 40]);
}

// Fill the honeycomb along one cut. The band is the cell depth, not a shelf
// behind it. The bed edge stays on the print plane, crosses the arm, and
// continues upright_band past the far face. The upright edge is that same
// distance past the cut, plus 0.2 mm of overlap so the quadrants share volume.
// The strip runs through the inner rim so it meets the hoop; dish_r from the
// offset corner stopped short of the far arc.
module edge_binding(q, bed) {
    intersection() {
        para_shell(0.5, honey_back, hub_radius - 2, dish_r - 1);
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
        z_top = z_apex - i * stair_z;
        inner = (i + 1) * stair_x;
        extra = i == 0 ? 0.2 : 0;
        translate([-outer, station_y - cheek_y / 2, z_top - stair_z])
            cube([outer - inner, cheek_y, stair_z + extra]);
        translate([inner, station_y - cheek_y / 2, z_top - stair_z])
            cube([outer - inner, cheek_y, stair_z + extra]);
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
                clamp_station(s * station_pitch / 2);
        }
        // Opens on the underside of the flange and clears the first step, so no
        // thin plate is left across the station.
        slot_h = max(clamp_slot, stair_z) + 0.2;
        for (s = [-1, 1])
            translate([0, s * station_pitch / 2, flange_back - (slot_h - 0.2) / 2])
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
