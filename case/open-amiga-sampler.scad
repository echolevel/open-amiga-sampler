//$fa = 1;
//$fs = 0.4;

use <MCAD/boxes.scad>

boxWidth = 54;
boxHeight = 25;
boxDepth = 65;
boxRadius = 4;
boxWallThickness = 2;
wedgeChunkiness = 3.0;
wedgeProtrusion = 3.5;
pcbThickness = 1.6;
pcbDistanceFromEdge = 4.6;
screwHoleRadius = 1.125;
screwHeadRadius = 2.0;

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
                    roundedBox(size = [42, 11.5, boxWallThickness + 1], radius = 1, sidesonly = true);
            
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

module top() {
    difference() {
        union() {
            difference() {
                fullOuterCase();
                union() {
                    translate([0, 0, -boxHeight * 0.5])
                        cube([boxWidth + 1, boxDepth + 1, boxHeight], center = true);
                    
                    translate([0, boxDepth * 0.5 - 1, 0])
                        rotate([90, 0, 0])
                            roundedBox(size = [ boxWidth - boxRadius * 3.0, boxHeight - boxRadius * 3.0, boxWallThickness + 2], radius = 4, sidesonly = true);
                }
            }
            
            intersection() {
                union() {
                     // Left screw lug
                    translate([-32.5 * 0.5, -boxDepth * 0.5 + pcbDistanceFromEdge + (34.0 - 2.5), boxHeight * 0.25 - pcbThickness * 0.5])
                        cylinder(h = boxHeight * 0.5, r = boxWallThickness + 0.6, center = true);   

                    // Right screw lug
                    translate([32.5 * 0.5, -boxDepth * 0.5 + pcbDistanceFromEdge + (34.0 - 2.5), boxHeight * 0.25 + pcbThickness * 0.5 /*+ boxWallThickness*/])
                        cylinder(h = boxHeight * 0.5, r = boxWallThickness + 0.6, center = true);            
                }
                innerShell();
            }
        }
        union() {
            // Screw holes
            translate([32.5 * 0.5, -boxDepth * 0.5 + pcbDistanceFromEdge + (34.0 - 2.5), 0])
                cylinder(h = boxHeight * 0.5, r = 0.6, center = true);            
            
            translate([-32.5 * 0.5, -boxDepth * 0.5 + pcbDistanceFromEdge + (34.0 - 2.5), 0])
                cylinder(h = boxHeight * 0.5, r = 0.6, center = true);   
        }
    }    
}

module bottom() {
    difference() {
        union() {
            intersection() {
                fullOuterCase();
                union() {
                    translate([0, 0, -(boxHeight + 1) * 0.5])
                        cube([boxWidth + 1, boxDepth + 1, boxHeight + 1], center = true);
                    
                    translate([0, boxDepth * 0.5 - 1, 0])
                        rotate([90, 0, 0])
                            roundedBox(size = [ boxWidth - boxRadius * 3.0, 
                                                boxHeight - boxRadius * 3.0, 
                                                boxWallThickness + 2],
                                                radius = 4, sidesonly = true);
                }
            } 
            intersection() {  
                union() {             
                    // Corner
                    translate([-boxWidth * 0.5 + boxWallThickness, -boxDepth * 0.5 + boxWallThickness, -boxHeight * 0.5])
                        cube([wedgeChunkiness, wedgeChunkiness, boxHeight * 0.5 + wedgeProtrusion]);
                    translate([boxWidth * 0.5 - (boxWallThickness + wedgeChunkiness), -boxDepth * 0.5 + boxWallThickness, -boxHeight * 0.5])
                        cube([wedgeChunkiness, wedgeChunkiness, boxHeight * 0.5 + wedgeProtrusion]);
                    
                    // More corner wedges
                    translate([-boxWidth * 0.5 + boxWallThickness, boxDepth * 0.5 - (boxWallThickness + wedgeChunkiness), -boxHeight * 0.5])
                        cube([wedgeChunkiness, wedgeChunkiness, boxHeight * 0.5 + wedgeProtrusion]);
                    translate([boxWidth * 0.5 - (boxWallThickness + wedgeChunkiness), boxDepth * 0.5 - (boxWallThickness + wedgeChunkiness), -boxHeight * 0.5])
                        cube([wedgeChunkiness, wedgeChunkiness, boxHeight * 0.5 + wedgeProtrusion]);
                    
                    // Left mounting post
                    translate([-32.5 * 0.5, -boxDepth * 0.5 + pcbDistanceFromEdge + (34.0 - 2.5), -boxHeight * 0.25 - pcbThickness * 0.5])
                        cylinder(h = (boxHeight - pcbThickness) * 0.5 + 1, r = screwHeadRadius + boxWallThickness, center = true);
                    
                    // Right mounting post
                    translate([32.5 * 0.5, -boxDepth * 0.5 + pcbDistanceFromEdge + (34.0 - 2.5), -boxHeight * 0.25 - pcbThickness * 0.5])
                        cylinder(h = (boxHeight - pcbThickness) * 0.5 + 1, r = screwHeadRadius + boxWallThickness, center = true);
                }
                innerShell();
            }
        }
    
        union() {
            // Screw holes
            translate([32.5 * 0.5, -boxDepth * 0.5 + pcbDistanceFromEdge + (34.0 - 2.5), 0])
                cylinder(h = boxHeight + 1, r = screwHoleRadius, center = true);
            translate([32.5 * 0.5, -boxDepth * 0.5 + pcbDistanceFromEdge + (34.0 - 2.5), -boxHeight * 0.25 - pcbThickness * 0.5 - boxWallThickness])
                cylinder(h = boxHeight * 0.5, r = screwHeadRadius, center = true);            
            
            translate([-32.5 * 0.5, -boxDepth * 0.5 + pcbDistanceFromEdge + (34.0 - 2.5), 0])
                cylinder(h = boxHeight + 1, r = screwHoleRadius, center = true);
            translate([-32.5 * 0.5, -boxDepth * 0.5 + pcbDistanceFromEdge + (34.0 - 2.5), -boxHeight * 0.25 - pcbThickness * 0.5 - boxWallThickness])
                cylinder(h = boxHeight * 0.5, r = screwHeadRadius, center = true);            

       }
    }
}

translate([-(boxWidth + 10), 0, 0])
    rotate([0, 180, 0])
        color("red")
        top();

translate([(boxWidth + 10), 0, 0])
    color("blue")
    bottom();

union() {
    color("white") top();
    color("white") bottom();
}

color("green") pcb();

