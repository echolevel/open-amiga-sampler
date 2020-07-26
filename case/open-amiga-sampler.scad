$fa = 1;
$fs = 0.4;

use <MCAD/boxes.scad>

boxWidth = 30;
boxHeight = 21;
boxDepth = 30;
boxRadius = 4;
boxWallThickness = 2;
wedgeChunkiness = 3.0;
wedgeProtrusion = 2.0;
pcbThickness = 1.6;
pcbDistanceFromEdge = 4.6;
//screwHoleRadius = 1.125;
//screwHeadRadius = 2.0;
//screwSupportThickness = 1.25;

connectorPlateWidth = boxWidth - boxWallThickness * 2.0;

module outerShell() {
    roundedBox(size = [boxWidth, boxDepth, boxHeight], radius = boxRadius, sidesonly = false);
}

module innerShell() {
    roundedBox(size = [ boxWidth - boxWallThickness * 2, 
                        boxDepth - boxWallThickness * 2, 
                        boxHeight - boxWallThickness * 2],
                        radius = boxRadius - boxWallThickness, sidesonly = false);
}

module fullOuterCase() {
    difference () {
        difference () {
            difference() {
                outerShell();
                innerShell();
            }

            // DB25 hole
            translate([0, -(boxDepth - boxWallThickness) / 2, 0])
                rotate([90, 0, 0])
                    roundedBox(size = [20, 10.5, boxWallThickness + 1], radius = 1, sidesonly = true);
/*            
            // L phono
            translate([-boxWidth / 4, (boxDepth - boxWallThickness) / 2, 0])
                rotate([90, 0, 0])
                    cylinder(h = boxWallThickness + 1, r = 4, center = true);

            // R phono
            translate([boxWidth / 4, (boxDepth - boxWallThickness) / 2, 0])
                rotate([90, 0, 0])
                    cylinder(h = boxWallThickness + 1, r = 4, center = true);
            
            // Pot
            translate([0, boxDepth / 4, (boxHeight - boxWallThickness) / 2])
                cylinder(h = boxWallThickness + 1, r = 3, center = true);
*/
        }
    }
}

module pressFitPlug(r1, h1, r2, h2) {
    taper = 0.3;
    union() {
        translate([0, 0, 0])
            cylinder(h = h1, r = r1, center = false);
        translate([0, 0, h1])
            cylinder(h = h2 - r2 * taper, r = r2, center = false, $fn = 8);
        translate([0, 0, h1 + h2 - r2 * taper])
            cylinder(h = r2 * 0.3, r1 = r2, r2 = r2 * (1.0 - taper), center = false, $fn = 8);
    }
};

module pressFitReceptacle(r1, r2, h) {
    taper = 0.3;
    difference() {
        translate([0, 0, 0])
            cylinder(h = h, r = r1, center = false);
        union() {
            translate([0, 0, -0.1])
                cylinder(h = h + 0.2, r = r2, center = false, $fn = 36);
            translate([0, 0, h - (r1 - r2) * taper])
                cylinder(h = (r1 - r2) * taper + 0.1, r1 = r2, r2 = r2 + (r1 - r2) * taper, center = false, $fn = 36);
        }
    }
};

module pcb() {
    difference() {
        cube([37.5, 34.0, pcbThickness], center = true);
        union() {
            translate([-37.5 * 0.5 + 2.5, 34.0 * 0.5 - 2.5, 0.0])
                cylinder(h = pcbThickness + 2, r = 2.25 * 0.5, center = true);
            translate([37.5 * 0.5 - 2.5, 34.0 * 0.5 - 2.5, 0.0])
                cylinder(h = pcbThickness + 2, r = 2.25 * 0.5, center = true);
        }
    }
}

module pressFitParts(bottom) {
    intersection() {
        rotate([0, 180, 0])
        union() {
            // Middle
            translate([0, -5.0, -boxHeight * 0.5])
                pressFitReceptacle(r1 = 2.5, r2 = 1.25, h = (boxHeight - pcbThickness) * 0.5);
            // Back left
            translate([-boxWidth * 0.5 + boxWallThickness + 2.3, boxDepth * 0.5 - 2.3 - boxWallThickness, -boxHeight * 0.5])
                pressFitReceptacle(r1 = 2.5, r2 = 1.25, h = boxHeight * (bottom ? 0.75 : 0.25));
            // Back right
            translate([boxWidth * 0.5 - boxWallThickness - 2.3, boxDepth * 0.5 - 2.3 - boxWallThickness, -boxHeight * 0.5])
                pressFitReceptacle(r1 = 2.5, r2 = 1.25, h = boxHeight * (bottom ? 0.75 : 0.25));
        }
        innerShell();
    }
}

module top() {
    difference() {
        union() {
            difference() {
                fullOuterCase();
                union() {
                    innerShell();
                    translate([0, 0, -boxHeight * 0.5])
                        cube([boxWidth + 1, boxDepth + 1, boxHeight], center = true);
                }
            }
            
            pressFitParts(false);
        }
        union() {
            translate([0, boxDepth * 0.5 - 1, -boxHeight * 0.25])
                rotate([90, 0, 0])
                    cube([connectorPlateWidth, boxHeight, boxWallThickness + boxRadius], center = true);
            // Pot hole
            translate([0, boxDepth * 0.1666, (boxHeight - boxWallThickness) * 0.5])
                cylinder(h = boxWallThickness + 0.01, r = 3.5, center = true);
        }
    }
}

module bottom() {
    rotate([0, 180, 0])
    union() {
        difference()
        {
            union() {
                difference() {
                    fullOuterCase();
                    union() {
                        innerShell();
                        translate([0, 0, -(boxHeight + 1) * 0.5])
                            cube([boxWidth + 1, boxDepth + 1, boxHeight + 1], center = true);
                    }
                }
                intersection() {
                    translate([0, boxDepth * 0.5 - boxWallThickness * 0.5, boxHeight * 0.25])
                        rotate([90, 0, 0])
                            cube([connectorPlateWidth, boxHeight, boxWallThickness + boxRadius], center = true);
                    fullOuterCase();
                }
            }
            // Phono hole
            translate([0, (boxDepth - boxWallThickness) * 0.5, 0])
                rotate([90, 0, 0])
                    cylinder(r = 3.5, h = boxWallThickness + 0.01, center = true);
        }

        pressFitParts(true);
    }
}


translate([-(boxWidth * 0.5 + 2), 0, 0])
    rotate([0, 180, 0])
        color("red")
        top();

translate([(boxWidth * 0.5 + 2), 0, 0])
    color("blue")
    bottom();

/*
translate([0, 0, 0])
    color("blue")
    bottom();
*/

/*
rotate([0, 180, 0])
translate([0, 0, 0])
color("red")
top();
*/

/*
translate([0, 0, 0])
color("red")
top();
color("blue")
bottom();
*/
