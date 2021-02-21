# OPEN AMIGA SAMPLER

## Overview

Here you can find the schematic and a PCB layout for Open Amiga Sampler in KiCAD format. Additionally, the schematic is available as a PDF.

The design consists of an inverting opamp circuit with variable gain which feeds an ADC. The DB25's strobe pin is connected to the ADC and initiates a conversion when it goes low. The ADC's outputs are connected to the data pins of a DB25 connector, which also provides power and ground. 

## BOM

* 1x Maxim ADC0820CCM+ (SOIC-20 Package) - mouser P/N  700-ADC0820CCM
* 1x Microchip MCP6001UT-I/OT (SOT-23-5 package) - mouser P/N 579-MCP6001UT-I/OT (The U variant is important as it has a different pin layout to the 6001T in the same package)
* 1x DB25 plug connector
* 2x RCA receptacles
* 1x 0805 330ohm resistor 
* 5x 0805 1kohm resistors
* 1x 10kohm exponential potentimeter
* 1x 4x5.3mm 47uF electrolytic capacitor
* 2x 10uf Tantalum Case A or 1206 capacitors
* 2x 0805 0.1uf capacitors

### Substitutions

The Maxim ADC0820CCM+ is pin compatible with the TI part with the same part number and package. The Maxim part is preferred as it's a better spec but the TI part can easily be substituted as the Maxim is pin-compatible.

The 10kohm potentiometer will give between 1x and 10x gain. A larger potentiometer can be substituted to enable a large maxium gain. The RCA receptacles can be replaced by a stereo jack receptacle if preferred. It is likely that both ICs could be substituted for similar chips with identical pinouts, but these are the models that we have tested and confirmed to work.

The 47uF electrolytic can be substituted for a taller one up to 5.8mm if using a standard grey DB25 shell or taller if using a bigger (e.g. 3D printed) case 

## Soldering

All on board components are surface mount but nothing smaller than 0805 and should be relatively easy to solder even for someone with a good base level of soldering and a bit of practice. The MCP6001 is a SOT-23-5 with a ~1mm pitch and represents the smallest component on the board. the Pot and RCA receptacles can be soldered with wire leads from the through hole pads

## Case

This board is intended to fit inside a standard DB25 D-Sub shell. (a regular common grey one) but due to it's small size, a larger enclosure can also be used and a custom 3D printed one may get produced as well.
