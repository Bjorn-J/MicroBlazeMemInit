# MicroBlazeMemInit
Simulation memory initialization for MicroBlaze processor

Xilinx Vivado 19.1 does not initialize the MicroBlaze MCS memory for behavioral simulation. MemInit16.sv creates an include file for the test bench which contains the initialization constants.

Procedure to use:
1. Compile firmware code in Xilinx SDK, based on hardware design exported from Vivado
2. In Vivado, start a behavioral simulation. This creates a fresh MEM file in the simulation directory.
3. When the simulation has loaded in ModelSIm, compile and run MemInit16.sv. This generates an include file memInit.vh for the test bench.
4. Recompile and restart the simulation, preferrable with your own DO script in ModelSim. This time the include file has been updated for the test bench.

MemInit16.sv was developped for 64K byte RAM, which in this case is implemented as 16 2-bit block memories RAMB36E1. Parameters can be changed to accomodate other configurations.

The initialization constants are implemented using defparam statements. INITSTR will need to be modified for other configurations, and should be verified by expanding the instance tree in ModelSim.

In your test bench, where you would normally place defparam statements, add the line `include "memInit.vh"` (with back-tick).
