// name: 5.8 GHz rib dish
// description: 400 mm prime-focus rib frame · feed arm · focal box
//
// 5.8 GHz prime-focus rib frame. Units: mm. OpenSCAD 2021.01+. No libraries.
// Vertex at the origin, opening toward +Z, focus at z = focal_length.
// Structure sits behind the paraboloid (toward -Z). Hub dovetails open on
// the dish face (Z+) so the hub prints on its back with no overhangs. The
// feed-arm hub joint is three equal radial thirds: an inner parabolic
// lip over a through-slot for tab insertion, a mid bar at the deep tab
// floor with the dish face on the rib, and an outer raised dovetail in
// the hub parabola with a heat-set insert and a recessed face bolt.
// Rim segments splice with a circular-slide mortise and
// tenon that is flat-backed like the rim and centered in its axial
// thickness, pinned with two Z filament holes
// and one radial hole. Splices are a circular mortise and tenon: the
// socket piece keeps the full rim section, and the pocket recesses along
// the arc. Radial ribs have a matching through-channel so rim tenons
// meet at the rib midplane. The rib socket has a flat -Z wall parallel to
// the tenon floor, the same as the rim splice. Thin ribs clip
// into the hub and rim and take a
// filament secant at the hub and rim. No mesh or metal in the model. Identical
// radial ribs (1 to 8), one rib with a Z-axis arm mount whose hub tab runs
// to the axis. Full-height hoop strips print straight and bow into slots
// on the ribs, carrying stainless mesh on the paraboloid. A hollow feed
// arm sleeves the mount, or prints as one piece with the mount rib, and
// carries cables to a focus-centered box with two lids. A pole bracket
// bolts to the hub back with four screws and hose-clamps to a mast.

/* [Selection] */
part = "assembly"; // [assembly, hub, radial_rib, radial_rib_mount, radial_rib_arm, rim_segment, thin_rib, mesh_hoop, feed_arm, enclosure_body, radome_lid, reflector_lid, gasket, pole_bracket]
fast_preview = true;

/* [Dish] */
frequency_GHz = 5.8; // [5:0.1:6.5]
dish_diameter = 400; // [250:1:600]
focal_length = 150; // [80:1:300]
n_ribs = 1; // [1:1:8]

/* [Stock] */
hub_od_ratio = 0.28; // [0.16:0.01:0.45]
thickness = 15; // [8:0.5:32]
rim_w = 8; // [6:0.5:16]
rim_h = 12; // [6:0.5:24]
lap_w = 16; // [12:0.5:28]
lap_clear = 0.25; // [0.1:0.05:0.6]
printer_bed_mm = 256; // [180:1:400]

/* [Mesh hoops] */
hoop_count = 2; // [0:1:8]
hoop_index = 0; // [0:1:7]
hoop_seg = 0; // [0:Rib end, 1:Mid span]
hoop_w = 6; // [3:0.5:12]
hoop_t = 1.2; // [0.8:0.1:4]
thin_ribs = 7; // [0:1:8]
rim_index = 0; // [0:1:15]

/* [Feed arm] */
arm_along = 28; // [22:0.5:50]
arm_across = 20; // [14:0.5:32]
arm_wall = 2.5; // [1.2:0.1:8]
mount_h = 24; // [16:0.5:40]
socket_len = 32; // [20:0.5:50]
arm_slip = 0.25; // [0.1:0.05:0.6]
feed_joint = "combined"; // [split:Separate arm, combined:Combined rib and arm]

/* [Enclosure] */
enclosure_x = 50; // [20:1:80]
enclosure_y = 50; // [30:1:120]
cavity_steps = 0; // [0:1:8]
enc_wall = 6; // [4:0.5:12]
lid_floor = 1.5; // [0.8:0.1:4]
lid_flange = 3.5; // [2.5:0.1:8]
gasket_w = 2.2; // [1.5:0.1:4]
gasket_h = 2.2; // [1.6:0.1:4]
groove_w = 2; // [1.4:0.1:3.5]
groove_d = 1; // [0.6:0.1:1.6]

/* [Pole bracket] */
pole_diameter = 32; // [20:0.5:60]
pole_clearance = 0.8; // [0.2:0.1:2]
v_included = 120; // [60:1:130]
clamp_band_width = 12.7; // [8:0.1:20]
clamp_slot = 2.5; // [1.5:0.1:4]
clamp_pitch = 72; // [50:1:140]
bolt_d = 5; // [3:0.1:8]
bolt_circle_r = 28; // [16:1:40]
hub_pole_face = "through"; // [through:Through hole, round:Recessed round, hex:Recessed hex, insert:Threaded insert]
hub_pole_seat_size = 9; // [5:0.1:16]
hub_pole_seat_h = 3.2; // [0:0.1:10]

/* [Hidden] */
$fa = fast_preview ? 12 : 6;
$fs = fast_preview ? 2 : 0.8;
rim_arm_cw = false;
rim_arm_ccw = false;

n_para = fast_preview ? 16 : 40;
eps = 0.2;
insert_d = 4.0;
insert_h = 4;
bolt_hole = 3.3;
filament_d = 1.75;
dt_angle = 12;
hub_dt_extra = 4;
dt_join = 0.6;
tenon_wall = 1.6;
cap_head_d = 6;
cap_head_h = 3.4;
mount_gap = 1;
gasket_lip = 2;
gasket_land = 1.2;
boss_r = insert_d / 2 + 1.8;
sock_wall = 2.5;
groove_round = 1;
fastener_clear = insert_d / 2 + 3;

lambda_mm = 299.792458 / frequency_GHz;
dish_r = dish_diameter / 2;
dish_depth = dish_diameter * dish_diameter / (16 * focal_length);
f_D = focal_length / dish_diameter;
hub_od = hub_od_ratio * dish_diameter;
hub_r = hub_od / 2;
hub_t = thickness;
rib_h = thickness;
hub_dt_len = lap_w + hub_dt_extra;
rib_r0 = hub_r - hub_dt_len;
rib_r1 = dish_r;
rim_r0 = dish_r - rim_w;
z_floor = dish_depth - rim_h;
hub_hole_r = hub_r - hub_dt_len / 2;
rim_hole_r = dish_r - rim_w / 2;

cavity_h = (0.75 + cavity_steps * 0.5) * lambda_mm;
mount_along_id = arm_along - 2 * arm_wall;
mount_across_id = arm_across - 2 * arm_wall;
boot_along_id = arm_along + 2 * arm_slip;
boot_across_id = arm_across + 2 * arm_slip;
boot_along_od = boot_along_id + 2 * arm_wall;
boot_across_od = boot_across_id + 2 * arm_wall;
rib_w = boot_across_od;
rib_face_ang = atan(rib_w / 2 / dish_r);
rim_center_gap_ang = atan(lap_clear / 2 / dish_r);
rim_half_ang = 180 / n_ribs - rib_face_ang;
use_square_arm = feed_joint == "combined" || part == "radial_rib_arm";
feed_along_od = use_square_arm ? boot_across_od : boot_along_od;
feed_across_od = boot_across_od;
feed_along_id = use_square_arm ? boot_across_id : boot_along_id;
feed_across_id = boot_across_id;
mount_along = use_square_arm ? feed_along_od : arm_along;
hoop_clip = 5;
hoop_over = hoop_clip;
slot_t = hoop_t + 2 * lap_clear;
thin_rib_clear = 0.05;
thin_slot_t = hoop_t + 2 * thin_rib_clear;
pi_ = 3.141592653589793;
function spin_fn(r) =
    min(
        fast_preview ? 360 : 720,
        max(96, ceil(2 * pi_ * r / (fast_preview ? 2 : 0.8)))
    );
lap_ang = lap_w / rim_hole_r * 180 / pi_;
thin_rib_r0 = hub_r - hoop_clip;
thin_rib_r1 = rim_r0 + hoop_clip;
thin_rib_h = rib_h - 1.2;
function thin_rib_rim_pin_r() = rim_r0 + hoop_clip / 2;
function thin_rib_hub_pin_r() = hub_r - hoop_clip / 2;
function thin_rib_pin_z_at(r) = z_of(r) - thin_rib_h / 2;
hoop_h = thin_rib_h;
z_skirt = rim_r0 * rim_r0 / (4 * focal_length) - rib_h;
end_keep_ang = rib_face_ang - rim_center_gap_ang;
sock_along_id = feed_along_od + 2 * arm_slip;
sock_across_id = feed_across_od + 2 * arm_slip;
sock_along_od = sock_along_id + 2 * sock_wall;
sock_across_od = sock_across_id + 2 * sock_wall;
mount_insert_off = mount_along_id / 2 - insert_d / 2 + 1.2;
arm_end_keep = insert_d / 2 + 1.6;
arm_insert_off = feed_along_id / 2 - insert_d / 2 + 1.2;
pad_r = insert_d / 2 + 2.4;
pad_len = insert_h + 0.2 - arm_wall + 1.0;
enc_z_keep = gasket_lip + groove_w + 0.8;
r_mount = rim_r0 - mount_along / 2 - (use_square_arm ? 0 : mount_gap);
z_mount_face = r_mount * r_mount / (4 * focal_length);
z_knee = z_mount_face + (use_square_arm ? 0 : mount_h);
p_knee = [r_mount, 0, z_knee];
face_x = enclosure_x / 2 + enc_wall;
enc_meet_dx = face_x - p_knee[0];
enc_meet_dz = focal_length - p_knee[2];
enc_meet_d = sqrt(enc_meet_dx * enc_meet_dx + enc_meet_dz * enc_meet_dz);
arm_ang = atan2(enc_meet_dz, enc_meet_dx) - asin(sock_along_od / 2 / enc_meet_d);
p_enc = [face_x, 0, p_knee[2] + enc_meet_dx * tan(arm_ang)];
arm_dx = p_enc[0] - p_knee[0];
arm_dz = p_enc[2] - p_knee[2];
arm_len = sqrt(arm_dx * arm_dx + arm_dz * arm_dz);
arm_elbow_s = (feed_along_od / 2) * (1 - sin(arm_ang)) / cos(arm_ang);
z_elbow = p_knee[2] + (feed_along_od / 2) * (sin(arm_ang) - 1) / cos(arm_ang);
arm_elbow_s_id = (feed_along_id / 2) * (1 - sin(arm_ang)) / cos(arm_ang);
z_elbow_id = p_knee[2] + (feed_along_id / 2) * (sin(arm_ang) - 1) / cos(arm_ang);
groove_outer_x = enclosure_x / 2 + gasket_lip + groove_w;
groove_outer_y = enclosure_y / 2 + gasket_lip + groove_w;
bolt_x = groove_outer_x + gasket_land + bolt_hole / 2;
bolt_y = groove_outer_y + gasket_land + bolt_hole / 2;
arm_insert_s = arm_len - socket_len + arm_end_keep;
z_mount_rim = (r_mount + mount_along / 2) * (r_mount + mount_along / 2) / (4 * focal_length);
z_mount_top_rim = z_knee;
z_mount_top_hub = z_mount_top_rim - mount_along * tan(arm_ang);
mount_insert_z = (z_mount_rim + z_mount_face + mount_h) / 2;
miter_skew = (feed_along_od / 2) * abs(arm_dz / arm_dx);
flange_t = 8;
cheek_y = clamp_band_width + 6;
pole_r = pole_diameter / 2 + pole_clearance;
flange_back = -hub_t - flange_t;
v_angle = v_included / 2;
v_steps = 6;
v_wall = 4;
z_apex = flange_back;
v_depth = pole_r / sin(v_angle);
stair_x = v_depth * tan(v_angle) / v_steps;
stair_z = v_depth / v_steps;
pole_cz = z_apex - v_depth;
cheek_back = pole_cz;
v_half = v_steps * stair_x;
min_clamp_pitch = 2 * (bolt_circle_r * sin(45) + bolt_d / 2 + 1) + cheek_y;
station_pitch = max(clamp_pitch, min_clamp_pitch);
flange_hx = max(v_half + v_wall, bolt_circle_r * cos(45) + bolt_d / 2 + 3);
flange_hy = max(station_pitch / 2 + cheek_y / 2, bolt_circle_r * sin(45) + bolt_d / 2 + 3);

function z_of(r) = r * r / (4 * focal_length);
function hub_dt_waist(clear=0) = rib_w - 2 * hub_dt_len * tan(dt_angle) + 2 * clear;
function hub_dt_wide(clear=0) = rib_w + 2 * clear;
function hub_fil_r(k) = hub_r - k * hub_dt_len;
function arm_dt_waist(clear=0) = rib_w - 2 * (hub_r - arm_sec2) * tan(dt_angle) + 2 * clear;
z_hub_lap = z_of(hub_r) - rib_h / 2;
z_arm_lap = -hub_t + insert_h + 1;
z_arm_dt = z_of(hub_r) - rib_h * 2 / 3;
arm_sec1 = hub_r / 3;
arm_sec2 = 2 * hub_r / 3;
arm_bolt_r = (arm_sec2 + hub_r) / 2;
arm_lip_bolt_r = arm_sec1 / 2;
arm_fil_r1 = (arm_sec1 + arm_sec2) / 2;
arm_fil_r2 = min(hub_r - 2.4, arm_bolt_r + insert_d / 2 + filament_d + 2.4);
function arm_fil_z(r) = let (z0 = r < arm_sec2 ? z_arm_lap : z_arm_dt) (z0 + z_of(r)) / 2;
z_mount_bore0 = z_of(r_mount - feed_along_od / 2) - rib_h - 2;

function para_pts(r0, r1, dz) =
    [for (i = [0:n_para])
        let (r = r0 + (r1 - r0) * i / n_para)
            [r, z_of(r) + dz]];

function hub_print_h() = hub_t + z_of(hub_r);
function rib_print_x() = rib_r1 - rib_r0;
function rib_print_y() =
    z_of(rib_r1) - min(z_of(rib_r0) - rib_h, z_rim_back);
function rib_mount_print_x() = rib_r1;
function rib_mount_print_y() =
    max(z_of(rib_r1), z_mount_top_hub) + rib_h;
function rib_arm_print_x() = rib_r1;
function rib_arm_print_y() =
    max(z_of(rib_r1), z_mount_top_hub, p_enc[2] + sock_along_od / 2) + rib_h;
function z_mount_top(x) =
    z_mount_top_rim + (x - r_mount - mount_along / 2) * tan(arm_ang);
function rim_foot_x_h(h) = dish_r - rim_r0 * cos(h);
function rim_foot_y_h(h) = 2 * dish_r * sin(h);
function rim_foot_x() = rim_foot_x_h(rim_piece_half + end_keep_ang + (rim_div > 1 ? lap_ang : 0));
function rim_foot_y() = rim_foot_y_h(rim_piece_half + end_keep_ang + (rim_div > 1 ? lap_ang : 0));
function bed_rot(ax, ay) =
    ax <= printer_bed_mm && ay <= printer_bed_mm ? 0 : 45;
function bed_span_x(ax, ay) =
    let (a = bed_rot(ax, ay))
        abs(ax * cos(a)) + abs(ay * sin(a));
function bed_span_y(ax, ay) =
    let (a = bed_rot(ax, ay))
        abs(ax * sin(a)) + abs(ay * cos(a));
function rim_print_x() = bed_span_x(rim_foot_x(), rim_foot_y());
function rim_print_y() = bed_span_y(rim_foot_x(), rim_foot_y());
function feed_arm_print_x() = r_mount + feed_along_od / 2 - face_x + 4;
function lid_outer_x() = 2 * max(enclosure_x / 2 + enc_wall, bolt_x + boss_r);
function lid_outer_y() = 2 * max(enclosure_y / 2 + enc_wall, bolt_y + boss_r);
function rib_s(r) =
    let (a = 2 * focal_length, u = r / a, n = sqrt(1 + u * u))
        r / 2 * n + a / 2 * ln(u + n);

function hoop_r_at_s(s, r = (hub_r + rim_r0) / 2, n = 8) =
    n <= 0 ? r :
    let (r2 = r - (rib_s(r) - s) / sqrt(1 + pow(r / (2 * focal_length), 2)))
        hoop_r_at_s(s, r2, n - 1);

function hoop_r(i) =
    let (s0 = rib_s(hub_r), s1 = rib_s(rim_r0))
        hoop_r_at_s(s0 + (s1 - s0) * (i + 1) / (hoop_count + 1));
function hoop_az_face(r) = asin((rib_w / 2) / r);
function hoop_span(r) = 360 / n_ribs - 2 * hoop_az_face(r);
function hoop_piece_len(r, div) =
    r * hoop_span(r) / div * pi_ / 180
        + (div == 1 ? 2 * hoop_clip : hoop_clip + hoop_over);
function hoop_fits_len(len) =
    bed_span_x(len, hoop_h) <= printer_bed_mm
        && bed_span_y(len, hoop_h) <= printer_bed_mm;
function hoop_div_from(d) =
    d >= 16 ? d :
        (hoop_fits_len(hoop_piece_len(rim_r0, d)) ? d : hoop_div_from(d + 1));
hoop_div_need = hoop_count == 0 ? 1 : hoop_div_from(1);
hoop_div = hoop_count == 0 ? 1 :
    (hoop_div_need == 1 ? 1 :
        (thin_ribs > 0 ? max(hoop_div_need, thin_ribs + 1) : hoop_div_need));
thin_n = thin_ribs <= 0 ? 0 :
    (hoop_div > 1 ? max(thin_ribs, hoop_div - 1) : thin_ribs);
function thin_frac(j) = (j + 1) / (thin_n + 1);
function thin_rib_taz(j) = (2 * thin_frac(j) - 1) * 180 / n_ribs;
function hoop_station_az(seg, r) =
    hoop_div <= 1 || thin_n <= 0 ?
        hoop_az_face(r) + seg * hoop_span(r) / hoop_div :
        (seg <= 0 ? hoop_az_face(r) :
            (seg >= hoop_div ? 360 / n_ribs - hoop_az_face(r) :
                thin_frac(seg - 1) * 360 / n_ribs));
function hoop_seg_len(r, seg) =
    let (
        ps = r * (hoop_station_az(seg + 1, r) - hoop_station_az(seg, r)) * pi_ / 180,
        s0 = seg == 0 ? hoop_clip : hoop_over,
        s1 = seg == hoop_div - 1 ? hoop_clip : hoop_over
    ) ps + s0 + s1;
function hoop_len(r) = hoop_seg_len(r, hoop_div <= 1 ? 0 : hoop_seg);
function hoop_print_x() = bed_span_x(hoop_len(hoop_r(hoop_index)), hoop_h);
function hoop_print_y() = bed_span_y(hoop_len(hoop_r(hoop_index)), hoop_h);
function rim_piece_fits(h) =
    h < 80
        && bed_span_x(rim_foot_x_h(h), rim_foot_y_h(h)) <= printer_bed_mm
        && bed_span_y(rim_foot_x_h(h), rim_foot_y_h(h)) <= printer_bed_mm;
function thin_hit(div, j = 0, k = 1) =
    thin_n <= 0 ? false :
        (j >= thin_n ? false :
            (k >= div ? thin_hit(div, j + 1, 1) :
                (abs(-rim_half_ang + k * 2 * rim_half_ang / div - thin_rib_taz(j)) < lap_ang + 1
                    ? true
                    : thin_hit(div, j, k + 1))));
function rim_div_from(d) =
    d >= 24 ? d :
        (!rim_piece_fits(rim_half_ang / d) ? rim_div_from(d + 1) :
            (thin_n > 0 && thin_hit(d) ? rim_div_from(d + 1) : d));
rim_div = rim_div_from(1);
rim_piece_half = rim_half_ang / rim_div;
function rim_step() = 2 * rim_piece_half;
function rim_base0(i) = -rim_half_ang + i * rim_step();
function rim_base1(i) = rim_base0(i) + rim_step();
function rim_body0(i) = rim_base0(i);
function rim_body1(i) = rim_base1(i);
function rim_a0(i) = rim_body0(i) - (i == 0 ? end_keep_ang : 0);
function rim_a1(i) = rim_body1(i) + (i == rim_div - 1 ? end_keep_ang : 0);
z_rim_back = thin_n > 0 ? z_skirt : z_floor;
z_lap_mid = z_rim_back + (z_of(rim_hole_r) - z_rim_back) / 2;
rim_ax_short = z_of(rim_r0) - z_rim_back;
tenon_h = min(rim_ax_short / 2, max(filament_d + 2.4, rim_ax_short - 2 * tenon_wall));
z_tenon_lo = z_rim_back + (rim_ax_short - tenon_h) / 2;
z_tenon_hi = z_tenon_lo + tenon_h;
z_tenon_mid = (z_tenon_lo + z_tenon_hi) / 2;
rim_tenon_r0 = rim_r0 + tenon_wall;
rim_tenon_r1 = dish_r - tenon_wall;
rim_fil_r = (rim_tenon_r0 + rim_tenon_r1) / 2;
function thin_rib_print_x() = thin_rib_r1 - thin_rib_r0;
function thin_rib_print_y() = z_of(thin_rib_r1) - (z_of(thin_rib_r0) - thin_rib_h);
function rim_print_z() = thin_n > 0 ? dish_depth - z_skirt : rim_h;
function bolt_xy(i) = let (a = 45 + i * 90) [bolt_circle_r * cos(a), bolt_circle_r * sin(a)];
function pole_insert_d() = bolt_d <= 3.2 ? 4.0 : (bolt_d <= 4.2 ? 5.6 : 6.5);
function hub_pole_recess_d() =
    hub_pole_face == "hex" ? hub_pole_seat_size / cos(30) : hub_pole_seat_size;
function hub_pole_pocket_d() =
    hub_pole_face == "insert" ? pole_insert_d() :
        (hub_pole_face == "through" ? bolt_d : hub_pole_recess_d());
function hub_pole_pocket_r() = hub_pole_pocket_d() / 2;
function pole_print_x() = 2 * flange_hy;
function pole_print_y() = 2 * flange_hx;
function pole_print_z() = -cheek_back;

echo(lambda_mm=lambda_mm, dish_depth_mm=dish_depth, f_D=f_D);
echo(n_ribs=n_ribs, rim_div=rim_div, hoop_div=hoop_div, thin_n=thin_n, hub_od=hub_od, thickness=thickness, rim_w=rim_w, rim_h=rim_h);
echo(rib_print=[rib_print_x(), rib_print_y(), rib_w]);
echo(rib_mount_print=[rib_mount_print_x(), rib_mount_print_y(), rib_w]);
echo(rib_arm_print=[rib_arm_print_x(), rib_arm_print_y(), rib_w]);
echo(thin_rib_print=[thin_rib_print_x(), thin_rib_print_y(), hoop_t]);
echo(rim_print=[rim_print_x(), rim_print_y(), rim_print_z()]);
echo(hub_print=[hub_od, hub_od, hub_print_h()]);
echo(
    hoop_radial_end=[
        hoop_count == 0 ? 0 : hoop_seg_len(hoop_r(0), 0),
        hoop_count * n_ribs * (hoop_div == 1 ? 1 : 2)
    ]
);
echo(
    hoop_thin_span=[
        hoop_count == 0 || hoop_div <= 2 ? 0 : hoop_seg_len(hoop_r(0), 1),
        hoop_count * n_ribs * max(hoop_div - 2, 0)
    ]
);
echo(cavity_h=cavity_h, r_mount=r_mount, arm_len=arm_len, arm_ang=arm_ang);
echo(boot_along_od=boot_along_od, boot_across_od=boot_across_od, feed_along_od=feed_along_od, feed_across_od=feed_across_od);

assert(thin_ribs >= 0 && thin_ribs <= 8, "Thin rib count must be 0 to 8");
assert(rib_r0 > 8, "Hub is too small for the dovetails");
assert(z_of(rib_r0) > z_hub_lap + 1, "Hub dovetail floor cuts through the rib face");
assert(z_of(hub_hole_r) - z_hub_lap > cap_head_h + 1.2, "Hub dovetail leaves no bolt stock on the rib");
assert(z_hub_lap > -hub_t + insert_h + 0.6, "Hub dovetail insert meets the slot floor");
assert(z_arm_lap > -hub_t + 2, "Arm tab floor meets the hub back");
assert(z_arm_lap < z_arm_dt - 1, "Arm tab floor is not below the dovetail step");
assert(z_of(0) - z_arm_dt > 1.6, "Arm hub lip is too thin");
assert(z_arm_dt > z_arm_lap + 1.6, "Arm hub lip meets the tab floor");
assert(z_arm_dt > -hub_t + insert_h + 0.6, "Arm dovetail insert meets the hub back");
assert(z_of(arm_bolt_r) - z_arm_dt > cap_head_h + 1.2, "Arm dovetail leaves no bolt stock on the rib");
assert(z_of(arm_lip_bolt_r) - z_arm_dt > insert_h + 0.5, "Arm lip insert meets the dish face");
assert(z_arm_dt - z_arm_lap > cap_head_h + 1.2, "Arm lip bolt recess is too deep");
assert(arm_lip_bolt_r > insert_d / 2 + 1.2, "Arm lip insert is too close to the axis");
assert(arm_lip_bolt_r + insert_d / 2 + 1.2 < arm_sec1, "Arm lip insert meets the lip edge");
assert(hub_r / 3 > insert_d + 6, "Arm dovetail is too short for the insert");
assert(arm_dt_waist() > insert_d + 1.6, "Arm dovetail is too narrow for the insert");
assert(arm_fil_r1 > arm_sec1 + filament_d, "Arm mid filament is inside the lip");
assert(arm_fil_r2 < hub_r - filament_d, "Arm outer filament is outside the hub");
assert(abs(arm_fil_r2 - arm_bolt_r) > insert_d / 2 + filament_d + 1.6, "Arm outer filament hits the dovetail bolt");
assert(thickness > insert_h + 1, "Stock is too thin for the insert");
assert(hub_dt_len > insert_d + filament_d + 6, "Hub dovetail is too short for insert and filament");
assert(hub_dt_waist() > filament_d + 2.4, "Hub dovetail is too narrow for filament");
assert(tenon_h > filament_d + 1.6, "Splice tenon is too thin for filament");
assert(rim_tenon_r1 - rim_tenon_r0 > filament_d + 1.6, "Splice tenon is too narrow for filament");
assert(rim_ax_short > filament_d + 2 * tenon_wall, "Rim axial face is too short for the tenon");
assert(lap_w > filament_d * 3 + 4, "Splice is too short for two filament pins");
assert(end_keep_ang > 0.2, "Rib is too thin for rim tenons to meet");
assert(thickness > bolt_hole + 0.4, "Stock is too thin for M3");
assert(rim_piece_half < 80, "Rim piece is too wide to print as a flat arc");
assert(hub_od <= printer_bed_mm, "Hub is wider than the printer");
assert(hub_print_h() <= printer_bed_mm, "Hub is taller than the printer");
assert(rib_print_x() <= printer_bed_mm, "Radial rib is longer than the printer");
assert(rib_print_y() <= printer_bed_mm, "Radial rib is taller than the printer");
assert(rib_mount_print_x() <= printer_bed_mm, "Arm-mount rib is longer than the printer");
assert(rib_mount_print_y() <= printer_bed_mm, "Arm-mount rib is taller than the printer");
assert(rib_arm_print_x() <= printer_bed_mm, "Combined rib and arm is longer than the printer");
assert(rib_arm_print_y() <= printer_bed_mm, "Combined rib and arm is taller than the printer");
assert(thickness <= printer_bed_mm, "Stock is thicker than the printer");
assert(rib_w <= printer_bed_mm, "Rib is wider than the printer");
assert(rim_print_x() <= printer_bed_mm, "Rim segment is too wide for the printer");
assert(rim_print_y() <= printer_bed_mm, "Rim segment is too long for the printer");
assert(rim_h <= printer_bed_mm, "Rim segment is thicker than the printer");
assert(arm_wall > 1.2, "Feed arm wall is too thin to print");
assert(mount_along_id > 4 && mount_across_id > 4, "Mount bore is too small for a cable");
assert(feed_along_id > 4 && feed_across_id > 4, "Feed arm bore is too small for a cable");
assert(arm_across <= rib_w, "Mount is wider than the rib");
assert(mount_insert_off + insert_d / 2 + 0.6 < arm_along / 2, "Mount insert breaks out of the end wall");
assert(pad_len < mount_across_id - 2, "Insert pad closes the arm mount");
assert(r_mount - mount_along / 2 > hub_r + 2, "Arm mount hits the hub");
assert(
    use_square_arm
        ? r_mount + mount_along / 2 <= rim_r0 + 0.05
        : r_mount + arm_along / 2 < rim_r0 - 0.2,
    "Arm mount hits the rim"
);
assert(groove_w + 0.2 <= gasket_lip + enc_wall, "Groove does not fit in the wall");
assert(bolt_x - bolt_hole / 2 > groove_outer_x + 0.6, "Lid bolts cut the gasket path");
assert(bolt_y - bolt_hole / 2 > groove_outer_y + 0.6, "Lid bolts cut the gasket path");
assert(lid_floor > groove_d, "Lid floor is thinner than the groove");
assert(lid_flange > groove_d + 1.2, "Lid flange is too thin for the groove");
assert(gasket_h > 2 * groove_d, "Gasket is too thin to crush in both grooves");
assert(cavity_h > enc_z_keep + 8, "Cavity is too short for the gasket wall");
assert(enc_meet_d > sock_along_od / 2 + 1, "Enclosure is too close to the arm knee");
assert(enclosure_y > sock_across_od + 4, "Enclosure is too narrow for the socket");
assert(feed_arm_print_x() <= printer_bed_mm, "Feed arm is longer than the printer");
assert(feed_across_od <= printer_bed_mm, "Feed arm is thicker than the printer");
assert(feed_along_od <= printer_bed_mm, "Feed arm is wider than the printer");
assert(lid_outer_x() <= printer_bed_mm, "Enclosure is wider than the printer");
assert(lid_outer_y() <= printer_bed_mm, "Enclosure is longer than the printer");
assert(cavity_h + sock_along_od <= printer_bed_mm, "Enclosure body is taller than the printer");
if (!use_square_arm) {
    assert(mount_h > z_mount_rim - z_mount_face + 2 * fastener_clear, "Arm mount is too short for the inserts");
    assert(mount_insert_z < z_mount_top(r_mount + mount_insert_off) - fastener_clear, "Mount insert is too close to the top");
    assert(mount_insert_z > z_mount_rim + fastener_clear, "Mount insert is too close to the dish");
}
assert(socket_len > arm_end_keep + miter_skew + fastener_clear, "Enclosure socket is too short for the bolts");
assert(arm_insert_off + insert_d / 2 + 0.6 < feed_along_od / 2, "Arm insert breaks out of the along wall");
assert(pad_len < feed_across_id - 2, "Insert pad closes the feed arm");
assert(bolt_circle_r + hub_pole_pocket_r() + 1.6 < rib_r0, "Pole bolts hit the rib dovetails");
assert(
    bolt_circle_r * sin(45) - hub_pole_pocket_r() > (rib_w + lap_clear) / 2 + 1.2,
    "Pole bolts hit the mount-rib tab"
);
assert(bolt_circle_r - hub_pole_pocket_r() > 4, "Pole bolts are too close to the hub axis");
assert(bolt_circle_r * cos(45) + bolt_d / 2 < flange_hx - 2, "Pole bolts leave the flange");
assert(bolt_circle_r * sin(45) + bolt_d / 2 < flange_hy - 2, "Pole bolts leave the flange");
assert(
    hub_pole_face == "through"
        || hub_pole_seat_h <= 0
        || hub_pole_seat_h < z_of(max(bolt_circle_r - hub_pole_pocket_r(), 0)) + hub_t - 2,
    "Pole seat goes through the hub"
);
assert(
    hub_pole_face == "through"
        || hub_pole_face == "insert"
        || hub_pole_seat_h <= 0
        || hub_pole_seat_size > bolt_d,
    "Pole seat is smaller than the shank"
);
assert(
    hub_pole_face != "insert" || pole_insert_d() > bolt_d,
    "Pole insert is smaller than the shank"
);
assert(hub_pole_face != "insert" || hub_pole_seat_h > 2.4, "Pole insert is too shallow");
assert(pole_print_x() <= printer_bed_mm, "Pole bracket is wider than the printer");
assert(pole_print_y() <= printer_bed_mm, "Pole bracket is longer than the printer");
assert(pole_print_z() <= printer_bed_mm, "Pole bracket is taller than the printer");
assert(hoop_count == 0 || hoop_w < hoop_h - 2, "Mesh hoop is wider than the rib");
assert(hoop_count == 0 || hoop_clip + 2 < rib_w / 2, "Mesh hoop slot meets in the rib");
assert(rim_index >= 0 && rim_index < rim_div, "Rim index is out of range");
assert(hoop_count == 0 || hoop_seg == 0 || hoop_seg == 1, "Hoop segment must be the rib end or the mid span");
assert(hoop_count == 0 || hoop_r(hoop_index) > rib_w / 2 + hoop_clip + 1, "Mesh hoop is inside the rib width");
assert(hoop_count == 0 || hoop_index < hoop_count, "Mesh hoop index is out of range");
assert(hoop_count == 0 || hoop_print_x() <= printer_bed_mm, "Mesh hoop is longer than the printer");
assert(hoop_count == 0 || hoop_print_y() <= printer_bed_mm, "Mesh hoop is taller than the printer");
assert(thin_n == 0 || z_skirt < z_floor - 1, "Rim skirt is not deeper than the rib seat");
assert(thin_n == 0 || end_keep_ang > 0.5, "Thin-rib rim ends are too short");
assert(thin_n == 0 || end_keep_ang + 1 < rim_piece_half, "Thin-rib rim skirt has no span");
assert(thin_n == 0 || hoop_clip + 1 < rim_w, "Thin-rib rim slot breaks out of the rim");
assert(thin_n == 0 || hoop_clip + 2 < hub_r - bolt_circle_r, "Thin-rib hub slot hits the pole bolts");
assert(thin_n == 0 || thin_rib_print_x() <= printer_bed_mm, "Thin rib is longer than the printer");
assert(thin_n == 0 || thin_rib_print_y() <= printer_bed_mm, "Thin rib is taller than the printer");
assert(thin_n == 0 || hoop_t <= printer_bed_mm, "Thin rib is thicker than the printer");
assert(thin_n == 0 || thin_rib_r0 > 4, "Thin-rib hub clip is inside the axis");
assert(thin_n == 0 || hoop_count == 0 || hoop_r(0) > thin_rib_r0 + hoop_t, "Mesh hoop cuts the thin-rib hub clip");
assert(thin_n == 0 || hoop_count == 0 || hoop_r(hoop_count - 1) < thin_rib_r1 - hoop_t, "Mesh hoop cuts the thin-rib rim clip");
assert(thin_rib_h > hoop_w + 2, "Thin rib is shorter than the hoop tab");
if (clamp_pitch < min_clamp_pitch)
    echo(str("clamp_pitch raised to ", station_pitch, " mm so the stations clear the bolt holes"));

module hoop_slot_2d(r, wt = hoop_t + 2 * lap_clear) {
    translate([r - wt / 2, z_of(r) - hoop_w])
        square([wt, hoop_w + 0.4]);
}

module hoop_slots() {
    for (i = [0:hoop_count - 1]) {
        r = hoop_r(i);
        for (s = [0, 1])
            translate([0, 0, s == 0 ? -eps : rib_w - hoop_clip])
                linear_extrude(hoop_clip + eps)
                    hoop_slot_2d(r, hoop_t + 2 * thin_rib_clear);
    }
}

module hoop_profile_2d(r) {
    translate([r, z_of(r)])
        rotate([0, 0, atan(r / (2 * focal_length))])
            translate([-hoop_t / 2, -hoop_h])
                square([hoop_t, hoop_h]);
}

module hoop_segment(r, seg = 0) {
    a_clip = hoop_clip / r * 180 / pi_;
    a_over = hoop_over / r * 180 / pi_;
    start_extra = seg == 0 ? a_clip : a_over;
    end_extra = seg == hoop_div - 1 ? a_clip : a_over;
    a0s = hoop_station_az(seg, r);
    a1s = hoop_station_az(seg + 1, r);
    rotate([0, 0, a0s - start_extra])
        rotate_extrude(angle=a1s - a0s + start_extra + end_extra, convexity=4)
            hoop_profile_2d(r);
}

module hoop_piece_2d(r, seg) {
    hx = hoop_seg_len(r, seg);
    nw = hoop_t + 2 * lap_clear;
    nh = hoop_h - hoop_w + 0.4;
    difference() {
        square([hx, hoop_h]);
        if (seg == 0)
            square([hoop_clip + eps, hoop_h - hoop_w]);
        if (seg == hoop_div - 1)
            translate([hx - hoop_clip - eps, 0])
                square([hoop_clip + 2 * eps, hoop_h - hoop_w]);
        if (seg > 0)
            translate([hoop_over - nw / 2, -eps])
                square([nw, nh]);
        if (seg < hoop_div - 1)
            translate([hx - hoop_over - nw / 2, -eps])
                square([nw, nh]);
        if (hoop_div == 1 && thin_n > 0)
            for (j = [0:thin_n - 1]) {
                s = hoop_clip
                    + r * (thin_frac(j) * 360 / n_ribs - hoop_az_face(r)) * pi_ / 180;
                translate([s - nw / 2, -eps])
                    square([nw, nh]);
            }
    }
}

module hoop_print_one(r, seg, y) {
    hx = hoop_seg_len(r, seg);
    translate([0, y, 0])
        translate([hx / 2, hoop_h / 2, 0])
            rotate([0, 0, bed_rot(hx, hoop_h)])
                translate([-hx / 2, -hoop_h / 2, 0])
                    linear_extrude(hoop_t)
                        hoop_piece_2d(r, seg);
}

module hoop_print() {
    if (hoop_count > 0)
        hoop_print_one(hoop_r(hoop_index), hoop_div <= 1 ? 0 : hoop_seg, 0);
}

module thin_rib_profile_2d() {
    polygon(concat(para_pts(thin_rib_r0, thin_rib_r1, 0), para_pts(thin_rib_r1, thin_rib_r0, -thin_rib_h)));
}

module thin_rib_hoop_slots() {
    wt = hoop_div > 1 ? 2 * hoop_t + 2 * lap_clear : hoop_t + 2 * lap_clear;
    translate([0, 0, -eps])
        linear_extrude(hoop_t + 2 * eps, convexity=4)
            for (i = [0:hoop_count - 1])
                hoop_slot_2d(hoop_r(i), wt);
}

module thin_rib() {
    difference() {
        linear_extrude(hoop_t, convexity=6)
            thin_rib_profile_2d();
        if (hoop_count > 0)
            thin_rib_hoop_slots();
        translate([thin_rib_rim_pin_r(), thin_rib_pin_z_at(thin_rib_rim_pin_r()), -1])
            filament_bore(hoop_t + 2);
        translate([thin_rib_hub_pin_r(), thin_rib_pin_z_at(thin_rib_hub_pin_r()), -1])
            filament_bore(hoop_t + 2);
    }
}

module place_thin_rib(az) {
    rotate([0, 0, az])
        rotate([90, 0, 0])
            translate([0, 0, -hoop_t / 2])
                thin_rib();
}

module thin_rib_clip_2d(r_in, r_out) {
    polygon(concat(
        para_pts(r_in, r_out, 2),
        para_pts(r_out, r_in, -thin_rib_h - thin_rib_clear)
    ));
}

module thin_rib_hub_slot() {
    rotate([90, 0, 0])
        translate([0, 0, -thin_slot_t / 2])
            linear_extrude(thin_slot_t, convexity=4)
                thin_rib_clip_2d(hub_r - hoop_clip, hub_r + 2);
}

module thin_rib_rim_slot() {
    rotate([90, 0, 0])
        translate([0, 0, -thin_slot_t / 2])
            linear_extrude(thin_slot_t, convexity=4)
                thin_rib_clip_2d(rim_r0 - 1, rim_r0 + hoop_clip);
}

module thin_rib_fil_chord(r, r_od) {
    z = thin_rib_pin_z_at(r);
    y_od = sqrt(max(r_od * r_od - r * r, 1)) + 1;
    y_next = r * tan(180 / n_ribs / (thin_n + 1)) - filament_d - 1;
    y = min(y_od, max(hoop_t / 2 + 2, y_next));
    translate([r, 0, z])
        rotate([90, 0, 0])
            translate([0, 0, -y])
                filament_bore(2 * y);
}

module thin_rib_rim_filament() {
    thin_rib_fil_chord(thin_rib_rim_pin_r(), dish_r);
}

module thin_rib_hub_filament() {
    thin_rib_fil_chord(thin_rib_hub_pin_r(), hub_r);
}

module place_hoop(hi, bay, seg) {
    r = hoop_r(hi);
    rotate([0, 0, bay * 360 / n_ribs])
        hoop_segment(r, seg);
}

module insert_bore() {
    cylinder(h=insert_h + 0.2, d=insert_d, $fn=24);
}

module through_bore(h) {
    cylinder(h=h, d=bolt_hole, $fn=24);
}

module cap_head_cut() {
    cylinder(h=cap_head_h + 1, d=cap_head_d, $fn=24);
}

module filament_bore(h) {
    cylinder(h=h, d=filament_d, $fn=20);
}

module hub_dt_pin_rib(clear=0) {
    r_in = hub_r - hub_dt_len - dt_join - (clear > 0 ? clear : 0);
    r_out = hub_r + dt_join;
    w0 = hub_dt_waist(clear);
    w1 = hub_dt_wide(clear);
    z0 = z_hub_lap - (clear > 0 ? lap_clear : 0);
    z1 = z_of(hub_r) + 6;
    hull() {
        translate([r_out, z0, rib_w / 2 - w0 / 2])
            cube([eps, z1 - z0, w0]);
        translate([r_in, z0, rib_w / 2 - w1 / 2])
            cube([eps, z1 - z0, w1]);
    }
}

module hub_dt_pin_dish(clear=0) {
    r_in = hub_r - hub_dt_len - (clear > 0 ? clear : 0);
    w0 = hub_dt_waist(clear);
    w1 = hub_dt_wide(clear);
    z0 = z_hub_lap - (clear > 0 ? lap_clear : 0);
    z1 = z_of(hub_r) + 6;
    hull() {
        translate([hub_r, -w0 / 2, z0])
            cube([eps, w0, z1 - z0]);
        translate([r_in, -w1 / 2, z0])
            cube([eps, w1, z1 - z0]);
    }
}

module arm_dt_pin_rib(clear=0) {
    r_in = arm_sec2 - (clear > 0 ? clear : 0);
    r_out = hub_r;
    w0 = arm_dt_waist(clear);
    w1 = hub_dt_wide(clear);
    z0 = z_arm_dt - (clear > 0 ? lap_clear : 0);
    z1 = z_of(hub_r) + 6;
    hull() {
        translate([r_out, z0, rib_w / 2 - w0 / 2])
            cube([eps, z1 - z0, w0]);
        translate([r_in, z0, rib_w / 2 - w1 / 2])
            cube([eps, z1 - z0, w1]);
    }
}

module arm_dt_pin_dish(clear=0) {
    r_in = arm_sec2 - (clear > 0 ? clear : 0);
    w0 = arm_dt_waist(clear);
    w1 = hub_dt_wide(clear);
    z0 = z_arm_dt - (clear > 0 ? lap_clear : 0);
    z1 = z_of(hub_r) + 6;
    hull() {
        translate([hub_r, -w0 / 2, z0])
            cube([eps, w0, z1 - z0]);
        translate([r_in, -w1 / 2, z0])
            cube([eps, w1, z1 - z0]);
    }
}

module hub_below_lip_2d() {
    polygon([
        [0, -hub_t - 10],
        [hub_r + 2, -hub_t - 10],
        [hub_r + 2, z_arm_dt],
        [0, z_arm_dt]
    ]);
}

module hub_arm_inner_void(clear=0) {
    w = rib_w + 2 * clear;
    intersection() {
        translate([-clear, -w / 2, -hub_t - 1])
            cube([arm_sec1 + clear + 0.4, w, z_of(hub_r) + hub_t + 12]);
        rotate_extrude(convexity=4, $fn=spin_fn(hub_r))
            hub_below_lip_2d();
    }
}

module hub_arm_mid_pocket(clear=0) {
    w = rib_w + 2 * clear;
    z0 = z_arm_lap - (clear > 0 ? lap_clear : 0);
    translate([arm_sec1 - 0.4, -w / 2, z0])
        cube([arm_sec2 - arm_sec1 + 0.8, w, z_of(hub_r) + 8 - z0]);
}

module hub_filaments_rib() {
    for (k = [1 / 3, 2 / 3])
        translate([hub_fil_r(k), -hub_t - 1, rib_w / 2])
            rotate([-90, 0, 0])
                filament_bore(hub_t + z_of(hub_r) + 8);
}

module hub_filaments_dish() {
    for (k = [1 / 3, 2 / 3])
        translate([hub_fil_r(k), 0, -hub_t - 1])
            filament_bore(hub_t + z_of(hub_r) + 8);
}

module rib_profile_2d(r0 = rib_r0) {
    polygon(concat(para_pts(r0, rib_r1, 0), para_pts(rib_r1, r0, -rib_h)));
}

module arm_hub_lip_clip() {
    rt = arm_sec1;
    z_top = z_arm_dt - lap_clear;
    translate([0, 0, -eps])
        linear_extrude(rib_w + 2 * eps, convexity=4)
            polygon([
                [-eps, z_of(hub_r) + 20],
                [rt, z_of(hub_r) + 20],
                [rt, z_top],
                [-eps, z_top]
            ]);
}

module hub_floor_cut_2d(r0 = rib_r0, z_lap = z_hub_lap) {
    ri = min(r0, 0) - eps;
    r1 = hub_r + rib_w;
    y_back = z_of(max(r0, 0)) - rib_h - 2;
    polygon([
        [ri, y_back],
        [r1, y_back],
        [r1, z_lap],
        [ri, z_lap]
    ]);
}

module arm_hub_floor_cut_2d() {
    ri = -eps;
    r1 = hub_r + rib_w;
    y_back = -rib_h - 2;
    polygon([
        [ri, y_back],
        [r1, y_back],
        [r1, z_arm_dt],
        [arm_sec2, z_arm_dt],
        [arm_sec2, z_arm_lap],
        [ri, z_arm_lap]
    ]);
}

// Flat floor perpendicular to Z. Cut only inside the hub circle
// so the shoulder is cylindrical.
module hub_floor_cut(r0 = rib_r0, z_lap = z_hub_lap) {
    intersection() {
        translate([0, 0, -eps])
            linear_extrude(rib_w + 2 * eps, convexity=4)
                hub_floor_cut_2d(r0, z_lap);
        translate([0, z_of(max(r0, 0)) - rib_h - 4, rib_w / 2])
            rotate([-90, 0, 0])
                cylinder(h=rib_h + z_of(hub_r) + 8, r=hub_r, $fn=spin_fn(hub_r));
    }
}

module arm_hub_floor_cut() {
    intersection() {
        translate([0, 0, -eps])
            linear_extrude(rib_w + 2 * eps, convexity=4)
                arm_hub_floor_cut_2d();
        translate([0, -rib_h - 4, rib_w / 2])
            rotate([-90, 0, 0])
                cylinder(h=rib_h + z_of(hub_r) + 8, r=hub_r, $fn=spin_fn(hub_r));
    }
}

module hub_disk() {
    translate([0, -rib_h - 4, rib_w / 2])
        rotate([-90, 0, 0])
            cylinder(h=rib_h + z_of(hub_r) + 8, r=hub_r, $fn=spin_fn(hub_r));
}

module hub_dt_taper_cut(z_lap = z_hub_lap) {
    intersection() {
        difference() {
            translate([hub_r - hub_dt_len, z_lap - 1, -1])
                cube([hub_dt_len + 2, z_of(hub_r) + rib_h + 6, rib_w + 2]);
            hub_dt_pin_rib(0);
        }
        hub_disk();
    }
}

module arm_dt_taper_cut() {
    intersection() {
        difference() {
            translate([arm_sec2, z_arm_dt - 1, -1])
                cube([hub_r - arm_sec2 + 2, z_of(hub_r) + rib_h + 6, rib_w + 2]);
            arm_dt_pin_rib(0);
        }
        hub_disk();
    }
}

module rib_rim_mt_socket(clear=0) {
    span = 2 * atan((rib_w / 2 + 2) / max(rim_r0, 1)) + 2;
    translate([0, 0, rib_w / 2])
        rotate([-90, 0, 0])
            rotate([0, 0, -span / 2])
                rotate_extrude(angle=max(span, 0.01), convexity=4, $fn=spin_fn(dish_r))
                    rim_mt_profile_2d(clear);
}

module rib_rim_back_support_2d() {
    translate([rim_r0, z_rim_back])
        square([rim_w, max(z_tenon_hi - z_rim_back, 0.2)]);
}

module arm_dt_bolt() {
    translate([arm_bolt_r, z_of(arm_bolt_r) + 1, rib_w / 2])
        rotate([90, 0, 0]) {
            through_bore(z_of(arm_bolt_r) - z_arm_dt + 2);
            cap_head_cut();
        }
}

module arm_joint_fil_chord(r, through_od=false) {
    z = arm_fil_z(r);
    y_od = sqrt(max(hub_r * hub_r - r * r, 1)) + 1;
    az = thin_n > 0 ? 360 / n_ribs / (thin_n + 1) : 180 / n_ribs;
    y_hit = r * tan(min(az, 75))
        - (thin_n > 0 ? thin_slot_t : rib_w) / 2
        - filament_d / 2 - 1;
    y = through_od ? y_od : min(y_od, max(rib_w / 2 + 2, y_hit));
    translate([r, 0, z])
        rotate([90, 0, 0])
            translate([0, 0, -y])
                filament_bore(2 * y);
}

module arm_joint_filaments_dish() {
    arm_joint_fil_chord(arm_fil_r1, true);
    arm_joint_fil_chord(arm_fil_r2);
}

module arm_joint_filaments_rib() {
    for (r = [arm_fil_r1, arm_fil_r2])
        translate([r, arm_fil_z(r), -1])
            filament_bore(rib_w + 2);
}

module arm_lip_bolt() {
    translate([arm_lip_bolt_r, z_arm_lap - 1, rib_w / 2])
        rotate([-90, 0, 0]) {
            through_bore(z_arm_dt - z_arm_lap + 2);
            cap_head_cut();
        }
}

module radial_rib(r0 = rib_r0, z_lap = z_hub_lap) {
    difference() {
        union() {
            linear_extrude(rib_w, convexity=6)
                rib_profile_2d(r0);
            linear_extrude(rib_w, convexity=4)
                rib_rim_back_support_2d();
        }
        if (r0 == 0) {
            arm_hub_floor_cut();
            arm_dt_taper_cut();
            arm_hub_lip_clip();
            arm_dt_bolt();
            arm_lip_bolt();
            arm_joint_filaments_rib();
        } else {
            hub_floor_cut(r0, z_lap);
            hub_dt_taper_cut(z_lap);
            translate([hub_hole_r, z_of(hub_hole_r) + 1, rib_w / 2])
                rotate([90, 0, 0]) {
                    through_bore(z_of(hub_hole_r) - z_lap + 2);
                    cap_head_cut();
                }
            hub_filaments_rib();
        }
        rib_rim_mt_socket(lap_clear);
        if (hoop_count > 0)
            hoop_slots();
    }
}

module mount_prism(along, across, z0, z1) {
    translate([r_mount - along / 2, z0, rib_w / 2 - across / 2])
        cube([along, z1 - z0, across]);
}

module mount_top_clip(along = arm_along) {
    translate([r_mount + along / 2, z_mount_top_rim, -1])
        rotate([0, 0, arm_ang])
            translate([-200, -400, 0])
                cube([400, 400, rib_w + 2]);
}

module mount_insert_pads() {
    intersection() {
        union() {
            for (sx = [-1, 1], sz = [-1, 1])
                translate([
                    r_mount + sx * mount_insert_off,
                    mount_insert_z,
                    rib_w / 2 + sz * mount_across_id / 2
                ])
                    rotate([sz > 0 ? 180 : 0, 0, 0])
                        cylinder(h=pad_len + pad_r, r1=pad_r, r2=0, $fn=28);
        }
        translate([
            r_mount - mount_along_id / 2,
            mount_insert_z - pad_r - 1,
            rib_w / 2 - mount_across_id / 2 - 0.2
        ])
            cube([mount_along_id, 2 * pad_r + 2, mount_across_id + 0.4]);
        union() {
            for (sz = [-1, 1])
                translate([
                    r_mount - mount_along_id / 2,
                    mount_insert_z - pad_r - 1,
                    sz > 0 ? rib_w / 2 + mount_across_id / 2 - pad_len
                           : rib_w / 2 - mount_across_id / 2
                ])
                    cube([mount_along_id, 2 * pad_r + 2, pad_len + 0.2]);
        }
    }
}

module mount_inserts() {
    for (s = [-1, 1]) {
        translate([r_mount + s * mount_insert_off, mount_insert_z, rib_w / 2 - arm_across / 2])
            insert_bore();
        translate([r_mount + s * mount_insert_off, mount_insert_z, rib_w / 2 + arm_across / 2])
            rotate([180, 0, 0])
                insert_bore();
    }
}

module radial_rib_mount() {
    z0 = z_mount_rim - rib_h;
    z1 = z_mount_top_hub + eps;
    difference() {
        union() {
            difference() {
                union() {
                    radial_rib(0);
                    difference() {
                        mount_prism(arm_along, arm_across, z0, z1);
                        mount_top_clip();
                    }
                }
                mount_prism(mount_along_id, mount_across_id, z_mount_bore0, z1 + 1);
            }
            mount_insert_pads();
        }
        mount_inserts();
    }
}

module rib_from_dish() {
    translate([0, 0, rib_w / 2])
        rotate([-90, 0, 0])
            children();
}

module radial_rib_arm() {
    difference() {
        union() {
            difference() {
                union() {
                    radial_rib(0);
                    rib_from_dish()
                        difference() {
                            arm_outer();
                            below_rib_back();
                            arm_face_clip();
                            arm_enc_z_clip();
                        }
                }
                rib_from_dish()
                    arm_inner();
            }
            rib_from_dish()
                arm_insert_pads();
        }
        rib_from_dish() {
            arm_enc_inserts();
            arm_enc_z_clip();
        }
    }
}

module place_rib(az) {
    rotate([0, 0, az])
        rotate([90, 0, 0])
            translate([0, 0, -rib_w / 2])
                radial_rib();
}

module place_rib_mount(az) {
    rotate([0, 0, az])
        rotate([90, 0, 0])
            translate([0, 0, -rib_w / 2])
                radial_rib_mount();
}

module place_rib_arm(az) {
    rotate([0, 0, az])
        rotate([90, 0, 0])
            translate([0, 0, -rib_w / 2])
                radial_rib_arm();
}

module hub_profile_2d() {
    polygon(concat(
        [[0, -hub_t], [hub_r, -hub_t]],
        [for (i = [n_para:-1:0]) let (r = hub_r * i / n_para) [r, z_of(r)]]
    ));
}

module hub_pocket() {
    hub_dt_pin_dish(lap_clear);
}

module hub_arm_pocket() {
    hub_arm_inner_void(lap_clear);
    hub_arm_mid_pocket(lap_clear);
    arm_dt_pin_dish(lap_clear);
}

module hub_insert() {
    translate([hub_hole_r, 0, z_hub_lap - lap_clear])
        rotate([180, 0, 0])
            insert_bore();
}

module hub_arm_insert() {
    translate([arm_bolt_r, 0, z_arm_dt - lap_clear])
        rotate([180, 0, 0])
            insert_bore();
}

module hub_arm_lip_insert() {
    translate([arm_lip_bolt_r, 0, z_arm_dt])
        insert_bore();
}

module hub() {
    difference() {
        rotate_extrude(convexity=8, $fn=spin_fn(hub_r))
            hub_profile_2d();
        for (i = [0:n_ribs - 1])
            rotate([0, 0, i * 360 / n_ribs]) {
                if (i == 0) {
                    hub_arm_pocket();
                    hub_arm_insert();
                    hub_arm_lip_insert();
                    arm_joint_filaments_dish();
                } else {
                    hub_pocket();
                    hub_insert();
                    hub_filaments_dish();
                }
            }
        if (thin_n > 0)
            for (i = [0:n_ribs - 1], j = [0:thin_n - 1])
                rotate([0, 0, (i + thin_frac(j)) * 360 / n_ribs]) {
                    thin_rib_hub_slot();
                    thin_rib_hub_filament();
                }
        hub_pole_holes();
    }
}

module hub_print() {
    translate([0, 0, hub_t])
        hub();
}

module hub_pole_seat_at(p) {
    rr = hub_pole_pocket_r();
    z_top = z_of(bolt_circle_r + rr) + 1;
    z_bot = z_of(max(bolt_circle_r - rr, 0)) - hub_pole_seat_h;
    translate([p[0], p[1], z_bot])
        cylinder(
            h=z_top - z_bot,
            d=hub_pole_pocket_d(),
            $fn=hub_pole_face == "hex" ? 6 : 24
        );
}

module hub_pole_holes() {
    for (i = [0:3]) {
        p = bolt_xy(i);
        translate([p[0], p[1], -hub_t - 1])
            cylinder(h=hub_t + z_of(bolt_circle_r) + 4, d=bolt_d, $fn=24);
        if (hub_pole_face != "through" && hub_pole_seat_h > 0)
            hub_pole_seat_at(p);
    }
}

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

module pole_bracket() {
    rotate([0, 0, 90])
        difference() {
            union() {
                translate([-flange_hx, -flange_hy, flange_back])
                    cube([2 * flange_hx, 2 * flange_hy, flange_t]);
                for (s = [-1, 1])
                    clamp_station(s * station_pitch / 2);
            }
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

module pole_bracket_print() {
    translate([0, 0, -cheek_back])
        pole_bracket();
}

module rim_profile_2d(zb) {
    polygon(concat(
        [[rim_r0, zb], [dish_r, zb]],
        para_pts(dish_r, rim_r0, 0)
    ));
}

module rim_sector(zb, a0, a1) {
    rotate([0, 0, a0])
        rotate_extrude(angle=max(a1 - a0, 0.01), convexity=8, $fn=spin_fn(dish_r))
            rim_profile_2d(zb);
}

module rim_lap_cut(a0, a1, z0, z1) {
    rotate([0, 0, a0])
        rotate_extrude(angle=max(a1 - a0, 0.01), convexity=4, $fn=spin_fn(dish_r))
            translate([rim_r0 - 1, z0])
                square([rim_w + 2, z1 - z0]);
}

module rim_index_label(i, zb) {
    a_mid = (rim_base0(i) + rim_base1(i)) / 2;
    r = (rim_r0 + dish_r) / 2;
    h = min(rim_w * 0.65, 5);
    d = 0.8;
    rotate([0, 0, a_mid])
        translate([r, 0, zb - eps])
            rotate([0, 0, 90])
                mirror([1, 0, 0])
                    linear_extrude(d + eps)
                        text(
                            str(i),
                            size=h,
                            font="Liberation Sans",
                            halign="center",
                            valign="center"
                        );
}

module rim_mt_profile_2d(clear=0) {
    c = clear > 0 ? clear : 0;
    r0 = rim_tenon_r0 - c;
    r1 = rim_tenon_r1 + c;
    translate([r0, z_tenon_lo - c])
        square([max(r1 - r0, 0.2), tenon_h + 2 * c]);
}

module rim_mt_solid(a0, a1, clear=0) {
    rotate([0, 0, a0])
        rotate_extrude(angle=max(a1 - a0, 0.01), convexity=4, $fn=spin_fn(dish_r))
            rim_mt_profile_2d(clear);
}

module rim_mt_filaments(a_sh, dir=1) {
    for (f = [1 / 3, 2 / 3])
        rotate([0, 0, a_sh + dir * f * lap_ang])
            translate([rim_fil_r, 0, z_rim_back - 1])
                filament_bore(z_of(dish_r) - z_rim_back + 4);
    rotate([0, 0, a_sh + dir * 0.5 * lap_ang])
        translate([rim_r0 - 1, 0, z_tenon_mid])
            rotate([0, 90, 0])
                filament_bore(rim_w + 2);
}

module rim_piece(i) {
    a0 = rim_a0(i);
    a1 = rim_a1(i);
    b0 = rim_body0(i);
    b1 = rim_body1(i);
    zb = z_rim_back;
    difference() {
        union() {
            rim_sector(zb, b0, b1);
            if (i == 0)
                rim_mt_solid(a0, b0, 0);
            if (i == rim_div - 1)
                rim_mt_solid(b1, a1, 0);
            if (rim_div > 1 && i < rim_div - 1)
                rim_mt_solid(b1, b1 + lap_ang, 0);
        }
        if (thin_n > 0) {
            for (j = [0:thin_n - 1]) {
                taz = thin_rib_taz(j);
                if (taz >= rim_base0(i) - 0.05 && taz <= rim_base1(i) + 0.05)
                    rotate([0, 0, taz]) {
                        thin_rib_rim_slot();
                        thin_rib_rim_filament();
                    }
            }
        }
        if (rim_div > 1 && i > 0)
            rim_mt_solid(b0, b0 + lap_ang, lap_clear);
        if (rim_div > 1 && i < rim_div - 1)
            rim_mt_filaments(b1, 1);
        if (rim_div > 1 && i > 0)
            rim_mt_filaments(b0, 1);
        rim_index_label(i, zb);
    }
}

module rim_segment() {
    rim_piece(rim_index);
}

module rim_print() {
    i = rim_index;
    a_mid = (rim_base0(i) + rim_base1(i)) / 2;
    ph = rim_piece_half
        + ((i == 0 || i == rim_div - 1) ? end_keep_ang : 0)
        + ((rim_div > 1 && i < rim_div - 1) ? lap_ang : 0);
    cx = (rim_r0 * cos(ph) + dish_r) / 2;
    z0 = z_rim_back;
    translate([0, 0, -z0])
        translate([cx, 0, 0])
            rotate([0, 0, bed_rot(rim_foot_x_h(ph), rim_foot_y_h(ph))])
                translate([-cx, 0, 0])
                    rotate([0, 0, -a_mid])
                        rim_piece(i);
}

module place_rim(bay, i) {
    rotate([0, 0, bay * 360 / n_ribs + 180 / n_ribs])
        rim_piece(i);
}

module rect_x(len, y, z) {
    translate([0, -y / 2, -z / 2])
        cube([len, y, z]);
}

module slab_z(z0, z1) {
    translate([-500, -500, z0])
        cube([1000, 1000, z1 - z0]);
}

module arm_face_clip() {
    translate([face_x - 400, -200, -200])
        cube([400, 400, 400]);
}

module arm_enc_z_clip() {
    translate([-400, -200, focal_length + cavity_h])
        cube([400 + face_x + socket_len + 10, 400, 400]);
}

module along_arm() {
    translate(p_knee)
        rotate([0, -arm_ang, 0])
            children();
}

module along_arm_enc() {
    translate([face_x, 0, p_enc[2] - focal_length])
        rotate([0, -arm_ang, 0])
            children();
}

module below_dish() {
    rmax = dish_r + 80;
    rotate_extrude(convexity=6)
        polygon(concat(
            [[0, -30], [rmax, -30], [rmax, z_of(rmax)]],
            [for (i = [n_para:-1:0]) let (r = rmax * i / n_para) [r, z_of(r)]]
        ));
}

module below_rib_back() {
    rmax = dish_r + 80;
    rotate_extrude(convexity=6)
        polygon(concat(
            [[0, -30], [rmax, -30], [rmax, z_of(rmax) - rib_h]],
            [for (i = [n_para:-1:0]) let (r = rmax * i / n_para) [r, z_of(r) - rib_h]]
        ));
}

module z_rect(ax, ay, z0, z1) {
    translate([r_mount - ax / 2, -ay / 2, z0])
        cube([ax, ay, z1 - z0]);
}

module arm_rimward_clip(along) {
    translate([r_mount + along / 2, -200, -200])
        cube([400, 400, 400]);
}

module arm_outer() {
    union() {
        z_rect(feed_along_od, feed_across_od, z_mount_bore0, z_elbow + eps);
        difference() {
            along_arm()
                translate([arm_elbow_s - 1, 0, 0])
                    rect_x(arm_len - arm_elbow_s + 8, feed_across_od, feed_along_od);
            arm_rimward_clip(feed_along_od);
        }
    }
}

module arm_inner() {
    union() {
        z_rect(feed_along_id, feed_across_id, z_mount_bore0, z_elbow_id + eps);
        difference() {
            along_arm()
                translate([arm_elbow_s_id - 1, 0, 0])
                    rect_x(arm_len - arm_elbow_s_id + 9, feed_across_id, feed_along_id);
            arm_rimward_clip(feed_along_id);
        }
    }
}

module boot_through_holes() {
    for (s = [-1, 1])
        translate([r_mount + s * mount_insert_off, -feed_across_od / 2 - 1, mount_insert_z])
            rotate([-90, 0, 0])
                through_bore(feed_across_od + 2);
}

module arm_insert_pads() {
    along_arm()
        intersection() {
            union() {
                for (sy = [-1, 1], sz = [-1, 1])
                    translate([arm_insert_s, sy * feed_across_id / 2, sz * arm_insert_off])
                        rotate([sy > 0 ? 90 : -90, 0, 0])
                            cylinder(h=pad_len + pad_r, r1=pad_r, r2=0, $fn=28);
            }
            translate([
                arm_insert_s - pad_r - 1,
                -feed_across_id / 2 - 0.2,
                -feed_along_id / 2
            ])
                cube([2 * pad_r + 2, feed_across_id + 0.4, feed_along_id]);
            union() {
                for (sy = [-1, 1])
                    translate([
                        arm_insert_s - pad_r - 1,
                        sy > 0 ? feed_across_id / 2 - pad_len : -feed_across_id / 2,
                        -feed_along_id / 2
                    ])
                        cube([2 * pad_r + 2, pad_len + 0.2, feed_along_id]);
            }
        }
}

module arm_enc_inserts() {
    along_arm()
        for (s = [-1, 1]) {
            translate([arm_insert_s, feed_across_od / 2, s * arm_insert_off])
                rotate([90, 0, 0])
                    insert_bore();
            translate([arm_insert_s, -feed_across_od / 2, s * arm_insert_off])
                rotate([-90, 0, 0])
                    insert_bore();
        }
}

module feed_arm() {
    difference() {
        union() {
            difference() {
                arm_outer();
                arm_inner();
                below_dish();
                arm_face_clip();
                arm_enc_z_clip();
            }
            arm_insert_pads();
        }
        boot_through_holes();
        arm_enc_inserts();
        arm_enc_z_clip();
    }
}

module feed_arm_print() {
    rotate([90, 0, 0])
        translate([0, feed_across_od / 2, 0])
            feed_arm();
}

module cavity_2d() {
    square([enclosure_x, enclosure_y], center=true);
}

module round_off(r=groove_round) {
    offset(r=r)
        offset(delta=-r)
            children();
}

module groove_2d() {
    difference() {
        round_off()
            offset(delta=gasket_lip + groove_w)
                cavity_2d();
        round_off()
            offset(delta=gasket_lip)
                cavity_2d();
    }
}

module gasket_2d() {
    difference() {
        round_off()
            offset(delta=gasket_lip + groove_w / 2 + gasket_w / 2)
                cavity_2d();
        round_off()
            offset(delta=gasket_lip + groove_w / 2 - gasket_w / 2)
                cavity_2d();
    }
}

module enclosure_profile_2d() {
    union() {
        offset(delta=enc_wall)
            cavity_2d();
        for (sx = [-1, 1], sy = [-1, 1])
            translate([sx * bolt_x, sy * bolt_y])
                circle(r=boss_r, $fn=28);
    }
}

module lid_screws(h, z) {
    for (sx = [-1, 1], sy = [-1, 1])
        translate([sx * bolt_x, sy * bolt_y, z])
            through_bore(h);
}

module lid_inserts() {
    for (sx = [-1, 1], sy = [-1, 1]) {
        translate([sx * bolt_x, sy * bolt_y, 0])
            insert_bore();
        translate([sx * bolt_x, sy * bolt_y, cavity_h])
            rotate([180, 0, 0])
                insert_bore();
    }
}

module enclosure_socket_solid() {
    along_arm_enc()
        translate([-socket_len, 0, 0])
            rect_x(socket_len + enc_wall, sock_across_od, sock_along_od);
}

module socket_wall_fill() {
    hull() {
        translate([face_x - 1, -sock_across_od / 2, cavity_h - 1])
            cube([1, sock_across_od, 1]);
        enclosure_socket_solid();
    }
}

module enclosure_socket_cuts() {
    along_arm_enc() {
        translate([-socket_len - 1, 0, 0])
            rect_x(socket_len + 1.2, sock_across_id, sock_along_id);
        translate([-1, 0, 0])
            rect_x(enc_wall + 12, feed_across_id, feed_along_id);
        for (s = [-1, 1])
            translate([-socket_len + arm_end_keep, -sock_across_od / 2 - 1, s * arm_insert_off])
                rotate([-90, 0, 0])
                    through_bore(sock_across_od + 2);
    }
}

module enclosure_body() {
    difference() {
        difference() {
            union() {
                linear_extrude(cavity_h, convexity=8)
                    enclosure_profile_2d();
                enclosure_socket_solid();
                socket_wall_fill();
            }
            translate([-500, -500, cavity_h])
                cube([1000, 1000, 500]);
        }
        translate([0, 0, -eps])
            linear_extrude(cavity_h + 2 * eps)
                cavity_2d();
        translate([0, 0, -eps])
            linear_extrude(groove_d + eps, convexity=4)
                groove_2d();
        translate([0, 0, cavity_h - groove_d])
            linear_extrude(groove_d + eps, convexity=4)
                groove_2d();
        intersection() {
            enclosure_socket_cuts();
            slab_z(-200, cavity_h - enc_z_keep);
        }
        lid_inserts();
    }
}

module lid() {
    difference() {
        linear_extrude(lid_flange, convexity=8)
            enclosure_profile_2d();
        translate([0, 0, lid_floor])
            linear_extrude(lid_flange + eps)
                cavity_2d();
        translate([0, 0, -eps])
            linear_extrude(groove_d + eps, convexity=4)
                groove_2d();
        lid_screws(lid_flange + 2, -1);
    }
}

module gasket() {
    linear_extrude(gasket_h, convexity=4)
        gasket_2d();
}

module place_enclosure() {
    translate([0, 0, focal_length])
        enclosure_body();
}

module place_radome() {
    translate([0, 0, focal_length])
        mirror([0, 0, 1])
            lid();
}

module place_reflector() {
    translate([0, 0, focal_length + cavity_h])
        lid();
}

module place_gaskets() {
    translate([0, 0, focal_length - gasket_h / 2])
        gasket();
    translate([0, 0, focal_length + cavity_h - gasket_h / 2])
        gasket();
}

echo(assembly_kit=concat(
    ["hub"],
    n_ribs > 1 ? ["radial_rib"] : [],
    feed_joint == "combined" ? ["radial_rib_arm"] : ["radial_rib_mount", "feed_arm"],
    [for (i = [0:rim_div - 1]) str("rim_segment;rim_index=", i)],
    thin_n > 0 ? ["thin_rib"] : [],
    hoop_count > 0
        ? [for (
            h = [0:hoop_count - 1],
            s = hoop_div <= 1 ? [0] : [0, 1]
        ) str("mesh_hoop;hoop_index=", h, ";hoop_seg=", s)]
        : [],
    ["enclosure_body", "radome_lid", "reflector_lid", "gasket", "pole_bracket"]
));

module assembly() {
    hub();
    for (i = [0:n_ribs - 1]) {
        if (i == 0) {
            if (feed_joint == "combined")
                place_rib_arm(0);
            else
                place_rib_mount(0);
        } else
            place_rib(i * 360 / n_ribs);
        for (p = [0:rim_div - 1])
            place_rim(i, p);
        if (thin_n > 0)
            for (j = [0:thin_n - 1])
                place_thin_rib((i + thin_frac(j)) * 360 / n_ribs);
        if (hoop_count > 0)
            for (h = [0:hoop_count - 1], s = [0:hoop_div - 1])
                place_hoop(h, i, s);
    }
    if (feed_joint != "combined")
        feed_arm();
    place_enclosure();
    place_radome();
    place_reflector();
    place_gaskets();
    pole_bracket();
}

if (part == "hub")
    hub_print();
else if (part == "radial_rib")
    radial_rib();
else if (part == "radial_rib_mount")
    radial_rib_mount();
else if (part == "radial_rib_arm")
    radial_rib_arm();
else if (part == "rim_segment")
    rim_print();
else if (part == "thin_rib")
    thin_rib();
else if (part == "mesh_hoop")
    hoop_print();
else if (part == "feed_arm")
    feed_arm_print();
else if (part == "enclosure_body")
    enclosure_body();
else if (part == "radome_lid")
    lid();
else if (part == "reflector_lid")
    lid();
else if (part == "gasket")
    gasket();
else if (part == "pole_bracket")
    pole_bracket_print();
else
    assembly();
