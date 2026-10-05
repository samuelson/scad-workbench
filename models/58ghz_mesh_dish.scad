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
// Layer thickness is in Z: one paraboloid tool, translated, cuts 2D prisms
// to depth. +Y is up when installed, so the hollow arm at 270° points down
// and its rim mouth drains water out. rear_box seals that mouth into a Pi
// box inset from the inner dish face; the lid faces the same way as the
// pole bracket.
//
// part selects the solid to export. Each quadrant seam is the plane of one
// side of that quadrant's arm, so the arm side and the dish cut lie on the
// print bed together. Along each cut the honeycomb is filled solid, flush
// with the back of the cells. The bed strip crosses the arm so the assembled
// seam is centered on it. A half-lap keys the upright rear into a rabbet on
// the bed rear; seam bolts come from the dish back into heat-set inserts.
// The four cuts leave a square hole at the hub. The pole bracket's plug fills
// that square, flush with the dish.

/* [Selection] */
part = "assembly"; // [assembly,quadrant_1,quadrant_2,quadrant_3,quadrant_4,front_lid,back_lid,gasket,pole_bracket,rear_lid,rear_gasket]
fast_preview = true;

/* [Dish and RF] */
frequency_GHz = 5.8; // [5:0.1:6.5]
dish_diameter = 400; // [250:1:600]
focal_length = 150; // [80:1:300]
mesh_opening_lambda = 0.05; // [0.05:0.01:0.2]
mesh_rib = 0.8; // [0.8:0.1:2.5]
skin_thickness = 0.8; // [0.8:0.1:2.5]

/* [Structure] */
honeycomb_pitch = 60; // [12:1:60]
honeycomb_rib = 1.2; // [1.2:0.1:4]
honeycomb_depth = 10; // [6:1:18]
hub_radius = 50; // [30:1:70]
hub_thickness = 12; // [8:1:20]
rim_width = 4; // [2:1:16]
rim_depth = 8; // [4:1:16]
printer_bed_mm = 256; // [180:1:400]
print_yaw = 0; // [0:1:90]

/* [Seam lap] */
// Overlap of the half-lap, past the upright cut into the bed piece.
lap_w = 16; // [8:0.5:30]
// Extra width on the rabbet.
lap_clear = 0.25; // [0.1:0.05:0.6]
// Through-bolts from the dish back into heat-set inserts.
seam_bolt = "M3"; // [M3, M4, M5]

/* [Feed enclosure] */
enclosure_size = 50; // [36:1:80]
// Depth of the box along +Z. The dish-facing opening stays at the focus.
enclosure_height = 24; // [9:1:120]
enclosure_wall = 2; // [1.6:0.1:4]
arm_width = 20; // [16:0.5:36]
arm_height = 20; // [16:0.5:36]
arm_wall = 2; // [2:2:4]
radome_thickness = 0.8; // [0.8:0.1:2.5]

/* [Rear box] */
rear_box = false;
// Split a centered box across quadrant_3 and quadrant_4.
rear_box_split = true;
// Extra +X on the one-piece box. 0 parks the −X wall on the q4 seam.
rear_box_x = 0; // [0:0.5:40]
// Outer size across the arm (X). Fits a Pi 4/5 board plus walls.
rear_box_w = 104; // [70:1:160]
// Outer size along the arm (Y). Board plus feed-bore keep-out.
rear_box_l = 92; // [60:1:140]
// Extra depth behind the dish back at the hub-ward edge.
rear_box_depth = 28; // [16:1:60]
// Posts on the Pi 4/5 hole pattern, inside the cavity.
pi_mount = false;
// Hub-ward post height. Rim-ward posts stay longer by the dish sag; all four
// change by the same amount.
pi_standoff_h = 10; // [4:0.5:24]

/* [Pole bracket] */
pole_diameter = 32; // [20:0.5:60]
pole_clearance = 0.8; // [0.2:0.1:2]
// Included angle of the pole V. 90° is the 45° stair faces. Larger is a wider V.
v_included = 120; // [60:1:130]
clamp_band_width = 12.7; // [8:0.1:20]
clamp_slot = 2.5; // [1.5:0.1:4]
// Distance between the two hose-clamp stations along the pole, not the V width.
clamp_pitch = 72; // [50:1:140]
bolt_d = 5; // [3:0.1:8]
bolt_circle_r = 28; // [16:1:40]
// Head seat on the dish inner face.
hub_bolt_recess = "round"; // [none:None, round:Round, hex:Hex]
// Diameter for round, across-flats for hex.
hub_bolt_recess_size = 9; // [5:0.1:16]
// Minimum depth below the inner face, on the shallow side of the angle.
hub_bolt_recess_h = 3.2; // [0:0.1:8]

/* [Hidden] */
$fa = 12;
$fs = 1;

feed_bore_height = arm_height - 2 * arm_wall;
feed_bore_width = arm_width - 2 * arm_wall;
// Extra back-of-dish opening, toward the hub from the inner rim.
feed_mouth = arm_height;

lambda_mm = 299.792458 / frequency_GHz;
surface_opening = mesh_opening_lambda * lambda_mm;
rim_slope_deg = atan(dish_diameter / (4 * focal_length));
xy_opening = surface_opening;
xy_pitch = xy_opening + mesh_rib;
open_fraction = pow(surface_opening / (surface_opening + mesh_rib), 2);
dish_depth = dish_diameter * dish_diameter / (16 * focal_length);
dish_r = dish_diameter / 2;
grid_pitch = fast_preview ? max(xy_pitch * 4, 18) : xy_pitch;
grid_rib = fast_preview ? max(mesh_rib * 2, 2) : mesh_rib;
shell_fn = fast_preview ? 48 : 96;
shell_n = fast_preview ? 18 : 40;
function para_r_max() = dish_r + 8;
function para_z_floor() =
    (rear_box ? min(-hub_thickness, rear_z_lid()) : -hub_thickness) - 8;

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
honeycomb_back = skin_thickness + honeycomb_depth;
rim_back_t = max(rim_depth, honeycomb_back) + 0.5;
rim_xy = dish_r + 4;
// Solid fill inside the honeycomb. The cut is one face of an arm. The upright
// strip is the extra past that face; the bed strip matches it on the far side.
upright_band = 4;
lap_t = honeycomb_back / 2;
lap_keep = 8;
seam_n = 3;
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
rear_front_t = max(enclosure_wall, skin_thickness);
pi_hole_span_x = 58;
pi_hole_span_y = 49;
pi_standoff_d = 6.4;
pi_pilot_d = 2.05;
rear_boss_inset = post_r + 0.8;
rear_hatch_inset = rear_boss_inset + post_r + 1;

echo(lambda_mm=lambda_mm, surface_opening_mm=surface_opening, rim_slope_deg=rim_slope_deg);
echo(xy_opening_mm=xy_opening, xy_pitch_mm=xy_pitch, open_fraction=open_fraction);
echo(dish_depth_mm=dish_depth);

assert(xy_opening > 0.8, "Mesh opening is too small to print");
assert(mesh_rib >= 0.8, "Mesh rib is too thin to print");
assert(enclosure_size >= 36, "Enclosure is too small for the corner posts");
assert(enclosure_height >= 2 * (lip_t + 4), "Enclosure is too short for the lid lands");
assert(arm_wall >= 2 && feed_bore_width > 0 && feed_bore_height > 0, "Feed bore does not leave a wall in the arm");
assert(gasket_half - groove_w / 2 > inner_opening / 2, "Gasket leaves the land");
assert((enclosure_size / 2) * sqrt(2) + arm_width < dish_r - rim_width, "Enclosure corner reaches the rim");
assert(bolt_circle_r * cos(45) + bolt_d / 2 < flange_hx - 2, "Bolt holes leave the flange");
assert(bolt_circle_r * sin(45) + bolt_d / 2 < flange_hy - 2, "Bolt holes leave the flange");
assert(bolt_circle_r - bolt_d / 2 > (arm_width / 2) * sqrt(2) + 1, "Bolt holes meet the hub gap");
assert(hub_bolt_recess == "none" || hub_bolt_recess_h <= 0 || hub_bolt_recess_size > bolt_d, "Bolt recess is smaller than the shank");
assert(hub_bolt_recess == "none" || hub_bolt_recess_h <= 0 || hub_bolt_recess_h < hub_thickness - 2, "Bolt recess goes through the hub");
assert(plug_side > 4, "Hub plug is too small");
assert(lap_w > seam_insert_d() + 4, "Lap is too narrow for the insert");
assert(seam_insert_h() < lap_t - 0.6, "Insert is longer than the lap thickness");
assert(
    min([for (q = [0:3]) seam_s_hi(q) - seam_s_lo(q)])
        > seam_n * (seam_insert_d() + 6),
    "Lap is too short for the inserts"
);
if (clamp_pitch < min_clamp_pitch)
    echo(str("clamp_pitch raised to ", station_pitch, " mm so the stations clear the bolt holes"));

function z_of(r) = r * r / (4 * focal_length);

function seam_bolt_d() =
    seam_bolt == "M3" ? 3 : (seam_bolt == "M4" ? 4 : 5);
function seam_bolt_hole() = seam_bolt_d() + 0.3;
function seam_insert_d() =
    seam_bolt == "M3" ? 4.0 : (seam_bolt == "M4" ? 5.6 : 6.5);
function seam_insert_h() =
    min(
        seam_bolt == "M3" ? 4 : (seam_bolt == "M4" ? 8 : 9.5),
        lap_t - 0.8
    );
function lap_r0() = hub_radius + 8;
function lap_r1() = dish_r - rim_width - 2;

function seam_s_at_r(q, r) =
    let(
        n = edge_normal(q, true),
        t = edge_tangent(q, true),
        o = edge_corner(q),
        d = lap_w / 2,
        px = o[0] + n[0] * d,
        py = o[1] + n[1] * d,
        bb = 2 * (px * t[0] + py * t[1]),
        cc = px * px + py * py - r * r,
        disc = bb * bb - 4 * cc
    )
        disc <= 0 ? 0 : (-bb + sqrt(disc)) / 2;

function seam_s_lo(q) = seam_s_at_r(q, lap_r0());
function seam_s_hi(q) =
    min(
        seam_s_at_r(q, lap_r1()),
        (rear_box && q == 3)
            ? (-arm_width / 2 - rear_y_hub() - lap_keep) : 1e9
    );

function seam_bolt_xy(q, i) =
    let(
        n = edge_normal(q, true),
        t = edge_tangent(q, true),
        o = edge_corner(q),
        d = lap_w / 2,
        s0 = seam_s_lo(q),
        s1 = seam_s_hi(q),
        s = s0 + (s1 - s0) * (i + 0.5) / seam_n
    )
        [o[0] + n[0] * d + t[0] * s, o[1] + n[1] * d + t[1] * s];

function rear_cx() = rear_box_split ? 0 : (-arm_width / 2 + rear_box_w / 2 + rear_box_x);
function rear_rim_outer() = dish_r;
function rear_x0() = rear_cx() - rear_box_w / 2;
function rear_x1() = rear_cx() + rear_box_w / 2;
function rear_x_out() = max(abs(rear_x0()), abs(rear_x1()));
function rear_y_hub() = -rear_rim_outer() + rear_box_l;
function rear_r_hub() =
    let(
        yh = rear_y_hub(),
        xn = rear_x0() * rear_x1() <= 0 ? 0 : (abs(rear_x0()) < abs(rear_x1()) ? rear_x0() : rear_x1())
    )
        sqrt(xn * xn + yh * yh);
function rear_z_lid() = z_of(rear_r_hub()) - honeycomb_back - rear_box_depth;
function rear_z_top() = z_of(dish_r) + 1;
function pi_cx() = rear_cx();
function pi_cy() = (rear_y_hub() - rear_rim_outer()) / 2 + 6;
function pi_hole_xy(sx, sy) = [
    pi_cx() + sx * pi_hole_span_x / 2,
    pi_cy() + sy * pi_hole_span_y / 2
];
function pi_hole_r(sx, sy) =
    let(p = pi_hole_xy(sx, sy))
        sqrt(p[0] * p[0] + p[1] * p[1]);
// Cavity face of the dish-side wall at a Pi hole, along Z.
function pi_dish_z(sx, sy) = z_of(pi_hole_r(sx, sy)) - rear_front_t;
function pi_dish_z_min() =
    min(pi_dish_z(-1, -1), pi_dish_z(-1, 1), pi_dish_z(1, -1), pi_dish_z(1, 1));
// Extra length so rim-ward posts still reach the dish from the shared board plane.
function pi_post_extra(sx, sy) = pi_dish_z(sx, sy) - pi_dish_z_min();
function pi_post_len(sx, sy) = pi_standoff_h + pi_post_extra(sx, sy);
// Shared board plane. Changing pi_standoff_h shifts every post by the same Z.
function pi_board_z() = pi_dish_z_min() - pi_standoff_h;
function rear_cav_x0() = rear_x0() + enclosure_wall;
function rear_cav_x1() = rear_x1() - enclosure_wall;
function rear_boss_rim_y(x) =
    let(ri = rear_rim_outer() - rear_boss_inset)
        -sqrt(max(ri * ri - x * x, 1));
function rear_boss_xy() = [
    [rear_x0() + rear_boss_inset, rear_y_hub() - rear_boss_inset],
    [rear_x1() - rear_boss_inset, rear_y_hub() - rear_boss_inset],
    [rear_x0() + rear_boss_inset, rear_boss_rim_y(rear_x0() + rear_boss_inset)],
    [rear_x1() - rear_boss_inset, rear_boss_rim_y(rear_x1() - rear_boss_inset)]
];

function vsub(a, b) = [a[0] - b[0], a[1] - b[1], a[2] - b[2]];
function vadd(a, b) = [a[0] + b[0], a[1] + b[1], a[2] + b[2]];
function vmul(a, s) = [a[0] * s, a[1] * s, a[2] * s];
function dot(a, b) = a[0] * b[0] + a[1] * b[1] + a[2] * b[2];
function vcross(a, b) = [a[1] * b[2] - a[2] * b[1], a[2] * b[0] - a[0] * b[2], a[0] * b[1] - a[1] * b[0]];
function vnorm(a) = sqrt(dot(a, a));
function unit(a) = vmul(a, 1 / vnorm(a));
function rot_z(a, p) = [p[0] * cos(a) - p[1] * sin(a), p[0] * sin(a) + p[1] * cos(a), p[2]];

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

function feed_inner_r() = dish_r - rim_width;
function feed_bore_r1() = feed_inner_r() - 0.2;
function feed_bore_r0() = feed_bore_r1() - feed_mouth;

echo(arm_angle_deg=atan2(
    arm_encl(270)[2] - arm_rim(270)[2],
    dish_r - enclosure_size / 2
));
assert(arm_len(270) > 20, "Hollow arm is too short");
assert(enclosure_size > arm_width + 4, "Arm is wider than the enclosure face");
assert(enclosure_height >= arm_height, "Enclosure is shorter than the arm");
if (rear_box) {
    assert(rear_x_out() < rear_rim_outer() - 2, "Rear box is wider than the rim");
    assert(rear_hatch_inset > groove_w, "Rear hatch leaves no gasket land");
    assert(rear_box_depth >= 16, "Rear box is too shallow behind the dish");
    assert(rear_z_lid() < z_of(rear_r_hub()) - honeycomb_back - 2, "Rear lid is not behind the dish");
    assert(rear_y_hub() < -arm_width / 2 - 4, "Rear box reaches the hub square");
    assert(
        rear_y_hub() * rear_y_hub() + rear_x_out() * rear_x_out()
            < rear_rim_outer() * rear_rim_outer(),
        "Rear box hub edge is outside the rim"
    );
    assert(
        rear_cav_x0() <= -feed_bore_width / 2 + 0.05
            && rear_cav_x1() >= feed_bore_width / 2,
        "Feed bore does not open into the rear box"
    );
    assert(
        rear_box_split || rear_x0() >= -arm_width / 2 - 0.05,
        "One-piece rear box leaves quadrant 4"
    );
    assert(
        !rear_box_split || (rear_x0() < -arm_width / 2 && rear_x1() > -arm_width / 2),
        "Split rear box does not cross the q3/q4 seam"
    );
    assert(
        !pi_mount
            || abs(pi_cx()) - pi_hole_span_x / 2 > feed_bore_width / 2 + pi_standoff_d / 2
            || abs(pi_cy() + arm_rim_r()) > feed_bore_height + pi_standoff_d,
        "Pi standoffs sit in the feed bore"
    );
    assert(
        !pi_mount || pi_board_z() > rear_z_lid() + lip_t + 1,
        "Pi standoffs reach the rear lid"
    );
}

// The bed is one side face of the arm. Material is on the +up side of that plane.
function bed_up(q) =
    q == 0 ? [0, 1, 0] :
    q == 1 ? [-1, 0, 0] :
    q == 2 ? [0, -1, 0] : [1, 0, 0];

function basis(q) =
    let(up = bed_up(q), by = [0, 0, 1])
    [vcross(by, up), by, up];

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

function rear_box_sample_pts(q) =
    let(
        a = arm_width / 2,
        r = rear_rim_outer(),
        corners = [
            [rear_x0(), rear_y_hub()],
            [rear_x1(), rear_y_hub()],
            [rear_x0(), -sqrt(max(r * r - rear_x0() * rear_x0(), 0))],
            [rear_x1(), -sqrt(max(r * r - rear_x1() * rear_x1(), 0))]
        ]
    )
    [for (c = corners, z = [rear_z_lid() - lid_t, rear_z_top()])
        let(xc = q == 3 ? max(c[0], -a) : (q == 2 ? min(c[0], -a) : c[0]))
            [xc, c[1], z]];

function rear_box_quad_pts(q) =
    !rear_box ? [] :
    (q == 3 || (rear_box_split && q == 2)) ? rear_box_sample_pts(q) : [];

function quad_samples(q) =
    let(th = arm_theta(q))
    concat(
        [for (xy = region_samples(q), z = [-hub_thickness, focal_length + enclosure_height])
            [xy[0], xy[1], z]],
        [rim_outer(th), focus_pt(th), outer_pt(th)],
        prism_corners(q),
        rear_box_quad_pts(q)
    );

function printed(q) = [for (p = quad_samples(q)) to_print(q, p)];
function span_of(pts, idx) = max([for (p = pts) p[idx]]) - min([for (p = pts) p[idx]]);
function min_z(q) = min([for (p = printed(q)) p[2]]);

// Solid on or below the inner face z = r²/(4f), out to para_r_max().
// No render(): the workbench uses Manifold; render() forces CGAL and OOMs.
module para_tool() {
    rmax = para_r_max();
    zfloor = para_z_floor();
    rotate_extrude($fn=shell_fn)
        polygon(concat(
            [[0, zfloor], [rmax, zfloor], [rmax, z_of(rmax)]],
            [for (i = [shell_n:-1:0]) let(r = rmax * i / shell_n) [r, z_of(r)]]
        ));
}

// Band t0..t1 behind the inner face. Thickness is in Z, not along the normal.
module para_slab(t0, t1) {
    difference() {
        translate([0, 0, -t0]) para_tool();
        translate([0, 0, -t1]) para_tool();
    }
}

// 2D footprint (XY) extruded, then cut to parabolic thickness t0..t1.
module para_layer(t0, t1) {
    z0 = -max(t1, hub_thickness) - 4;
    z1 = dish_depth - min(t0, 0) + 4;
    intersection() {
        translate([0, 0, z0])
            linear_extrude(height=z1 - z0)
                children();
        para_slab(t0, t1);
    }
}

module annulus_2d(r0, r1) {
    difference() {
        circle(r=r1, $fn=shell_fn);
        if (r0 > 0)
            circle(r=r0, $fn=shell_fn);
    }
}

// XY of one print quadrant, grown so 2D ribs are not clipped on the cut.
module quadrant_xy_2d(q, grow = 1) {
    a = arm_width / 2;
    span = rim_xy + a + 4;
    if (q == 0) translate([a - grow, -a - grow]) square([span + grow, span + 2 * grow]);
    else if (q == 1) translate([a - span, a - grow]) square([span + grow, span + 2 * grow]);
    else if (q == 2) translate([-a - span, a - span]) square([span + grow, span + 2 * grow]);
    else translate([-a - grow, -a - span]) square([span + 2 * grow, span + grow]);
}

module dish_2d(q) {
    if (q < 0)
        children();
    else
        intersection() {
            quadrant_xy_2d(q);
            children();
        }
}

// Hex ribs: union of three stripe families. Flat-to-flat opening is pitch - rib.
module hex_stripes_2d(pitch, rib, r) {
    n = ceil(2 * r / pitch) + 2;
    half = r + pitch;
    for (a = [0, 60, 120])
        rotate(a)
            for (i = [-n:n])
                translate([0, (i + 0.5) * pitch])
                    square([2 * half, rib], center=true);
}

// Annulus ∩ hex ribs. Holes that straddle hub or rim are clipped, not dropped.
module hex_annulus_2d(r0, r1, pitch, rib, q = -1) {
    intersection() {
        annulus_2d(r0, r1);
        hex_stripes_2d(pitch, rib, r1 + pitch);
        if (q >= 0)
            quadrant_xy_2d(q);
    }
}

// Hex-perforated front skin of the reflector, between hub and rim.
module mesh_skin(q = -1) {
    para_layer(0, skin_thickness)
        hex_annulus_2d(hub_radius - 2, dish_r - rim_width + 2, grid_pitch, grid_rib, q);
}

// Honeycomb backing behind the skin, stopping inside the rim hoop.
module honeycomb(q = -1) {
    para_layer(0.5, honeycomb_back)
        hex_annulus_2d(hub_radius - 2, dish_r - rim_width + 1, honeycomb_pitch, honeycomb_rib, q);
}

// Solid band over the hub edge, behind the front surface. Mesh ribs end here.
module hub_weld(q = -1) {
    para_layer(0.5, honeycomb_back + 1)
        dish_2d(q)
            annulus_2d(hub_radius - 8, hub_radius + 4);
}

// Outer rim hoop. Starts 0.3 mm proud of the mesh so the join is not coplanar.
module rim_hoop(q = -1) {
    para_layer(-0.3, rim_back_t)
        dish_2d(q)
            annulus_2d(dish_r - rim_width, dish_r);
}

// Flat hub disk on the back, plus a parabolic fill up to the inner face.
module hub_pad(q = -1) {
    module pad_solid() {
        translate([0, 0, -hub_thickness])
            cylinder(r=hub_radius, h=hub_thickness + 0.2, $fn=shell_fn);
        para_layer(-0.3, hub_thickness)
            dish_2d(q)
                circle(r=hub_radius + 3, $fn=shell_fn);
    }
    if (q < 0)
        pad_solid();
    else
        intersection() {
            pad_solid();
            quadrant_region(q);
        }
}

// Full reflector: skin, honeycomb, rim, hub pad, and hub weld.
module dish_body(q = -1) {
    union() {
        mesh_skin(q);
        honeycomb(q);
        rim_hoop(q);
        hub_pad(q);
        hub_weld(q);
    }
}

// Volume of one print quadrant. The two cuts are coplanar with the arm sides,
// so they bound a square of side arm_width at the hub.
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

// Cube of `size` centered at `origin`, with edges along ux, uy, uz.
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

function clip_z0() = para_z_floor();
function clip_h() = focal_length + enclosure_height - clip_z0() + 20;
function clip_xy() = dish_r + enclosure_size;

// Keeps the arm on the enclosure side of the feed-box face at this azimuth.
module arm_clip(th) {
    overlap = 1.2;
    s = enclosure_size / 2 - overlap;
    e = clip_xy();
    z0 = clip_z0();
    h = clip_h();
    if (th == 0)
        translate([s, -e, z0]) cube([e, 2 * e, h]);
    else if (th == 90)
        translate([-e, s, z0]) cube([2 * e, e, h]);
    else if (th == 180)
        translate([-s - e, -e, z0]) cube([e, 2 * e, h]);
    else
        translate([-e, -s - e, z0]) cube([2 * e, e, h]);
}

// Rectangular prism along the arm centerline from rim toward the enclosure.
module arm_blank(th, w, h, extra_encl, extra_rim) {
    u = arm_u(th);
    dist = arm_len(th);
    frame_cube(
        arm_mid(th, extra_encl, extra_rim),
        u, arm_az(th), [0, 0, 1],
        [dist + extra_encl + extra_rim, w, h]
    );
}

// Limits the arm to the dish disk so it does not pass the hoop.
module arm_rim_clip() {
    translate([0, 0, clip_z0()])
        cylinder(h=clip_h(), r=dish_r, $fn=shell_fn);
}

// Behind the vertical rim hoop only, not the whole dish back (that would
// carve the arm along its length).
module behind_dish_back() {
    intersection() {
        para_slab(rim_back_t, rim_back_t + 80);
        translate([0, 0, para_z_floor()])
            linear_extrude(height=dish_depth + hub_thickness + 220)
                annulus_2d(dish_r - rim_width - 12, dish_r + 8);
    }
}

// Arm from the enclosure face to the rim, not yet cut behind the hoop.
module arm_prism(th) {
    intersection() {
        arm_blank(th, arm_width, arm_height, 4, 2);
        arm_clip(th);
        arm_rim_clip();
    }
}

// Printed strut at azimuth th.
module arm_solid(th) {
    difference() {
        arm_prism(th);
        if (!(rear_box && th == 270))
            behind_dish_back();
    }
}

// All four arm blanks. With a rear box the 270° arm runs to the outer hoop;
// the bore still stops at the inner rim.
module arms_solid() {
    difference() {
        union() {
            for (q = [0:2])
                arm_prism(arm_theta(q));
            if (!rear_box)
                arm_prism(270);
        }
        behind_dish_back();
    }
    if (rear_box)
        arm_prism(270);
}

// XY of the back opening: bore-wide strip along the 270° arm, from the inner
// rim toward the hub. pad_in lengthens it hub-ward; half_w is the X half-span.
module feed_mouth_2d(pad_in, half_w) {
    r1 = feed_bore_r1();
    r0 = feed_bore_r0() - pad_in;
    intersection() {
        translate([-half_w, -r1 - 2])
            square([2 * half_w, r1 - r0 + 4]);
        annulus_2d(max(r0, hub_radius), r1);
    }
}

// Solid honeycomb fill around the extra mouth: side walls flush with the arm,
// and a hub-ward bulkhead, so the cut does not open into the cells.
module feed_mouth_walls() {
    para_layer(0, honeycomb_back)
        difference() {
            feed_mouth_2d(arm_wall, arm_width / 2);
            feed_mouth_2d(0, feed_bore_width / 2);
        }
}

// Conduit through the quadrant-4 arm. Concentric with the arm. The rim-ward
// end is a Z-cylinder of the inner-rim curve, short of the hoop. The back
// opening continues hub-ward through the dish so the mouth is wide enough.
module feed_void() {
    th = 270;
    intersection() {
        arm_blank(th, feed_bore_width, feed_bore_height, enclosure_wall + 10, 2);
        translate([0, 0, clip_z0()])
            cylinder(h=clip_h(), r=feed_bore_r1(), $fn=shell_fn);
    }
    para_layer(skin_thickness, honeycomb_back + arm_height)
        feed_mouth_2d(0, feed_bore_width / 2);
}

// Rounded square of half-width `half`.
module rounded_square(half, rad) {
    offset(r=rad) offset(delta=-rad) square([half * 2, half * 2], center=true);
}

// Feed-enclosure gasket outline.
module gasket_2d() {
    difference() {
        rounded_square(gasket_half + gasket_w / 2, 3);
        rounded_square(gasket_half - gasket_w / 2, 2.2);
    }
}

// Matching groove in a feed-enclosure lid land.
module groove_2d() {
    difference() {
        rounded_square(gasket_half + groove_w / 2, 3);
        rounded_square(gasket_half - groove_w / 2, 2.2);
    }
}

// Four corner posts of the feed enclosure.
module corner_posts() {
    for (sx = [-1, 1], sy = [-1, 1])
        translate([sx * enclosure_size / 2, sy * enclosure_size / 2, 0])
            cylinder(h=enclosure_height, r=post_r, center=true, $fn=32);
}

// Feed box in local coordinates, origin at the box center.
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

// Screw pilots in the corner posts, both lid faces.
module pilots() {
    for (sx = [-1, 1], sy = [-1, 1], s = [-1, 1]) {
        z0 = s > 0 ? enclosure_height / 2 - pilot_depth : -enclosure_height / 2 - 0.05;
        translate([sx * enclosure_size / 2, sy * enclosure_size / 2, z0])
            cylinder(h=pilot_depth + 0.1, d=pilot_d, $fn=24);
    }
}

// Feed box at the focus, opening toward −Z.
module enclosure_world() {
    translate([0, 0, focal_length + enclosure_height / 2])
        enclosure_local();
}

// Countersunk through-holes for the feed-enclosure lid screws.
module lid_holes() {
    for (sx = [-1, 1], sy = [-1, 1]) {
        translate([sx * enclosure_size / 2, sy * enclosure_size / 2, -0.2])
            cylinder(h=lid_t + 0.4, d=hole_d, $fn=24);
        translate([sx * enclosure_size / 2, sy * enclosure_size / 2, lid_t - csk_h])
            cylinder(h=csk_h + 0.02, d1=hole_d, d2=csk_d, $fn=32);
    }
}

// Feed-enclosure lid. Front is a thin radome over the inner opening.
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

// TPU gasket for a feed-enclosure lid land.
module gasket() {
    linear_extrude(gasket_h)
        gasket_2d();
}

// Rear-box footprint: hub-ward rectangle clipped to the rim circle.
module rear_box_2d(grow = 0) {
    offset(delta = grow)
        intersection() {
            translate([rear_x0(), -rear_rim_outer() - 1])
                square([rear_box_w, rear_y_hub() + rear_rim_outer() + 1]);
            circle(r = rear_rim_outer(), $fn = shell_fn);
        }
}

// Inner cavity outline of the rear box.
module rear_box_inner_2d() {
    offset(delta = -enclosure_wall)
        rear_box_2d();
}

// Hatch opening inset from the rear-box outline, leaving a gasket land.
module rear_hatch_2d() {
    offset(delta = -rear_hatch_inset)
        rear_box_2d();
}

// Hollow of the rear box. Stops short of the rim hoop.
module rear_box_cavity() {
    difference() {
        intersection() {
            translate([0, 0, rear_z_lid() + lip_t])
                linear_extrude(rear_z_top() - rear_z_lid())
                    rear_box_inner_2d();
            para_slab(
                rear_front_t, honeycomb_back + rear_box_depth + 82
            );
        }
        para_layer(-1, rim_back_t + 1)
            annulus_2d(dish_r - rim_width - 2, dish_r + 2);
    }
}

// Material outside the dish radius so the rim-side wall is the hoop, square to the lid.
module rear_rim_collar_void() {
    z0 = z_of(dish_r) - rim_back_t;
    translate([0, 0, z0])
        linear_extrude(rear_z_top() - z0 + 2)
            difference() {
                circle(r = rear_rim_outer() + 20, $fn = shell_fn);
                circle(r = dish_r, $fn = shell_fn);
            }
}

// Rear-hatch gasket outline.
module rear_gasket_2d() {
    difference() {
        offset(delta = -(rear_hatch_inset - gasket_w / 2))
            rear_box_2d();
        offset(delta = -(rear_hatch_inset + gasket_w / 2))
            rear_box_2d();
    }
}

// Matching groove in the rear lid.
module rear_groove_2d() {
    difference() {
        offset(delta = -(rear_hatch_inset - groove_w / 2))
            rear_box_2d();
        offset(delta = -(rear_hatch_inset + groove_w / 2))
            rear_box_2d();
    }
}

// Screw bosses inboard of the hatch, on the lid plane.
module rear_box_bosses() {
    h = lip_t + pilot_depth + 2;
    for (p = rear_boss_xy())
        translate([p[0], p[1], rear_z_lid()])
            cylinder(h=h, r=post_r, $fn=32);
}

// Screw pilots in the rear-box bosses.
module rear_box_pilots() {
    for (p = rear_boss_xy())
        translate([p[0], p[1], rear_z_lid() - 0.05])
            cylinder(h=pilot_depth + 0.1, d=pilot_d, $fn=24);
}

// Raspberry Pi posts: parallel +Z cylinders. Free ends share a plane facing the
// hatch. Each post is pi_standoff_h plus the extra to reach its dish-side wall,
// so changing the slider shortens or lengthens every post by the same amount.
module pi_standoffs() {
    zb = pi_board_z();
    for (sx = [-1, 1], sy = [-1, 1]) {
        p = pi_hole_xy(sx, sy);
        h = pi_post_len(sx, sy);
        difference() {
            translate([p[0], p[1], zb])
                cylinder(h=h + 1, d=pi_standoff_d, $fn=24);
            translate([p[0], p[1], zb - 0.05])
                cylinder(h=pi_standoff_h + 0.6, d=pi_pilot_d, $fn=20);
        }
    }
}

// Rear Pi box: prism to the rim arc, hatch in the back wall, bosses, and Pi posts.
module rear_box_body() {
    difference() {
        union() {
            difference() {
                difference() {
                    intersection() {
                        translate([0, 0, rear_z_lid()])
                            linear_extrude(rear_z_top() - rear_z_lid())
                                rear_box_2d();
                        // Clip to the dish back. t = 0 is the mesh inner face. Outer radius is past
                        // the rim circle so the extruded rim wall stays square to the lid.
                        para_slab(
                            0, honeycomb_back + rear_box_depth + 80
                        );
                    }
                    rear_rim_collar_void();
                }
                rear_box_cavity();
                translate([0, 0, rear_z_lid() - 1])
                    linear_extrude(lip_t + 2)
                        rear_hatch_2d();
            }
            rear_box_bosses();
            if (pi_mount)
                pi_standoffs();
        }
        rear_box_pilots();
    }
}

// Hatch cover for the rear box, gasket groove and countersunk screws.
module rear_lid() {
    difference() {
        linear_extrude(lid_t)
            rear_box_2d();
        translate([0, 0, -0.05])
            linear_extrude(groove_d + 0.05)
                rear_groove_2d();
        for (p = rear_boss_xy()) {
            translate([p[0], p[1], -0.2])
                cylinder(h=lid_t + 0.4, d=hole_d, $fn=24);
            translate([p[0], p[1], lid_t - csk_h])
                cylinder(h=csk_h + 0.02, d1=hole_d, d2=csk_d, $fn=32);
        }
    }
}

// TPU gasket for the rear hatch.
module rear_gasket() {
    linear_extrude(gasket_h)
        rear_gasket_2d();
}

// Rear lid in assembly pose, facing −Z like the pole bracket.
module place_rear_lid() {
    translate([0, 0, rear_z_lid()])
        mirror([0, 0, 1])
            rear_lid();
}

// Rear gasket on the hatch land.
module place_rear_gasket() {
    translate([0, 0, rear_z_lid()])
        mirror([0, 0, 1])
            rear_gasket();
}

// Radome on the dish-facing face of the feed box.
module place_front_lid() {
    translate([0, 0, focal_length])
        mirror([0, 0, 1])
            lid(true);
}

// Back lid of the feed box, facing +Z.
module place_back_lid() {
    translate([0, 0, focal_length + enclosure_height])
        lid(false);
}

// Feed-enclosure gasket. s = −1 front, +1 back; proud toward the lid.
module place_gasket(s) {
    translate([0, 0, focal_length + (s > 0 ? enclosure_height : 0)])
        if (s > 0)
            gasket();
        else
            mirror([0, 0, 1]) gasket();
}

// The bed edge is the arm-side plane that sits on the printer. The other edge
// is the neighbor's arm-side plane. Normals point into this quadrant.
function edge_normal(q, bed) = bed ? bed_up(q) : bed_up((q + 3) % 4);

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

// Strip along one quadrant cut, from depth d0 to d1 along the inward normal.
// World-XY polygon: 2D multmatrix 3x3 does not apply the corner translation.
module edge_strip_2d(q, bed, d0, d1) {
    n = edge_normal(q, bed);
    t = edge_tangent(q, bed);
    o = edge_corner(q);
    len = rim_xy + arm_width / 2 + 4;
    o2 = [o[0], o[1]];
    n2 = [n[0], n[1]];
    t2 = [t[0], t[1]];
    polygon([
        o2 + n2 * d0,
        o2 + n2 * d1,
        o2 + n2 * d1 + t2 * len,
        o2 + n2 * d0 + t2 * len
    ]);
}

module edge_strip_ring_2d(q, bed, d0, d1, r0, r1) {
    intersection() {
        edge_strip_2d(q, bed, d0, d1);
        annulus_2d(r0, r1);
    }
}

// Solid honeycomb fill along one cut, from the mesh front through cell depth.
// The bed strip stays on the print plane, crosses the arm, and continues
// upright_band past the far face. The upright strip is that same distance
// past the cut, plus 0.2 mm of overlap so the quadrants share volume. The
// strip runs through the inner rim so it meets the hoop.
module edge_binding(q, bed) {
    para_layer(0, honeycomb_back)
        edge_strip_ring_2d(
            q, bed,
            bed ? 0 : -0.2,
            bed ? arm_width + upright_band : upright_band,
            hub_radius - 2, dish_r - 1
        );
}

// Half-lap footprint along one cut. Stops short of the hub, rim hoop, and rear box.
module lap_zone_2d(q, bed, d0, d1) {
    difference() {
        edge_strip_ring_2d(q, bed, d0, d1, lap_r0(), lap_r1());
        if (rear_box)
            offset(delta = lap_keep)
                rear_box_2d();
    }
}

// Rear half of the bed strip, cut away so the upright lap can sit in it.
module bed_rabbet(q) {
    para_layer(lap_t - lap_clear, honeycomb_back + 2)
        lap_zone_2d(q, true, -0.2, lap_w + lap_clear);
}

// Rear half of the upright strip, extended into the bed rabbet.
module upright_lap(q) {
    para_layer(lap_t, honeycomb_back)
        lap_zone_2d(q, false, -lap_w, 0.2);
}

module seam_insert_at(p) {
    r = sqrt(p[0] * p[0] + p[1] * p[1]);
    z_face = z_of(r) - lap_t;
    translate([p[0], p[1], z_face - 0.2])
        cylinder(h=seam_insert_h() + 0.2, d=seam_insert_d(), $fn=24);
}

module seam_through_at(p) {
    r = sqrt(p[0] * p[0] + p[1] * p[1]);
    z_back = z_of(r) - honeycomb_back;
    z_face = z_of(r) - lap_t;
    translate([p[0], p[1], z_back - 4])
        cylinder(h=z_face - z_back + 4.2, d=seam_bolt_hole(), $fn=24);
}

module assembly_bindings() {
    para_layer(0, honeycomb_back)
        union() {
            for (q = [0:3]) {
                edge_strip_ring_2d(q, true, 0, arm_width + upright_band, hub_radius - 2, dish_r - 1);
                edge_strip_ring_2d(q, false, -0.2, upright_band, hub_radius - 2, dish_r - 1);
            }
        }
}

module assembly_rabbets() {
    for (q = [0:3])
        bed_rabbet(q);
}

module assembly_upright_laps() {
    for (q = [0:3])
        upright_lap(q);
}

module assembly_fasteners() {
    for (q = [0:3], i = [0:seam_n - 1]) {
        p = seam_bolt_xy(q, i);
        seam_insert_at(p);
        seam_through_at(p);
    }
}

module seam_fasteners(q) {
    for (i = [0:seam_n - 1]) {
        seam_insert_at(seam_bolt_xy(q, i));
        seam_through_at(seam_bolt_xy((q + 1) % 4, i));
    }
}

function bolt_xy(i) = let(a = 45 + i * 90) [bolt_circle_r * cos(a), bolt_circle_r * sin(a)];

function hub_bolt_recess_d() =
    hub_bolt_recess == "hex" ? hub_bolt_recess_size / cos(30) : hub_bolt_recess_size;

// Pocket coaxial with the shank hole. The dish face is sloped, so the floor
// is set from the inboard (shallow) edge so the whole head sits below the face.
module hub_bolt_recess_at(p) {
    rr = hub_bolt_recess_d() / 2;
    z_top = z_of(bolt_circle_r + rr) + 1;
    z_bot = z_of(max(bolt_circle_r - rr, 0)) - hub_bolt_recess_h;
    translate([p[0], p[1], z_bot])
        cylinder(
            h=z_top - z_bot,
            d=hub_bolt_recess_d(),
            $fn=hub_bolt_recess == "hex" ? 6 : 48
        );
}

// Through-holes, one in each quadrant, from the hub back through the front.
// Optional round or hex seats for the heads on the inner face.
module hub_bolt_holes() {
    for (i = [0:3]) {
        p = bolt_xy(i);
        translate([p[0], p[1], -hub_thickness - 2])
            cylinder(h=hub_thickness + 10, d=bolt_d, $fn=24);
        if (hub_bolt_recess != "none" && hub_bolt_recess_h > 0)
            hub_bolt_recess_at(p);
    }
}

// Square hole at the hub left by the four offset seams.
module key_void() {
    translate([-arm_width / 2, -arm_width / 2, -hub_thickness - 4])
        cube([arm_width, arm_width, hub_thickness + 30]);
}

// Dish, arms, and feed-mouth walls. q < 0 is the full reflector.
module dish_fill(q = -1) {
    union() {
        dish_body(q);
        if (q < 0)
            arms_solid();
        else
            arm_solid(arm_theta(q));
        if (q < 0 || q == 3)
            feed_mouth_walls();
    }
}

module reflector_positive(q = -1) {
    difference() {
        union() {
            dish_fill(q);
            if (q < 0)
                assembly_bindings();
            else {
                edge_binding(q, true);
                edge_binding(q, false);
            }
        }
        if (rear_box)
            rear_box_cavity();
        if (q < 0)
            assembly_rabbets();
        else
            bed_rabbet(q);
    }
    if (q < 0)
        assembly_upright_laps();
    else
        upright_lap(q);
}

// One quadrant in world coordinates, including its arm, seams, and rear box.
// Bindings stay outside quadrant_region so the 0.2 mm upright overlap remains.
module quadrant_raw(q) {
    difference() {
        union() {
            difference() {
                union() {
                    intersection() {
                        quadrant_region(q);
                        union() {
                            dish_fill(q);
                            enclosure_world();
                        }
                    }
                    edge_binding(q, true);
                    edge_binding(q, false);
                }
                if (rear_box)
                    rear_box_cavity();
                bed_rabbet(q);
            }
            upright_lap(q);
            if (rear_box)
                intersection() {
                    quadrant_region(q);
                    rear_box_body();
                }
        }
        hub_bolt_holes();
        seam_fasteners(q);
        if (q == 3)
            feed_void();
    }
}

// Rotate so the bed arm face of quadrant q lies on XY, +Z out of the bed.
module lay_flat(q) {
    b = basis(q);
    multmatrix([
        [b[0][0], b[0][1], b[0][2], 0],
        [b[1][0], b[1][1], b[1][2], 0],
        [b[2][0], b[2][1], b[2][2], 0],
        [0, 0, 0, 1]
    ]) children();
}

// Quadrant on the print bed, yawed by print_yaw, sitting on z = 0.
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
        // Hose-clamp slot through the flange, deep enough to clear the first stair.
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

// Assembled dish, lids, gaskets, pole bracket, and optional rear box.
module assembly() {
    difference() {
        union() {
            reflector_positive(-1);
            enclosure_world();
            if (rear_box)
                rear_box_body();
        }
        feed_void();
        key_void();
        hub_bolt_holes();
        assembly_fasteners();
    }
    place_front_lid();
    place_back_lid();
    place_gasket(-1);
    place_gasket(1);
    pole_bracket();
    if (rear_box) {
        place_rear_lid();
        place_rear_gasket();
    }
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
else if (part == "rear_lid") rear_lid();
else if (part == "rear_gasket") rear_gasket();
else assert(false, str("Unknown part ", part));
