// name: 5.8 GHz rib dish
// description: 400 mm prime-focus rib frame · feed arm · focal box
//
// 5.8 GHz prime-focus rib frame. Units: mm. OpenSCAD 2021.01+. No libraries.
// Vertex at the origin, opening toward +Z, focus at z = focal_length.
// Structure sits behind the paraboloid (toward -Z). No mesh or metal in the
// model. Seven identical radial ribs, one rib with a Z-axis arm mount, and
// eight identical rim arcs bolt to a one-piece hub. A hollow feed arm sleeves
// the mount and carries cables to a focus-centered box with two lids.

/* [Selection] */
part = "assembly"; // [assembly, hub, radial_rib, radial_rib_mount, rim_segment, feed_arm, enclosure_body, radome_lid, reflector_lid, gasket]
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

/* [Feed arm] */
arm_along = 28; // [22:0.5:50]
arm_across = 20; // [14:0.5:32]
arm_wall = 2.5; // [1.2:0.1:8]
mount_h = 24; // [16:0.5:40]
socket_len = 32; // [20:0.5:50]
arm_slip = 0.25; // [0.1:0.05:0.6]

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

/* [Hidden] */
$fa = fast_preview ? 12 : 6;
$fs = fast_preview ? 2 : 0.8;

n_ribs = 8;
n_para = fast_preview ? 16 : 40;
eps = 0.2;
insert_d = 4.0;
insert_h = 4;
bolt_hole = 3.3;
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
rib_r0 = hub_r - lap_w;
rib_r1 = dish_r;
rim_r0 = dish_r - rim_w;
z_floor = dish_depth - rim_h;
rim_half_ang = 180 / n_ribs - atan(lap_clear / 2 / dish_r);
hub_hole_r = hub_r - lap_w / 2;
rim_hole_r = dish_r - rim_w / 2;

cavity_h = (0.75 + cavity_steps * 0.5) * lambda_mm;
mount_along_id = arm_along - 2 * arm_wall;
mount_across_id = arm_across - 2 * arm_wall;
boot_along_id = arm_along + 2 * arm_slip;
boot_across_id = arm_across + 2 * arm_slip;
boot_along_od = boot_along_id + 2 * arm_wall;
boot_across_od = boot_across_id + 2 * arm_wall;
rib_w = boot_across_od;
rim_bolt_off = min(4, rib_w / 2 - bolt_hole / 2 - 1.6);
sock_along_id = boot_along_od + 2 * arm_slip;
sock_across_id = boot_across_od + 2 * arm_slip;
sock_along_od = sock_along_id + 2 * sock_wall;
sock_across_od = sock_across_id + 2 * sock_wall;
mount_insert_off = mount_along_id / 2 - insert_d / 2 + 1.2;
arm_end_keep = insert_d / 2 + 1.6;
arm_insert_off = boot_along_id / 2 - insert_d / 2 + 1.2;
pad_r = insert_d / 2 + 2.4;
pad_len = insert_h + 0.2 - arm_wall + 1.0;
enc_z_keep = gasket_lip + groove_w + 0.8;
r_mount = rim_r0 - arm_along / 2 - mount_gap;
z_mount_face = r_mount * r_mount / (4 * focal_length);
p_knee = [r_mount, 0, z_mount_face + mount_h];
face_x = enclosure_x / 2 + enc_wall;
enc_meet_dx = face_x - p_knee[0];
enc_meet_dz = focal_length - p_knee[2];
enc_meet_d = sqrt(enc_meet_dx * enc_meet_dx + enc_meet_dz * enc_meet_dz);
arm_ang = atan2(enc_meet_dz, enc_meet_dx) - asin(sock_along_od / 2 / enc_meet_d);
p_enc = [face_x, 0, p_knee[2] + enc_meet_dx * tan(arm_ang)];
arm_dx = p_enc[0] - p_knee[0];
arm_dz = p_enc[2] - p_knee[2];
arm_len = sqrt(arm_dx * arm_dx + arm_dz * arm_dz);
groove_outer_x = enclosure_x / 2 + gasket_lip + groove_w;
groove_outer_y = enclosure_y / 2 + gasket_lip + groove_w;
bolt_x = groove_outer_x + gasket_land + bolt_hole / 2;
bolt_y = groove_outer_y + gasket_land + bolt_hole / 2;
arm_insert_s = arm_len - socket_len + arm_end_keep;
z_mount_rim = (r_mount + arm_along / 2) * (r_mount + arm_along / 2) / (4 * focal_length);
mount_insert_z = (z_mount_rim + z_mount_face + mount_h) / 2;
miter_skew = (boot_along_od / 2) * abs(arm_dz / arm_dx);

function z_of(r) = r * r / (4 * focal_length);

function para_pts(r0, r1, dz) =
    [for (i = [0:n_para])
        let (r = r0 + (r1 - r0) * i / n_para)
            [r, z_of(r) + dz]];

function hub_print_h() = hub_t + z_of(hub_r);
function rib_print_x() = rib_r1 - rib_r0;
function rib_print_y() = z_of(rib_r1) - (z_of(rib_r0) - rib_h);
function rib_mount_print_y() =
    max(z_of(rib_r1), z_mount_face + mount_h) - (z_of(rib_r0) - rib_h);
function rim_print_x() = dish_r - rim_r0 * cos(rim_half_ang);
function rim_print_y() = 2 * dish_r * sin(rim_half_ang);
function rim_insert_t() = z_of(rim_hole_r) - z_floor;
function feed_arm_print_x() = r_mount + boot_along_od / 2 - face_x + 4;
function lid_outer_x() = 2 * max(enclosure_x / 2 + enc_wall, bolt_x + boss_r);
function lid_outer_y() = 2 * max(enclosure_y / 2 + enc_wall, bolt_y + boss_r);

echo(lambda_mm=lambda_mm, dish_depth_mm=dish_depth, f_D=f_D);
echo(hub_od=hub_od, thickness=thickness, rim_w=rim_w, rim_h=rim_h);
echo(rib_print=[rib_print_x(), rib_print_y(), rib_w]);
echo(rib_mount_print=[rib_print_x(), rib_mount_print_y(), rib_w]);
echo(rim_print=[rim_print_x(), rim_print_y(), rim_h]);
echo(hub_print=[hub_od, hub_od, hub_print_h()]);
echo(cavity_h=cavity_h, r_mount=r_mount, arm_len=arm_len, arm_ang=arm_ang);
echo(boot_along_od=boot_along_od, boot_across_od=boot_across_od, mount_along_id=mount_along_id, mount_across_id=mount_across_id);

assert(rib_r0 > 8, "Hub is too small for the half-laps");
assert(thickness / 2 > insert_h + 0.6, "Stock is too thin for the hub lap");
assert(thickness > insert_h + 1, "Stock is too thin for the insert");
assert(lap_w > insert_d + 4, "Lap is too short for the insert");
assert(rim_w >= insert_d + 4, "Rim is too narrow for the bolt");
assert(thickness > bolt_hole + 0.4, "Stock is too thin for M3");
assert(2 * (rim_bolt_off + bolt_hole / 2 + 1.2) <= rib_w, "Rib is too thin for two rim bolts");
assert(rim_h < thickness - 2, "L-notch leaves no tab on the rib");
assert(rim_insert_t() > insert_h + 0.6, "Rim is too thin at the insert");
assert(n_ribs * (rib_w + lap_clear + 2) < 2 * PI * hub_hole_r, "Hub laps overlap");
assert(rim_half_ang < 80, "Rim sector is too wide to print as a flat arc");
assert(hub_od <= printer_bed_mm, "Hub is wider than the printer");
assert(hub_print_h() <= printer_bed_mm, "Hub is taller than the printer");
assert(rib_print_x() <= printer_bed_mm, "Radial rib is longer than the printer");
assert(rib_print_y() <= printer_bed_mm, "Radial rib is taller than the printer");
assert(rib_mount_print_y() <= printer_bed_mm, "Arm-mount rib is taller than the printer");
assert(thickness <= printer_bed_mm, "Stock is thicker than the printer");
assert(rib_w <= printer_bed_mm, "Rib is wider than the printer");
assert(rim_print_x() <= printer_bed_mm, "Rim segment is too wide for the printer");
assert(rim_print_y() <= printer_bed_mm, "Rim segment is too long for the printer");
assert(rim_h <= printer_bed_mm, "Rim segment is thicker than the printer");
assert(arm_wall > 1.2, "Feed arm wall is too thin to print");
assert(mount_along_id > 4 && mount_across_id > 4, "Mount bore is too small for a cable");
assert(boot_along_id > 4 && boot_across_id > 4, "Feed arm bore is too small for a cable");
assert(arm_across <= rib_w, "Mount is wider than the rib");
assert(mount_insert_off + insert_d / 2 + 0.6 < arm_along / 2, "Mount insert breaks out of the end wall");
assert(pad_len < mount_across_id - 2, "Insert pad closes the arm mount");
assert(r_mount - arm_along / 2 > hub_r + 2, "Arm mount hits the hub");
assert(r_mount + arm_along / 2 < rim_r0 - 0.2, "Arm mount hits the rim");
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
assert(boot_across_od <= printer_bed_mm, "Feed arm is thicker than the printer");
assert(boot_along_od <= printer_bed_mm, "Feed arm is wider than the printer");
assert(lid_outer_x() <= printer_bed_mm, "Enclosure is wider than the printer");
assert(lid_outer_y() <= printer_bed_mm, "Enclosure is longer than the printer");
assert(cavity_h + sock_along_od <= printer_bed_mm, "Enclosure body is taller than the printer");
assert(mount_h > z_mount_rim - z_mount_face + 2 * fastener_clear, "Arm mount is too short for the inserts");
assert(socket_len > arm_end_keep + miter_skew + fastener_clear, "Enclosure socket is too short for the bolts");
assert(arm_insert_off + insert_d / 2 + 0.6 < boot_along_od / 2, "Arm insert breaks out of the along wall");
assert(pad_len < boot_across_id - 2, "Insert pad closes the feed arm");
assert(mount_insert_z - z_mount_face < mount_h - fastener_clear, "Mount insert is too close to the top");
assert(mount_insert_z > z_mount_rim + fastener_clear, "Mount insert is too close to the dish");

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

module mount_prism(along, across, z0, z1) {
    translate([r_mount - along / 2, z0, rib_w / 2 - across / 2])
        cube([along, z1 - z0, across]);
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
    z0 = z_mount_face - rib_h - eps;
    z1 = z_mount_face + mount_h + eps;
    z_bore0 = z_of(r_mount - arm_along / 2) - rib_h - 2;
    difference() {
        union() {
            difference() {
                union() {
                    radial_rib();
                    mount_prism(arm_along, arm_across, z0, z1);
                }
                mount_prism(mount_along_id, mount_across_id, z_bore0, z1 + 1);
            }
            mount_insert_pads();
        }
        mount_inserts();
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

module hub_profile_2d() {
    polygon(concat(
        [[0, -hub_t], [hub_r, -hub_t]],
        [for (i = [n_para:-1:0]) let (r = hub_r * i / n_para) [r, z_of(r)]]
    ));
}

module hub_pocket() {
    r0 = rib_r0 - lap_clear;
    r1 = hub_r + 2;
    rotate([90, 0, 0])
        translate([0, 0, -(rib_w + lap_clear) / 2])
            linear_extrude(rib_w + lap_clear, convexity=4)
                polygon(concat(
                    [[r0, -hub_t - eps], [r1, -hub_t - eps]],
                    para_pts(r1, r0, -rib_h / 2 + lap_clear)
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

module rect_x(len, y, z) {
    translate([0, -y / 2, -z / 2])
        cube([len, y, z]);
}

module slab_z(z0, z1) {
    translate([-500, -500, z0])
        cube([1000, 1000, z1 - z0]);
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

module z_rect(ax, ay, z0, z1) {
    translate([r_mount - ax / 2, -ay / 2, z0])
        cube([ax, ay, z1 - z0]);
}

module arm_outer() {
    union() {
        z_rect(boot_along_od, boot_across_od, z_mount_face - 4, p_knee[2] + 0.2);
        hull() {
            translate([r_mount, 0, p_knee[2]])
                cube([boot_along_od, boot_across_od, 0.4], center=true);
            along_arm()
                rect_x(0.4, boot_across_od, boot_along_od);
        }
        along_arm()
            rect_x(arm_len + 6, boot_across_od, boot_along_od);
    }
}

module arm_inner() {
    union() {
        z_rect(boot_along_id, boot_across_id, z_mount_face - 6, p_knee[2] + 1);
        hull() {
            translate([r_mount, 0, p_knee[2]])
                cube([boot_along_id, boot_across_id, 0.4], center=true);
            along_arm()
                rect_x(0.4, boot_across_id, boot_along_id);
        }
        along_arm()
            translate([-1, 0, 0])
                rect_x(arm_len + 8, boot_across_id, boot_along_id);
    }
}

module boot_through_holes() {
    for (s = [-1, 1])
        translate([r_mount + s * mount_insert_off, -boot_across_od / 2 - 1, mount_insert_z])
            rotate([-90, 0, 0])
                through_bore(boot_across_od + 2);
}

module arm_insert_pads() {
    along_arm()
        intersection() {
            union() {
                for (sy = [-1, 1], sz = [-1, 1])
                    translate([arm_insert_s, sy * boot_across_id / 2, sz * arm_insert_off])
                        rotate([sy > 0 ? 90 : -90, 0, 0])
                            cylinder(h=pad_len + pad_r, r1=pad_r, r2=0, $fn=28);
            }
            translate([
                arm_insert_s - pad_r - 1,
                -boot_across_id / 2 - 0.2,
                -boot_along_id / 2
            ])
                cube([2 * pad_r + 2, boot_across_id + 0.4, boot_along_id]);
            union() {
                for (sy = [-1, 1])
                    translate([
                        arm_insert_s - pad_r - 1,
                        sy > 0 ? boot_across_id / 2 - pad_len : -boot_across_id / 2,
                        -boot_along_id / 2
                    ])
                        cube([2 * pad_r + 2, pad_len + 0.2, boot_along_id]);
            }
        }
}

module arm_enc_inserts() {
    along_arm()
        for (s = [-1, 1]) {
            translate([arm_insert_s, boot_across_od / 2, s * arm_insert_off])
                rotate([90, 0, 0])
                    insert_bore();
            translate([arm_insert_s, -boot_across_od / 2, s * arm_insert_off])
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
                translate([face_x - 400, -200, -200])
                    cube([400, 400, 400]);
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
        translate([0, boot_across_od / 2, 0])
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
            rect_x(enc_wall + 12, boot_across_id, boot_along_id);
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

module assembly() {
    hub();
    for (i = [0:n_ribs - 1]) {
        if (i == 0)
            place_rib_mount(0);
        else
            place_rib(i * 360 / n_ribs);
        place_rim(i * 360 / n_ribs);
    }
    feed_arm();
    place_enclosure();
    place_radome();
    place_reflector();
    place_gaskets();
}

if (part == "hub")
    hub_print();
else if (part == "radial_rib")
    radial_rib();
else if (part == "radial_rib_mount")
    radial_rib_mount();
else if (part == "rim_segment")
    rim_print();
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
else
    assembly();
