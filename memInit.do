vlog -sv -work work "../../../../VivadoFPGA.srcs/sim_1/new/MemInit16.sv"
vsim -voptargs="+acc" -displaymsgmode both -msgmode both work.MemInit16
run 1ns