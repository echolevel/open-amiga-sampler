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

lipRatio = 0.45;

snapFitLength = 10;
snapFitHeight = 3.0;
snapFitY = -4;
snapFitTolerance = 0.5;

module snapFitParts(top, subtract) {
    if (top == false && subtract == true) {
        cube([boxWidth - boxWallThickness * 2.0 * lipRatio, snapFitLength + snapFitTolerance * 2, -snapFitY * 2.0], center = true);
        translate([0, 0, snapFitY])
            cube([boxWidth + 0.001, snapFitLength + snapFitTolerance * 2, snapFitHeight + snapFitTolerance * 2], center = true);
    }
    
    if (top == true && subtract == true) {
        translate([0, 0, -boxWallThickness * 0.25])
            cube([boxWidth + 0.001, snapFitLength + snapFitTolerance * 2, boxWallThickness * 0.5 + 0.001], center = true);
    }
    
    if (top == true && subtract == false) {
        for (a = [0, 180]) {
            rotate([0, 0, a])
                translate([-boxWidth * 0.5 + boxWallThickness * 1.5, 0, 0])
                    rotate([90, 0, 0])
                        linear_extrude(height = snapFitLength, center = true)
                            polygon([
                                [-boxWallThickness * 0.5, boxHeight * 0.5], 
                                [ boxWallThickness * 0.5, boxHeight * 0.5], 
                                [-boxWallThickness * 1.5, snapFitY + snapFitHeight * 0.5], 
                                [-boxWallThickness * 0.5, snapFitY + snapFitHeight * 0.5], 
                                [ boxWallThickness * 0.5, snapFitY + snapFitHeight * 0.5], 
                                [-boxWallThickness * 1.5, snapFitY - snapFitHeight * 0.5 + boxWallThickness], 
                                [-boxWallThickness * 0.5, snapFitY - snapFitHeight * 0.5], 
                                [ boxWallThickness * 0.5, snapFitY - snapFitHeight * 0.5]
                            ],
                            [
                                [0, 1, 4],
                                [0, 4, 3],
                                [2, 3, 5],
                                [5, 3, 6],
                                [6, 3, 7],
                                [7, 3, 4]
                            ]);
           
        }
    }
}

module connectorPanel(top, subtract) {
    panelShrink = (top ? 0.5 : 0.0);
    
    if ((top == true && subtract == false) || (top == false && subtract == true)) {
        union() {
            // Panel
            translate([0, boxDepth * 0.5 - boxWallThickness * (0.5 + (top ? (1 - lipRatio) : lipRatio) * 0.5), 0])
                rotate([90, 0, 0])
                    roundedBox(size = [
                            boxWidth - boxRadius * 2 - panelShrink,
                            boxHeight - boxRadius * 2 - panelShrink,
                            boxWallThickness * (top ? lipRatio : (1 - lipRatio)) + (subtract ? 0.001 : 0)
                        ],
                        sidesonly = true, radius = 2.0);
            translate([0, boxDepth * 0.5 - boxWallThickness * (top ? (1 - lipRatio) : lipRatio) * 0.5, 0])
                rotate([90, 0, 0])
                    roundedBox(size = [
                            boxWidth - boxRadius * 2 - boxWallThickness - panelShrink,
                            boxHeight - boxRadius * 2 - boxWallThickness - panelShrink,
                            boxWallThickness * (top ? (1 - lipRatio) : lipRatio) + (subtract ? 0.001 : 0)
                        ],
                        sidesonly = true, radius = 1.0);
        }
    }
    
    if (top == true && subtract == true) {
        // Phono hole
        translate([0, (boxDepth - boxWallThickness) * 0.5, 0])
            rotate([90, 0, 0])
                cylinder(r = 3.5, h = boxWallThickness + 0.01, center = true);
    }
}

topLipDrop = 0.25; // Compensation for height inaccuracy where 2 parts meet

module top() {
    difference() {
        union() {
            difference() {
                union() {
                    difference() {
                        fullOuterCase();
                        union() {
                            translate([0, 0, -boxHeight * 0.5 + topLipDrop])
                                cube([boxWidth + 1, boxDepth + 1, boxHeight], center = true);
                            innerShell();
                        }
                    }
                    intersection() {
                        translate([0, 0, topLipDrop])
                            roundedBox(size = [ boxWidth - boxWallThickness * (1 - lipRatio) * 2.0, boxDepth - boxWallThickness * (1 - lipRatio) * 2.0, boxWallThickness], radius = boxRadius - (boxRadius - boxWallThickness) * (1 - lipRatio), sidesonly = true);
                        fullOuterCase();
                    }
                }
                union() {
                    // Pot hole
                    translate([0, boxDepth * 0.1666 - 2.5, (boxHeight - boxWallThickness) * 0.5])
                        cylinder(h = boxWallThickness + 0.01, r = 3.75, center = true);
                    snapFitParts(top = true, subtract = true);
                }
            }
            intersection() {
                union() {
                    snapFitParts(top = true, subtract = false);
                    connectorPanel(top = true, subtract = false);
                }
                outerShell();
            }
        }
        connectorPanel(top = true, subtract = true);
    }
}

module bottom() {
    rotate([0, 180, 0])
    union() {
        difference() {
            union() {
                union() {
                    difference() {
                        fullOuterCase();
                        union() {
                            translate([0, 0, -(boxHeight + 1) * 0.5])
                                cube([boxWidth + 1, boxDepth + 1, boxHeight + 1], center = true);
                            roundedBox(size = [
                                    boxWidth - boxWallThickness * lipRatio * 2.0,
                                    boxDepth - boxWallThickness * lipRatio * 2.0,
                                    boxWallThickness
                                ],
                                radius = boxRadius - (boxRadius - boxWallThickness) * lipRatio, sidesonly = true);
                            innerShell();
                        }
                    }
                }
            }
            union() {
                connectorPanel(top = false, subtract = true);
                rotate([0, 180, 0])
                    snapFitParts(top = false, subtract = true);
            }
        }
    }
}

if (true) {
    translate([-(boxWidth * 0.5 + 2), 0, 0])
        rotate([0, 180, 0])
            color("red")
            top();

    translate([(boxWidth * 0.5 + 2), 0, 0])
        color("blue")
        bottom();
}
else {
    translate([0, 0, 0])
    color("red")
    top();
    translate([0, 0, 0])
    color("blue")
    bottom();
}

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




