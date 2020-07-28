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
        }
    }
}

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

/*
module snapFitClipAndLip() {
    // Lip and snap fit clip
    snapFitPoints = [
                [0, 0],
                [boxWallThickness * 0.5, -boxWallThickness * 0.5],
                [boxWallThickness * 0.5, -boxWallThickness * 2.5 + boxWallThickness * 0.5],
                [boxWallThickness * 0.25, -boxWallThickness * 2.5],
    
                [-boxWallThickness * 0.25, -boxWallThickness * 2.5 + boxWallThickness * 0.5],
                [0, -boxWallThickness * 2.5 + boxWallThickness],
                [0, -boxWallThickness * 1.5],
            ];
    
    difference() {
        rotate([90, 0, 0])
            translate([-boxWidth * 0.5 + boxWallThickness, boxWallThickness, 0])
                union() {
                    linear_extrude(height = 5, center = true)
                        polygon(snapFitPoints, 
                        [
                            [0, 1, 2],
                            [0, 2, 3],
                            [3, 4, 5],
                            [0, 3, 5]
                        ]);
                    linear_extrude(height = boxDepth - boxWallThickness * 4 - 0.5, center = true)
                        polygon(snapFitPoints, 
                        [
                            [0, 6, 2],
                            [0, 1, 2]
                        ]);
                }
        union() {
            clipGap = 1.0;
            translate([-boxWidth * 0.5 + boxWallThickness * 1.5, 2.5 + clipGap * 0.5, -2.5])
                cube([boxWallThickness + 0.01, clipGap, 5], center = true);
            translate([-boxWidth * 0.5 + boxWallThickness * 1.5, -(2.5 + clipGap * 0.5), -2.5])
                cube([boxWallThickness + 0.01, clipGap, 5], center = true);
        }
    }
}

module snapFitHole() {
    translate([boxWidth * 0.5 - boxWallThickness - 0.01, 0, 0])
        rotate([-90, 0, 0])
            linear_extrude(height = 7, center = true)
                polygon([
                    [0, -boxWallThickness * 1.6],
                    [boxWallThickness * 0.33, -boxWallThickness],
                    [0, -boxWallThickness * 0.4]
                ], 
                [
                    [0, 1, 2]
                ]);
}
*/

snapFitLength = 10;

module snapFitParts(top) {
    length = (top ? snapFitLength : snapFitLength + 0.5);
    thickness = (top ? boxWallThickness + 0.001 : boxWallThickness + 0.001 + 0.5);
    clipSize = (top ? 1 : 1.1);
    
    for (a = [0 , 180]) {
        rotate([0, 0, a]) {
            translate([-(boxWidth - boxWallThickness) * 0.5, 0, 0])
            {
                cube([thickness, length, boxHeight], center = true);
                translate([thickness * 0.5, 0, -boxHeight * 0.3])
                    rotate([0, 45, 0])
                        cube([clipSize, length, clipSize], center = true);
            }
        }
    }
}

module top() {
    union() {
        difference() {
            union() {
                difference() {
                    fullOuterCase();
                    union() {
                        innerShell();
                        translate([0, 0, -boxHeight * 0.5])
                            cube([boxWidth + 1, boxDepth + 1, boxHeight], center = true);
                        ratio = 0.45;
                        roundedBox(size = [ boxWidth - boxWallThickness * ratio * 2.0, boxDepth - boxWallThickness * ratio * 2.0, boxWallThickness], radius = boxRadius - (boxRadius - boxWallThickness) * ratio, sidesonly = true);
                        innerShell();
                    }
                }
            }
            union() {
                translate([0, boxDepth * 0.5 - 1, -boxHeight * 0.25])
                    rotate([90, 0, 0])
                        cube([connectorPlateWidth, boxHeight, boxWallThickness + boxRadius], center = true);
                // Pot hole
                translate([0, boxDepth * 0.1666 - 2.5, (boxHeight - boxWallThickness) * 0.5])
                    cylinder(h = boxWallThickness + 0.01, r = 3.75, center = true);
            }
        }
/*    
        snapFitClipAndLip();
        rotate([0, 0, 180])
            snapFitClipAndLip();
*/      
        intersection() {
            snapFitParts(top = true);
            outerShell();
        }
    }
}

module bottom() {
    rotate([0, 180, 0])
    difference() {
        union() {
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
                    ratio = 0.55;
                    roundedBox(size = [ boxWidth - boxWallThickness * ratio * 2.0, boxDepth - boxWallThickness * ratio * 2.0, boxWallThickness], radius = boxRadius - (boxRadius - boxWallThickness) * ratio, sidesonly = true);
                    fullOuterCase();
                }
            }
            intersection() {
                // Connector plate
                translate([0, boxDepth * 0.5 - boxWallThickness * 0.5, boxHeight * 0.25])
                    rotate([90, 0, 0])
                        cube([connectorPlateWidth, boxHeight, boxWallThickness + boxRadius], center = true);
                fullOuterCase();
            }
            intersection() {
                union() {
                    // Back supports (because my printer is rubbish)
                    translate([boxWidth * 0.5 - (boxWallThickness * 1.5), boxDepth * 0.5 - (boxWallThickness * 1.5), boxHeight * 0.125])
                        cube([boxWallThickness, boxWallThickness, boxHeight * 0.75], center = true);
                    translate([-boxWidth * 0.5 + (boxWallThickness * 1.5), boxDepth * 0.5 - (boxWallThickness * 1.5), boxHeight * 0.125])
                        cube([boxWallThickness, boxWallThickness, boxHeight * 0.75], center = true);
                    
                    // Snapfit additive part. TODO(PJQ) slope at top to guide clips in
                    for (a = [0 , 180]) {
                        rotate([0, 0, a]) {
                            translate([boxWidth * 0.5 - (boxWallThickness * 1.5), 0, boxHeight * 0.375])
                            //cube([boxWallThickness, snapFitLength - 1, boxHeight * 0.5], center = true);

                            rotate([90, 0, 0])
                                linear_extrude(height = snapFitLength - 1, center = true)
                                    polygon([
                                        [-boxWallThickness * 0.5, boxHeight * 0.25], 
                                        [ boxWallThickness * 0.5, boxHeight * 0.25], 
                                        [-boxWallThickness * 0.5, -boxHeight * 0.25], 
                                        [ boxWallThickness * 0.5, -boxHeight * 0.25 + boxWallThickness]
                                    ],
                                    [
                                        [0, 1, 2],
                                        [1, 2, 3]
                                    ]);
                        }
                    }
                }
                outerShell();
            }
        }
        // Phono hole
        translate([0, (boxDepth - boxWallThickness) * 0.5, 0])
            rotate([90, 0, 0])
                cylinder(r = 3.5, h = boxWallThickness + 0.01, center = true);
        rotate([0, 180, 0])
            snapFitParts(top = false);
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
translate([0, 0, 1])
color("red")
top();
translate([0, 0, -1])
color("blue")
bottom();
*/
