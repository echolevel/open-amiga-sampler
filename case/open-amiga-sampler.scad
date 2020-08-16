$fa = 1;
$fs = 0.4;

use <MCAD/boxes.scad>

boxWidth = 30;
boxHeight = 21;
boxDepth = 30;
boxRadius = 4;
boxWallThickness = 2;
lipGap = 0.4;
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

module screwParts(top, subtract) {
    screwThreadRadius = 1.0;
    screwHeadRadius = 2.5;
    screwClearance = 0.4;
    
    translate([0, -5, 0]) {
        if (top == false) {
            if (subtract == false) {
                translate([0, 0, boxHeight * 0.5 - epsilon])
                    rotate([180, 0, 0])
                        cylinder(r = screwHeadRadius + boxWallThickness, screwHeadRadius - (screwThreadRadius - screwClearance));
                translate([0, 0, pcbThickness * 0.5 - epsilon])
                    cylinder(r = screwThreadRadius + screwClearance + boxWallThickness, h = (boxHeight - pcbThickness) * 0.5);
            }
            else {
                translate([0, 0, boxHeight * 0.5 + epsilon])
                    rotate([180, 0, 0]) {
                    // Countersink
                        cylinder(r1 = screwHeadRadius, r2 = screwThreadRadius + screwClearance, h = screwHeadRadius - (screwThreadRadius + screwClearance));
                        // Hole
                        cylinder(r = screwThreadRadius + screwClearance, h = boxHeight * 0.5);
                }
            }
        }
       
        if (top == true) {
            if (subtract == false) {
                translate([0, 0, pcbThickness * 0.5])
                    cylinder(r = screwThreadRadius + boxWallThickness, h = (boxHeight - pcbThickness) * 0.5 - boxWallThickness + epsilon);
            }
            else {
                translate([0, 0, pcbThickness * 0.5 - boxWallThickness * 2.0 + epsilon])
                    cylinder(r = screwThreadRadius - 0.125, h = (boxHeight - pcbThickness) * 0.5 - boxWallThickness);
            }
        }

    }
}

epsilon = 0.001;

module connectorPanel(top, subtract) {
    curveRadius = 1.25;

    if ((top == true && subtract == false) || (top == false && subtract == true)) {
        union() {
            // Inner
            size0 = (top ? (boxWallThickness - lipGap) : (boxWallThickness + lipGap));
            translate([0, boxDepth * 0.5 - boxWallThickness + size0 * 0.25, 0]) {
                rotate([90, 0, 0])
                    roundedBox(size = [
                            boxWidth - boxRadius * 2 - curveRadius * 2.0 - (top ? lipGap * 2.0 : 0),
                            boxHeight - boxRadius * 2 - (top ? lipGap * 2.0 : 0),
                            size0 * 0.5 + (subtract ? epsilon : 0)
                        ],
                        sidesonly = true,
                        radius = curveRadius - (top ? lipGap : 0));


                for (a = [0, 180])
                    rotate([(top ? 0 : 180), 0, a]) {
                        x = -boxWidth * 0.5 + boxRadius + (top ? lipGap : 0);
                        z = -(boxWallThickness * 0.5 - (top ? lipGap : 0));
                        if (top == true) {
                            difference() {
                                translate([ x + curveRadius * 0.5,
                                            0,
                                            z - curveRadius * 0.5])
                                    cube([curveRadius, size0 * 0.5 + epsilon, curveRadius + epsilon], center = true);
                                translate([x, 0, z - curveRadius])
                                    rotate([90, 0, 0])
                                        cylinder(r = curveRadius, h = size0 * 0.5 + 1.0, center = true);
                            }
                        } else
                        {
                            translate([ x + curveRadius * 0.5 + epsilon,
                                    0,
                                    z - curveRadius * 0.5])
                                cube([curveRadius, size0 * 0.5 + epsilon, curveRadius + epsilon], center = true);
                        }
                    }
            }
            
            // Outer
            size1 = (top ? (boxWallThickness + lipGap)  : (boxWallThickness - lipGap));
            translate([0, boxDepth * 0.5 - size1 * 0.25, 0]) {
                rotate([90, 0, 0])
                    roundedBox(size = [
                            boxWidth - boxRadius * 2 - boxWallThickness - curveRadius * 2.0 - (top ? lipGap : 0),
                            boxHeight - boxRadius * 2 - boxWallThickness - (top ? lipGap : 0),
                            size1 * 0.5 + (subtract ? epsilon : 0)
                        ],
                        sidesonly = true,
                        radius = curveRadius - boxWallThickness * 0.5);
                for (a = [0, 180])
                    rotate([(top ? 0 : 180), 0, a])
                        difference() {
                            x = -boxWidth * 0.5 + boxRadius + (top ? lipGap * 0.5 : 0);
                            translate([x + curveRadius + lipGap, 0, -curveRadius * 0.5])
                                cube([curveRadius, size1 * 0.5 + epsilon, curveRadius + epsilon], center = true);
                            translate([x + boxWallThickness * 0.5, 0, -curveRadius])
                                rotate([90, 0, 0])
                                    cylinder(r = curveRadius, h = size1 * 0.5 + 1.0, center = true);
                        }            
            }
        }
    }
    
    if (top == false && subtract == true) {
        // Lower
        translate([0, boxDepth * 0.5 - boxWallThickness + (boxWallThickness + lipGap) * 0.25 - epsilon * 0.5, boxHeight * 0.5 - boxRadius - curveRadius * 0.5])
            cube([boxWidth - (boxRadius + curveRadius) * 2, (boxWallThickness + lipGap) * 0.5 + epsilon, curveRadius], center = true);
        
        // Upper
        /*translate([0, boxDepth * 0.5 - boxWallThickness + (boxWallThickness + lipGap) * 0.25 - epsilon * 0.5, lipGap * 0.99 + curveRadius])
            cube([boxWidth - boxRadius * 2, (boxWallThickness + lipGap) * 0.5 + epsilon, curveRadius], center = true);*/
    }
    
    if (top == true && subtract == true) {
        // Phono hole
        translate([0, (boxDepth - boxWallThickness) * 0.5, 0])
            rotate([90, 0, 0])
                cylinder(r = 3.5, h = boxWallThickness + 0.01, center = true);
    }
}


module top() {
    difference() {
        union() {
            difference() {
                union() {
                    difference() {
                        fullOuterCase();
                        union() {
                            translate([0, 0, -boxHeight * 0.5])
                                cube([boxWidth + 1, boxDepth + 1, boxHeight], center = true);
                            innerShell();
                        }
                    }
                    intersection() {
                        translate([0, 0, lipGap])
                            roundedBox(size = [
                                    boxWidth - (boxWallThickness + lipGap),
                                    boxDepth - (boxWallThickness + lipGap),
                                    boxWallThickness
                                ],
                                radius = boxRadius * 0.5 + (boxWallThickness - lipGap) * 0.5,
                                sidesonly = true);
                        fullOuterCase();
                    }
                    screwParts(top = true, subtract = false);
                }
                union() {
                    // Pot hole
                    translate([0, boxDepth * 0.5 - boxRadius - 3.75 - 0.5, (boxHeight - boxWallThickness) * 0.5])
                        cylinder(h = boxWallThickness + 0.01, r = 3.75, center = true);
                        screwParts(top = true, subtract = true);
                }
            }
            intersection() {
                union() {
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
                                    boxWidth - (boxWallThickness - lipGap),
                                    boxDepth - (boxWallThickness - lipGap),
                                    boxWallThickness
                                ],
                                radius = boxRadius - (boxWallThickness - lipGap) * 0.5,
                                sidesonly = true);
                            innerShell();
                        }
                    }
                    screwParts(top = false, subtract = false);
                }
            }
            union() {
                connectorPanel(top = false, subtract = true);
                screwParts(top = false, subtract = true);
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




