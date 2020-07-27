# OPEN AMIGA SAMPLER

## Overview

Here you can find the schematic and a PCB layout for Open Amiga Sampler in KiCAD format. Additionally, the schematic is available as a PDF.
The design consists of an inverting opamp circuit with variable gain which feeds an ADC. The DB25's strobe pin is connected to the ADC and initiates a conversion when it goes low. The ADC's outputs are connected to the data pins of a DB25 connector, which also provides power and ground. 

## BOM

* 1x Maxim ADC0820CCN+
* 1x Microchip MCP6002-I/P
* 1x DB25 plug connector
* 2x RCA receptacles
* 1x 330ohm resistor
* 5x 1kohm resistors
* 1x 10kohm exponential potentimeter
* 1x 47uf capacitor
* 2x 10uf capacitors
* 2x 0.1uf capacitors

### Substitutions

The 10kohm potentiometer will give between 1x and 10x gain. A larger potentiometer can be substituted to enable a large maxium gain. The RCA receptacles can be replaced by a stereo jack receptacle if preferred. It is likely that both ICs could be substituted for similar chips with identical pinouts, but these are the models that we have tested and confirmed to work.

## Soldering

All components are through-hole and should be relatively easy to solder even for a novice. Some components can be soldered to the back of the board and folded down to make the overall unit slimmer. One possible configuration is to solder C1, C2, C3 and C5 to the back of the board, and fold C4 down onto the front footprint of C3. We recommend soldering the DB25 connector first, followed by the passive components and leads, and finally the ICs. This reduces the chance of damaging the ICs with excessive heat.

## Case

We are working on a compact 3D printed case in an approriate form factor for all Amiga computers. You may be able to find an appropriate enclosure to build the device into, but if you intend to plug the device directly into your Amiga you will need to make sure that ports adjacent to the parallel port will not be impeded.
