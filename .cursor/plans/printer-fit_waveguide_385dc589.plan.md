---
name: Printer-fit waveguide
overview: Rectangular 915 MHz slotted waveguide on a WR-975 bore, with broad-wall couplers and cap skirts so the tube fits a 256 mm bed. Slot width is 16 mm. Round mode keeps a full ring sleeve.
todos:
  - id: resize-bore
    content: Set the rectangular bore to 247.65 × 123.825 mm, the bed limit to 256 mm, and the default shape to rectangular
    status: completed
  - id: long-edge-joints
    content: Rectangular couplers and cap skirts grip only the broad walls, so X span equals the tube width
    status: completed
  - id: widen-slots
    content: Set slot width to 16 mm
    status: completed
  - id: fit-assert
    content: Assert part spans fit a 256 mm bed and echo the tube and coupler spans
    status: completed
  - id: comments
    content: Update the header for the WR-975 bore, 256 mm bed, and long-edge joints
    status: completed
  - id: verify
    content: Run OpenSCAD echoes for rectangular and round and confirm asserts, offset, and section heights
    status: completed
isProject: false
---

# WR-975 slotted waveguide

Resonant shunt-slot array in [`models/915mhz_slotted_waveguide.scad`](models/915mhz_slotted_waveguide.scad). Vertical guide, horizontal polarization. Probe at `λg/4`, longitudinal broad-wall slots every `λg/2` with alternating offset, short at `λg/4` past the last slot. Default `waveguide_shape` is `"rectangular"`.

## Bore and slots

Finished rectangular bore **247.65 × 123.825 mm** (WR-975, 2:1). Walls 3 mm, coating 0.05 mm, so the tube outer size is **253.75 × 129.93 mm**. Bed limit is 256 mm in X, Y, and Z; `printer_height_mm` is 256 and the 5 mm height reserve is unchanged. Print upright, no brim.

`slot_width_mm` is **16**. `slot_length_lambda0` stays 0.48. `rectangular_slot_offset_mm` stays 0 so the Stevenson formula supplies the offset.

At 915 MHz:

- cutoff 605 MHz, next mode 1211 MHz
- `λg` 437 mm, slot spacing 218 mm, RF length 1092 mm
- eight-slot offset 31.7 mm (46.2 mm with one wall slotted)

## Joints

Rectangular coupler: a pair of straps on the broad walls (±Y). Each strap is `outer_width` in X, `coupler_length_mm` along Z, with `coupler_radial_clearance_mm` and `coupler_wall_mm` added only in Y.

Rectangular cap: plate matches the tube outer width and depth. Socket skirt grips only the broad walls, with `cap_radial_clearance_mm` in Y. The coated inner face is the RF short. No internal ledge.

Round mode keeps the full ring sleeve and cap.

## Checks

Assert tube, cap, and coupler spans are at most 256 mm in X and Y for both shapes, and name the oversized part. Echo tube outer size and coupler span with the rectangular dimensions. Update the file header to match this bore, bed, and joint geometry.

Slot pitch is 218 mm, so the existing height splitter is unchanged.
