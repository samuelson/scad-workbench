// name: Degree band
// description: Circular ring with a 360° scale on the outer face
// Printable protractor ring. Ticks and optional numerals are engraved
// on the outer wall. 0° sits on +X; degrees increase counterclockwise.
inner_diameter = 60; // [10:1:180]
band_height = 14; // [6:0.5:40]
wall = 5; // [2.5:0.5:16]
tick_step = 1; // [1:1:15]
label_step = 10; // [5:5:90]
medium_step = 5; // [0:5:45]
tick_depth = 0.6; // [0.3:0.1:1.5]
show_numbers = true;
numbers_vertical = true;
vertical_number_size = 0.5; // [0.4:0.05:1]
number_position = 0.75; // [0.2:0.01:0.9]
number_offset = -3.5; // [-12:0.1:12]
label_font = "Liberation Sans"; // [7 Segment, Liberation Sans, Liberation Sans:style=Bold, Liberation Serif, Liberation Mono, DejaVu Sans]

inner_r = inner_diameter / 2;
outer_r = inner_r + wall;
outer_diameter = inner_diameter + 2 * wall;
$fn = max(96, round(outer_diameter * 1.6));
engrave = min(tick_depth, wall * 0.55);
arc_mm = PI * outer_diameter / 360;
tick_w = min(0.55, arc_mm * tick_step * 0.38);

function digits_of(n) =
    n < 10 ? [n] : concat(digits_of(floor(n / 10)), [n % 10]);

// Horizontal / vertical bars for a 7-segment digit (a b c d e f g).
seg_on = [
    [1,1,1,1,1,1,0],
    [0,1,1,0,0,0,0],
    [1,1,0,1,1,0,1],
    [1,1,1,1,0,0,1],
    [0,1,1,0,0,1,1],
    [1,0,1,1,0,1,1],
    [1,0,1,1,1,1,1],
    [1,1,1,0,0,0,0],
    [1,1,1,1,1,1,1],
    [1,1,1,1,0,1,1]
];

module bar_h(x, y, len, t) {
    translate([x, y]) square([len, t], center=true);
}

module bar_v(x, y, len, t) {
    translate([x, y]) square([t, len], center=true);
}

module digit_2d(n, w, h, t) {
    s = seg_on[n];
    hl = w - t * 0.35;
    vl = h / 2 - t * 0.45;
    if (s[0]) bar_h(0,  h / 2 - t / 2, hl, t);
    if (s[1]) bar_v( w / 2 - t / 2,  h / 4, vl, t);
    if (s[2]) bar_v( w / 2 - t / 2, -h / 4, vl, t);
    if (s[3]) bar_h(0, -h / 2 + t / 2, hl, t);
    if (s[4]) bar_v(-w / 2 + t / 2, -h / 4, vl, t);
    if (s[5]) bar_v(-w / 2 + t / 2,  h / 4, vl, t);
    if (s[6]) bar_h(0, 0, hl, t);
}

module number_2d(n, h) {
    if (label_font == "7 Segment") {
        w = h * 0.62;
        t = h * 0.16;
        gap = h * 0.12;
        d = digits_of(n);
        count = len(d);
        total = count * w + (count - 1) * gap;
        for (i = [0:count - 1])
            translate([-total / 2 + w / 2 + i * (w + gap), 0])
                digit_2d(d[i], w, h, t);
    } else {
        text(str(n), size=h, font=label_font, halign="center", valign="center", $fn=24);
    }
}

module tick_cut(angle, h, w) {
    rotate([0, 0, angle])
        translate([outer_r - engrave, -w / 2, -0.02])
            cube([engrave + 0.08, w, h + 0.02]);
}

function number_span(h, digits=3) =
    label_font == "7 Segment"
        ? digits * h * 0.62 + (digits - 1) * h * 0.12
        : digits * h * 0.72;

module label_cut(angle, n, h, z) {
    rotate([0, 0, angle])
        translate([outer_r - engrave, 0, z])
            rotate([90, 0, 90])
                linear_extrude(height=engrave + 0.08)
                    rotate(numbers_vertical ? 90 : 0)
                        number_2d(n, h);
}

module scale_marks() {
    tick_span = band_height * 0.92;
    minor_h = tick_span * 0.36;
    medium_h = tick_span * 0.62;
    major_h = tick_span;
    max_label_span = max(0.8, band_height - minor_h);
    vertical_auto = max_label_span / 2.1;
    label_h = numbers_vertical
        ? vertical_auto * min(vertical_number_size, 1)
        : min(max_label_span * 0.72, arc_mm * label_step * 0.36);
    z_half = (numbers_vertical ? number_span(label_h) : label_h) / 2;
    label_z_min = (numbers_vertical ? minor_h : 0) + z_half;
    label_z_max = band_height - z_half;
    wanted_z = min(label_z_max, max(label_z_min, band_height * number_position));
    drawn_major = (!show_numbers || numbers_vertical)
        ? major_h
        : max(band_height * 0.12, wanted_z - z_half - band_height * 0.04);
    drawn_medium = drawn_major * (medium_h / major_h);
    drawn_minor = drawn_major * (minor_h / major_h);
    label_z = wanted_z;
    auto_shift_mm = numbers_vertical ? tick_w * 1.7 / 2 + 0.45 + label_h / 2 : 0;
    label_angle_offset = (auto_shift_mm + number_offset) / outer_r * 180 / PI;

    for (a = [0:tick_step:359]) {
        is_major = (a % label_step == 0);
        is_medium = (medium_step > 0) && (a % medium_step == 0);
        h = is_major ? drawn_major : (is_medium ? drawn_medium : drawn_minor);
        w = is_major ? tick_w * 1.7 : tick_w;
        tick_cut(a, h, w);
        if (show_numbers && is_major)
            label_cut(a + label_angle_offset, a, label_h, label_z);
    }
}

difference() {
    cylinder(h=band_height, r=outer_r);
    translate([0, 0, -1])
        cylinder(h=band_height + 2, r=inner_r);
    scale_marks();
}
