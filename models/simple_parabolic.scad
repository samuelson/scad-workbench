// name: Simple parabolic
// description: Prime-focus rib frame · feed arm · focal box
//
// Prime-focus rib frame. Units: mm. OpenSCAD 2021.01+. No libraries.
// Vertex at the origin, opening toward +Z, focus at z = focal_length.
// Structure sits behind the paraboloid (toward -Z). One radial rib runs
// through the vertex to the pole-bracket edge, with a flat back pad.
// Two M5 bolts through the dish face sit on the clamp-station centers,
// with heat-set inserts opening on the paraboloid along +Z. Thin ribs
// clip into the sides of that rib and into the rim, plus one opposite
// the feed arm that clips into the stub end. One filament along each
// side of the main rib pins the three side clips; the opposite thin rib
// has its own pin across the stub.
// Rim segments
// splice with a circular-slide mortise and tenon that is flat-backed like
// the rim, with the +Z face sloped to the local parabola, centered in
// its axial thickness, pinned with two Z filament holes and one radial
// hole, including at the rib joints. The rib has a matching
// through-channel so rim tenons meet at the rib midplane. No mesh or metal in the model.
// Full-height hoop strips print straight and bow into slots on the ribs,
// carrying stainless mesh on the paraboloid. A hollow feed arm prints as
// one piece with the rib and carries cables to a focus-centered box with
// two lids. A pole bracket bolts to the rib back and hose-clamps to a mast.

/* [Selection] */
part = "assembly"; // [assembly, radial_rib_arm, rim_segment, thin_rib, mesh_hoop, enclosure_body, radome_lid, reflector_lid, gasket, pole_bracket]

/* [Dish] */
frequency_GHz = 5.8; // [5:0.1:6.5]
dish_diameter = 400; // [250:1:600]
focal_length = 150; // [80:1:300]

/* [Enclosure] */
enclosure_x = 50; // [20:1:80]
enclosure_y = 50; // [30:1:120]
cavity_steps = 0; // [0:1:8]

/* [Hidden] */
fast_preview = true;
hoop_index = 0;
hoop_seg = 0;
rim_index = 0;
thin_index = 0;
n_ribs = 1;
thickness = 15;
rim_w = 8;
rim_h = 12;
lap_w = 16;
lap_clear = 0.25;
printer_bed_mm = 256;
hoop_count = 2;
hoop_w = 6;
hoop_t = 1.2;
thin_rib_t = 3.2;
thin_ribs = 7;
arm_across = 20;
arm_wall = 2.5;
socket_len = 32;
arm_slip = 0.25;
enc_wall = 6;
lid_floor = 1.5;
lid_flange = 3.5;
gasket_w = 2.2;
gasket_h = 2.2;
groove_w = 2;
groove_d = 1;
pole_diameter = 32;
pole_clearance = 0.8;
v_included = 120;
clamp_band_width = 12.7;
clamp_slot = 2.5;
clamp_pitch = 72;
bolt_d = 5;

$fa = fast_preview ? 12 : 6;
$fs = fast_preview ? 2 : 0.8;

n_para = fast_preview ? 16 : 40;
eps = 0.2;
insert_d = 4.0;
insert_h = 4;
bolt_hole = 3.3;
filament_d = 1.75;
filament_v = 2.20;
filament_h = 2.00;
tenon_wall = 1.6;
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
rib_h = thickness;
rib_r1 = dish_r;
rim_r0 = dish_r - rim_w;
z_floor = dish_depth - rim_h;
rim_hole_r = dish_r - rim_w / 2;
z_pad = -rib_h;

cavity_h = (0.75 + cavity_steps * 0.5) * lambda_mm;
boot_across_id = arm_across + 2 * arm_slip;
boot_across_od = boot_across_id + 2 * arm_wall;
rib_w = boot_across_od;
rib_face_ang = atan(rib_w / 2 / dish_r);
rim_center_gap_ang = atan(lap_clear / 2 / dish_r);
rim_half_ang = 180 / n_ribs - rib_face_ang;
feed_along_od = boot_across_od;
feed_across_od = boot_across_od;
feed_along_id = boot_across_id;
feed_across_id = boot_across_id;
mount_along = feed_along_od;
hoop_clip = 5;
hoop_over = hoop_clip;
thin_rib_clear = 0.10;
thin_slot_t = thin_rib_t + 2 * thin_rib_clear;
pi_ = 3.141592653589793;
function spin_fn(r) =
    min(
        fast_preview ? 360 : 720,
        max(96, ceil(2 * pi_ * r / (fast_preview ? 2 : 0.8)))
    );
lap_ang = lap_w / rim_hole_r * 180 / pi_;
thin_rib_r1 = rim_r0 + hoop_clip;
thin_rib_h = rib_h - 1.2;
function thin_rib_rim_pin_r() = thin_rib_r1;
function thin_rib_pin_z_at(r) = z_of(r) - thin_rib_h / 2;
function thin_rib_rim_pin_z() = z_of(thin_rib_rim_pin_r()) - thin_rib_h * 0.62;
hoop_h = thin_rib_h;
inner_r = rib_w / 2 + hoop_clip;
z_skirt = rim_r0 * rim_r0 / (4 * focal_length) - rib_h;
end_keep_ang = rib_face_ang - rim_center_gap_ang;
sock_along_id = feed_along_od + 2 * arm_slip;
sock_across_id = feed_across_od + 2 * arm_slip;
sock_along_od = sock_along_id + 2 * sock_wall;
sock_across_od = sock_across_id + 2 * sock_wall;
arm_end_keep = insert_d / 2 + 1.6;
arm_insert_off = feed_along_id / 2 - insert_d / 2 + 1.2;
pad_r = insert_d / 2 + 2.4;
pad_len = insert_h + 0.2 - arm_wall + 1.0;
enc_z_keep = gasket_lip + groove_w + 0.8;
r_mount = rim_r0 - mount_along / 2;
z_mount_face = r_mount * r_mount / (4 * focal_length);
z_knee = z_mount_face;
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
z_mount_top_rim = z_knee;
z_mount_top_hub = z_mount_top_rim - mount_along * tan(arm_ang);
miter_skew = (feed_along_od / 2) * abs(arm_dz / arm_dx);
flange_t = 8;
cheek_y = clamp_band_width + 6;
pole_r = pole_diameter / 2 + pole_clearance;
flange_back = z_pad - flange_t;
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
station_pitch = clamp_pitch;
flange_hx = v_half + v_wall;
flange_hy = station_pitch / 2 + cheek_y / 2;
rib_x0 = -flange_hy;
function pole_insert_d() = bolt_d <= 3.2 ? 4.0 : (bolt_d <= 4.2 ? 5.6 : 6.5);
function pole_insert_h() = bolt_d <= 3.2 ? 4 : (bolt_d <= 4.2 ? 5 : 6);
function pole_bolt_x(i) = (i == 0 ? -1 : 1) * station_pitch / 2;

function z_of(r) = r * r / (4 * focal_length);
function rib_back(x) = abs(x) <= flange_hy ? z_pad : z_of(x) - rib_h;
z_mount_bore0 = z_of(r_mount - feed_along_od / 2) - rib_h - 2;

function para_pts(r0, r1, dz) =
    [for (i = [0:n_para])
        let (r = r0 + (r1 - r0) * i / n_para)
            [r, z_of(r) + dz]];

function rib_arm_print_x() = rib_r1 - rib_x0;
function rib_arm_print_y() =
    max(z_of(rib_r1), z_mount_top_hub, p_enc[2] + sock_along_od / 2) - z_pad;
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
function lid_outer_x() = 2 * max(enclosure_x / 2 + enc_wall, bolt_x + boss_r);
function lid_outer_y() = 2 * max(enclosure_y / 2 + enc_wall, bolt_y + boss_r);
function rib_s(r) =
    let (a = 2 * focal_length, u = r / a, n = sqrt(1 + u * u))
        r / 2 * n + a / 2 * ln(u + n);

function hoop_r_at_s(s, r = (inner_r + rim_r0) / 2, n = 8) =
    n <= 0 ? r :
    let (r2 = r - (rib_s(r) - s) / sqrt(1 + pow(r / (2 * focal_length), 2)))
        hoop_r_at_s(s, r2, n - 1);

function hoop_r(i) =
    let (s0 = rib_s(inner_r), s1 = rib_s(rim_r0))
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
thin_skip_ang = max(rib_face_ang, 8);
thin_azs = [
    for (j = [0:thin_ribs - 1])
        let (a = (j + 1) / (thin_ribs + 1) * 360)
            if (abs(cos(a) - 1) > 1 - cos(thin_skip_ang)) a
];
thin_n = len(thin_azs);
hoop_div_need = hoop_div_from(1);
hoop_div = hoop_div_need == 1 ? 1 : max(hoop_div_need, thin_n + 1);
function thin_az(j) = thin_azs[j];
function thin_r_hit(az) =
    let (s = abs(sin(az)))
        s < 1e-6 ? -rib_x0 : rib_w / 2 / s;
function thin_r0_az(az) = thin_r_hit(az) - hoop_clip;
function thin_inner_pin_r(az) = thin_r_hit(az) - hoop_clip / 2;
function thin_az_is_end(az) = abs(sin(az)) < 1e-6;
function thin_side_pin_y() = rib_w / 2 - hoop_clip / (2 * sqrt(2));
function thin_side_pin_x_end() = thin_side_pin_y() + thin_rib_t / sqrt(2) + 1;
function thin_side_pin_z() = z_of(thin_side_pin_y()) - thin_rib_h * 0.28;
function thin_end_pin_z(r) = z_of(r) - thin_rib_h * 0.78;
function thin_rib_taz(j) = thin_az(j) - 180 / n_ribs;
function hoop_station_az(seg, r) =
    hoop_div <= 1 ?
        hoop_az_face(r) + seg * hoop_span(r) / hoop_div :
        (seg <= 0 ? hoop_az_face(r) :
            (seg >= hoop_div ? 360 / n_ribs - hoop_az_face(r) :
                thin_az(seg - 1)));
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
    j >= thin_n ? false :
        (k >= div ? thin_hit(div, j + 1, 1) :
            (abs(-rim_half_ang + k * 2 * rim_half_ang / div - thin_rib_taz(j)) < lap_ang + 1
                ? true
                : thin_hit(div, j, k + 1)));
function rim_div_from(d) =
    d >= 24 ? d :
        (!rim_piece_fits(rim_half_ang / d) ? rim_div_from(d + 1) :
            (thin_hit(d) ? rim_div_from(d + 1) : d));
rim_div = rim_div_from(1);
rim_piece_half = rim_half_ang / rim_div;
function rim_step() = 2 * rim_piece_half;
function rim_base0(i) = -rim_half_ang + i * rim_step();
function rim_base1(i) = rim_base0(i) + rim_step();
function rim_body0(i) = rim_base0(i);
function rim_body1(i) = rim_base1(i);
function rim_a0(i) = rim_body0(i) - (i == 0 ? end_keep_ang : 0);
function rim_a1(i) = rim_body1(i) + (i == rim_div - 1 ? end_keep_ang : 0);
z_rim_back = z_skirt;
rim_ax_short = z_of(rim_r0) - z_rim_back;
rim_tenon_r0 = rim_r0 + tenon_wall;
rim_tenon_r1 = dish_r - tenon_wall;
rim_fil_r = (rim_tenon_r0 + rim_tenon_r1) / 2;
tenon_slope = rim_fil_r / (2 * focal_length);
z_tenon_lo = z_rim_back + tenon_wall;
function tenon_z_hi(r) = z_of(rim_fil_r) - tenon_wall + (r - rim_fil_r) * tenon_slope;
z_tenon_hi = tenon_z_hi(rim_fil_r);
tenon_h = z_tenon_hi - z_tenon_lo;
z_tenon_mid = (z_tenon_lo + z_tenon_hi) / 2;
function thin_print_r0() = thin_r0_az(thin_az(thin_index));
function thin_rib_print_x() = thin_rib_r1 - thin_print_r0();
function thin_rib_print_y() = z_of(thin_rib_r1) - (z_of(thin_print_r0()) - thin_rib_h);
function rim_print_z() = dish_depth - z_skirt;
function pole_print_x() = 2 * flange_hy;
function pole_print_y() = 2 * flange_hx;
function pole_print_z() = -cheek_back;

echo(lambda_mm=lambda_mm, dish_depth_mm=dish_depth, f_D=f_D);
echo(n_ribs=n_ribs, rim_div=rim_div, hoop_div=hoop_div, thin_n=thin_n, thickness=thickness, rim_w=rim_w, rim_h=rim_h);
echo(rib_arm_print=[rib_arm_print_x(), rib_arm_print_y(), rib_w]);
echo(thin_rib_print=[thin_rib_print_x(), thin_rib_print_y(), thin_rib_t]);
echo(rim_print=[rim_print_x(), rim_print_y(), rim_print_z()]);
echo(
    hoop_radial_end=[
        hoop_seg_len(hoop_r(0), 0),
        hoop_count * n_ribs * (hoop_div == 1 ? 1 : 2)
    ]
);
echo(
    hoop_thin_span=[
        hoop_div <= 2 ? 0 : hoop_seg_len(hoop_r(0), 1),
        hoop_count * n_ribs * max(hoop_div - 2, 0)
    ]
);
echo(cavity_h=cavity_h, r_mount=r_mount, arm_len=arm_len, arm_ang=arm_ang);
echo(boot_across_od=boot_across_od, feed_along_od=feed_along_od, feed_across_od=feed_across_od);
echo(thin_azs=thin_azs, flange_hx=flange_hx, station_pitch=station_pitch);

assert(thin_n > 0, "No thin ribs remain after skipping the feed-arm azimuth");
assert(tenon_h > filament_d + 1.6, "Splice tenon is too thin for filament");
assert(tenon_z_hi(rim_tenon_r0) > z_tenon_lo + filament_d, "Angled tenon is too thin at the inner radius");
assert(tenon_z_hi(rim_tenon_r1) < z_of(rim_tenon_r1) - tenon_wall + 0.2, "Angled tenon cuts the dish face");
assert(rim_tenon_r1 - rim_tenon_r0 > filament_d + 1.6, "Splice tenon is too narrow for filament");
assert(rim_ax_short > filament_d + 2 * tenon_wall, "Rim axial face is too short for the tenon");
assert(lap_w > filament_d * 3 + 4, "Splice is too short for two filament pins");
assert(end_keep_ang > 0.2, "Rib is too thin for rim tenons to meet");
assert(thickness > bolt_hole + 0.4, "Stock is too thin for M3");
assert(rim_piece_half < 80, "Rim piece is too wide to print as a flat arc");
assert(rib_arm_print_x() <= printer_bed_mm, "Combined rib and arm is longer than the printer");
assert(rib_arm_print_y() <= printer_bed_mm, "Combined rib and arm is taller than the printer");
assert(thickness <= printer_bed_mm, "Stock is thicker than the printer");
assert(rib_w <= printer_bed_mm, "Rib is wider than the printer");
assert(rim_print_x() <= printer_bed_mm, "Rim segment is too wide for the printer");
assert(rim_print_y() <= printer_bed_mm, "Rim segment is too long for the printer");
assert(rim_h <= printer_bed_mm, "Rim segment is thicker than the printer");
assert(arm_wall > 1.2, "Feed arm wall is too thin to print");
assert(feed_along_id > 4 && feed_across_id > 4, "Feed arm bore is too small for a cable");
assert(r_mount + mount_along / 2 <= rim_r0 + 0.05, "Arm mount hits the rim");
assert(groove_w + 0.2 <= gasket_lip + enc_wall, "Groove does not fit in the wall");
assert(bolt_x - bolt_hole / 2 > groove_outer_x + 0.6, "Lid bolts cut the gasket path");
assert(bolt_y - bolt_hole / 2 > groove_outer_y + 0.6, "Lid bolts cut the gasket path");
assert(lid_floor > groove_d, "Lid floor is thinner than the groove");
assert(lid_flange > groove_d + 1.2, "Lid flange is too thin for the groove");
assert(gasket_h > 2 * groove_d, "Gasket is too thin to crush in both grooves");
assert(cavity_h > enc_z_keep + 8, "Cavity is too short for the gasket wall");
assert(enc_meet_d > sock_along_od / 2 + 1, "Enclosure is too close to the arm knee");
assert(enclosure_y > sock_across_od + 4, "Enclosure is too narrow for the socket");
assert(feed_across_od <= printer_bed_mm, "Feed arm is thicker than the printer");
assert(feed_along_od <= printer_bed_mm, "Feed arm is wider than the printer");
assert(lid_outer_x() <= printer_bed_mm, "Enclosure is wider than the printer");
assert(lid_outer_y() <= printer_bed_mm, "Enclosure is longer than the printer");
assert(cavity_h + sock_along_od <= printer_bed_mm, "Enclosure body is taller than the printer");
assert(socket_len > arm_end_keep + miter_skew + fastener_clear, "Enclosure socket is too short for the bolts");
assert(arm_insert_off + insert_d / 2 + 0.6 < feed_along_od / 2, "Arm insert breaks out of the along wall");
assert(pad_len < feed_across_id - 2, "Insert pad closes the feed arm");
assert(station_pitch / 2 + bolt_d / 2 + 1.6 < flange_hy, "Pole bolts leave the flange");
assert(station_pitch / 2 + pole_insert_d() / 2 < flange_hy - 1, "Pole inserts leave the rib pad");
assert(pole_insert_d() > bolt_d, "Pole insert is not larger than the bolt");
assert(
    z_of(station_pitch / 2) - z_pad > pole_insert_h() + 2,
    "Pole insert is too deep for the rib"
);
assert(pole_print_x() <= printer_bed_mm, "Pole bracket is wider than the printer");
assert(pole_print_y() <= printer_bed_mm, "Pole bracket is longer than the printer");
assert(pole_print_z() <= printer_bed_mm, "Pole bracket is taller than the printer");
assert(hoop_w < hoop_h - 2, "Mesh hoop is wider than the rib");
assert(hoop_clip + 2 < rib_w / 2, "Mesh hoop slot meets in the rib");
assert(rim_index >= 0 && rim_index < rim_div, "Rim index is out of range");
assert(thin_index >= 0 && thin_index < thin_n, "Thin-rib index is out of range");
assert(hoop_seg == 0 || hoop_seg == 1, "Hoop segment must be the rib end or the mid span");
assert(hoop_r(hoop_index) > rib_w / 2 + hoop_clip + 1, "Mesh hoop is inside the rib width");
assert(hoop_index < hoop_count, "Mesh hoop index is out of range");
assert(hoop_print_x() <= printer_bed_mm, "Mesh hoop is longer than the printer");
assert(hoop_print_y() <= printer_bed_mm, "Mesh hoop is taller than the printer");
assert(z_skirt < z_floor - 1, "Rim skirt is not deeper than the rib seat");
assert(end_keep_ang > 0.5, "Thin-rib rim ends are too short");
assert(end_keep_ang + 1 < rim_piece_half, "Thin-rib rim skirt has no span");
assert(hoop_clip + 1 < rim_w, "Thin-rib rim slot breaks out of the rim");
assert(thin_rib_print_x() <= printer_bed_mm, "Thin rib is longer than the printer");
assert(thin_rib_print_y() <= printer_bed_mm, "Thin rib is taller than the printer");
assert(thin_rib_t <= printer_bed_mm, "Thin rib is thicker than the printer");
assert(thin_print_r0() > 4, "Thin-rib clip is inside the axis");
assert(thin_side_pin_y() > filament_h, "Side filament is inside the axis");
assert(thin_side_pin_y() + filament_h / 2 < rib_w / 2, "Side filament breaks out of the rib face");
assert(
    abs(thin_side_pin_z() - thin_end_pin_z(-rib_x0 - hoop_clip / 2)) > filament_h + 0.6,
    "Side filament hits the opposite-rib pin"
);
assert(hoop_r(0) > inner_r + hoop_t, "Mesh hoop cuts the thin-rib inner clip");
assert(hoop_r(hoop_count - 1) < thin_rib_r1 - hoop_t, "Mesh hoop cuts the thin-rib rim clip");
assert(thin_rib_h > hoop_w + 2, "Thin rib is shorter than the hoop tab");

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
                    hoop_slot_2d(r, hoop_t + 0.1);
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
        if (hoop_div == 1)
            for (j = [0:thin_n - 1]) {
                s = hoop_clip
                    + r * (thin_az(j) - hoop_az_face(r)) * pi_ / 180;
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
    hoop_print_one(hoop_r(hoop_index), hoop_div <= 1 ? 0 : hoop_seg, 0);
}

module thin_rib_profile_2d(r0) {
    polygon(concat(para_pts(r0, thin_rib_r1, 0), para_pts(thin_rib_r1, r0, -thin_rib_h)));
}

module thin_rib_hoop_slots() {
    wt = hoop_div > 1 ? 2 * hoop_t + 2 * lap_clear : hoop_t + 2 * lap_clear;
    translate([0, 0, -eps])
        linear_extrude(thin_rib_t + 2 * eps, convexity=4)
            for (i = [0:hoop_count - 1])
                hoop_slot_2d(hoop_r(i), wt);
}

module thin_rib_at(az) {
    r0 = thin_r0_az(az);
    difference() {
        linear_extrude(thin_rib_t, convexity=6)
            thin_rib_profile_2d(r0);
        thin_rib_hoop_slots();
        translate([thin_rib_rim_pin_r(), thin_rib_rim_pin_z(), -1])
            filament_bore(thin_rib_t + 2);
        if (thin_az_is_end(az)) {
            pin_r = thin_inner_pin_r(az);
            translate([pin_r, thin_end_pin_z(pin_r), -1])
                filament_bore(thin_rib_t + 2);
        } else {
            translate([0, 0, thin_rib_t / 2])
                rotate([-90, 0, 0])
                    rotate([0, 0, -az])
                        thin_rib_side_filament_world();
        }
    }
}

module thin_rib() {
    thin_rib_at(thin_az(thin_index));
}

module place_thin_rib(az) {
    rotate([0, 0, az])
        rotate([90, 0, 0])
            translate([0, 0, -thin_rib_t / 2])
                thin_rib_at(az);
}

module thin_rib_clip_2d(r_in, r_out) {
    polygon(concat(
        para_pts(r_in, r_out, 2),
        para_pts(r_out, r_in, -thin_rib_h - thin_rib_clear)
    ));
}

module world_to_rib_print() {
    translate([0, 0, rib_w / 2])
        rotate([-90, 0, 0])
            children();
}

module thin_rib_main_slot(az) {
    r_hit = thin_r_hit(az);
    world_to_rib_print()
        rotate([0, 0, az])
            rotate([90, 0, 0])
                translate([0, 0, -thin_slot_t / 2])
                    linear_extrude(thin_slot_t, convexity=4)
                        thin_rib_clip_2d(r_hit - hoop_clip, r_hit + hoop_clip + 2);
}

module thin_rib_rim_slot() {
    rotate([90, 0, 0])
        translate([0, 0, -thin_slot_t / 2])
            linear_extrude(thin_slot_t, convexity=4)
                thin_rib_clip_2d(rim_r0 - 1, rim_r0 + hoop_clip);
}

module thin_rib_rim_filament() {
    r = thin_rib_rim_pin_r();
    z = thin_rib_rim_pin_z();
    y = sqrt(max(dish_r * dish_r - r * r, 1)) + 1;
    translate([r, 0, z])
        rotate([90, 0, 0])
            translate([0, 0, -y])
                filament_bore(2 * y, filament_h);
}

module thin_rib_side_filament_world() {
    y0 = thin_side_pin_y();
    z0 = thin_side_pin_z();
    x0 = rib_x0 - 1;
    x1 = thin_side_pin_x_end();
    for (s = [-1, 1])
        translate([x0, s * y0, z0])
            rotate([0, 90, 0])
                filament_bore(x1 - x0, filament_h);
}

module thin_rib_side_filaments() {
    world_to_rib_print()
        thin_rib_side_filament_world();
}

module thin_rib_main_filament(az) {
    r = thin_inner_pin_r(az);
    world_to_rib_print()
        translate([r * cos(az), r * sin(az), thin_end_pin_z(r)])
            rotate([90, 0, az])
                translate([0, 0, -rib_w / 2 - 1])
                    filament_bore(rib_w + 2, filament_h);
}

module place_hoop(hi, bay, seg) {
    r = hoop_r(hi);
    rotate([0, 0, bay * 360 / n_ribs])
        hoop_segment(r, seg);
}

module insert_bore() {
    cylinder(h=insert_h + 0.2, d=insert_d, $fn=24);
}

module rib_pole_fasteners() {
    world_to_rib_print()
        for (i = [0, 1]) {
            x = pole_bolt_x(i);
            zf = z_of(x);
            translate([x, 0, z_pad - 1])
                cylinder(h=zf - z_pad + 2, d=bolt_d, $fn=24);
            translate([x, 0, zf - pole_insert_h()])
                cylinder(h=pole_insert_h() + 1, d=pole_insert_d(), $fn=24);
        }
}

module through_bore(h) {
    cylinder(h=h, d=bolt_hole, $fn=24);
}

module filament_bore(h, d=filament_v) {
    cylinder(h=h, d=d, $fn=20);
}

module rib_profile_2d() {
    polygon(concat(
        [for (i = [0:n_para])
            let (x = rib_x0 + (rib_r1 - rib_x0) * i / n_para)
                [x, z_of(x)]],
        [for (i = [n_para:-1:0])
            let (x = rib_x0 + (rib_r1 - rib_x0) * i / n_para)
                [x, rib_back(x)]]
    ));
}

module rib_rim_mt_socket(clear=0) {
    span = 2 * atan((rib_w / 2 + 2) / max(rim_r0, 1)) + 2;
    translate([0, 0, rib_w / 2])
        rotate([-90, 0, 0])
            rotate([0, 0, -span / 2])
                rotate_extrude(angle=max(span, 0.01), convexity=4, $fn=spin_fn(dish_r))
                    rim_mt_profile_2d(clear);
}

module rib_rim_joint_filaments() {
    world_to_rib_print()
        for (side = [-1, 1]) {
            a0s = side < 0 ? -end_keep_ang : 0;
            for (f = [1 / 3, 2 / 3])
                rotate([0, 0, a0s + f * end_keep_ang])
                    translate([rim_fil_r, 0, z_rim_back - 1])
                        filament_bore(z_of(dish_r) - z_rim_back + 4);
            rotate([0, 0, a0s + 0.5 * end_keep_ang])
                translate([rim_r0 - 1, 0, z_tenon_mid])
                    rotate([0, 90, 0])
                        filament_bore(rim_w + 2, filament_h);
        }
}

module rib_rim_back_support_2d() {
    translate([rim_r0, z_rim_back])
        square([rim_w, max(tenon_z_hi(rim_tenon_r1) - z_rim_back, 0.2)]);
}

module radial_rib() {
    difference() {
        union() {
            linear_extrude(rib_w, convexity=6)
                rib_profile_2d();
            linear_extrude(rib_w, convexity=4)
                rib_rim_back_support_2d();
        }
        rib_rim_mt_socket(lap_clear);
        rib_rim_joint_filaments();
        hoop_slots();
        thin_rib_side_filaments();
        for (j = [0:thin_n - 1]) {
            thin_rib_main_slot(thin_az(j));
            if (thin_az_is_end(thin_az(j)))
                thin_rib_main_filament(thin_az(j));
        }
        rib_pole_fasteners();
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
                    radial_rib();
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

module radial_rib_arm_print() {
    translate([-rib_x0, -z_pad, 0])
        radial_rib_arm();
}

module place_rib_arm(az) {
    rotate([0, 0, az])
        rotate([90, 0, 0])
            translate([0, 0, -rib_w / 2])
                radial_rib_arm();
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
            for (i = [0, 1])
                translate([0, pole_bolt_x(i), flange_back - 1])
                    cylinder(h=flange_t + 2, d=bolt_d, $fn=24);
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
    polygon([
        [r0, z_tenon_lo - c],
        [r1, z_tenon_lo - c],
        [r1, tenon_z_hi(r1) + c],
        [r0, tenon_z_hi(r0) + c]
    ]);
}

module rim_mt_solid(a0, a1, clear=0) {
    rotate([0, 0, a0])
        rotate_extrude(angle=max(a1 - a0, 0.01), convexity=4, $fn=spin_fn(dish_r))
            rim_mt_profile_2d(clear);
}

module rim_mt_filaments(a_sh, dir=1, span=lap_ang) {
    for (f = [1 / 3, 2 / 3])
        rotate([0, 0, a_sh + dir * f * span])
            translate([rim_fil_r, 0, z_rim_back - 1])
                filament_bore(z_of(dish_r) - z_rim_back + 4);
    rotate([0, 0, a_sh + dir * 0.5 * span])
        translate([rim_r0 - 1, 0, z_tenon_mid])
            rotate([0, 90, 0])
                filament_bore(rim_w + 2, filament_h);
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
        for (j = [0:thin_n - 1]) {
            taz = thin_rib_taz(j);
            if (taz >= rim_base0(i) - 0.05 && taz <= rim_base1(i) + 0.05)
                rotate([0, 0, taz]) {
                    thin_rib_rim_slot();
                    thin_rib_rim_filament();
                }
        }
        if (rim_div > 1 && i > 0)
            rim_mt_solid(b0, b0 + lap_ang, lap_clear);
        if (rim_div > 1 && i < rim_div - 1)
            rim_mt_filaments(b1, 1);
        if (rim_div > 1 && i > 0)
            rim_mt_filaments(b0, 1);
        if (i == 0)
            rim_mt_filaments(a0, 1, end_keep_ang);
        if (i == rim_div - 1)
            rim_mt_filaments(b1, 1, end_keep_ang);
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
    ["radial_rib_arm"],
    [for (i = [0:rim_div - 1]) str("rim_segment;rim_index=", i)],
    [for (i = [0:thin_n - 1]) str("thin_rib;thin_index=", i)],
    [for (
        h = [0:hoop_count - 1],
        s = hoop_div <= 1 ? [0] : [0, 1]
    ) str("mesh_hoop;hoop_index=", h, ";hoop_seg=", s)],
    ["enclosure_body", "radome_lid", "reflector_lid", "gasket", "pole_bracket"]
));

module assembly() {
    place_rib_arm(0);
    for (i = [0:n_ribs - 1]) {
        for (p = [0:rim_div - 1])
            place_rim(i, p);
        for (j = [0:thin_n - 1])
            place_thin_rib(thin_az(j));
        for (h = [0:hoop_count - 1], s = [0:hoop_div - 1])
            place_hoop(h, i, s);
    }
    place_enclosure();
    place_radome();
    place_reflector();
    place_gaskets();
    pole_bracket();
}

if (part == "radial_rib_arm")
    radial_rib_arm_print();
else if (part == "rim_segment")
    rim_print();
else if (part == "thin_rib")
    thin_rib();
else if (part == "mesh_hoop")
    hoop_print();
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
else if (part == "assembly")
    assembly();
else
    assert(false, str("unknown part: ", part));
