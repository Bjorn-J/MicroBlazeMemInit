//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:		B. Jansson
//
// Create Date:      04/27/2020
// Design Name:
// Module Name:      MemInit16
// Project Name:     VivadoFPGA
// Target Devices:   Xilinx RAMB36E1 IP, block memory
// Tool Versions:    ModelSim DE-2019.3
// Description:      Read MEM file, generate defparam .INIT_XX statements for include file to initialize 2-bit memories
//
// Dependencies:	None
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//
//////////////////////////////////////////////////////////////////////////////////

module MemInit16 #( parameter
	MEM_SIZE = 64,				// Kbytes
	NUM_MEM = 16,				// Memory devices
	IN_FILE = "bd_c1ed_lmb_bram_I_0.mem",
	OUT_FILE = "memInit.vh" );	// Include file for test bench
	
	`define INITSTR "defparam uut.cpu.microblaze_mcs_0.inst.lmb_bram_I.U0.inst_blk_mem_gen.\\\\gnbram.gnative_mem_map_bmg.native_mem_map_blk_mem_gen .\\\\valid.cstr .\\\\ramloop[%1d].ram.r .\\\\prim_noinit.ram .\\\\DEVICE_7SERIES.WITH_BMM_INFO.TRUE_DP.SIMPLE_PRIM36.TDP_SP36_NO_ECC_ATTR.ram .INIT_%s = 256'h%h;"
	localparam taddr = MEM_SIZE*256-1;	// Terminal physical word-address
	localparam width = 32/NUM_MEM;		// Number of bits per word stored in each memory device
	localparam bppi = 256/width;			// Bit pairs (groups) per INIT_XX

	integer outfile, lasta, lastinit;
	reg [31:0] mem[0:taddr];				// Local temporary memory
	reg [255:0] temp;					// Because .INIT_XX = 256'h...
	string inum = "00";					// Formatted number (XX) for .INIT_XX

	initial begin
		$readmemh( IN_FILE, mem );		// Initialize local memory from file
		// Identify last initialized memory location
		for( lasta = taddr; lasta>=0; lasta-- )
			if( mem[lasta] !== 32'hxxxxxxxx ) break;
		lastinit = lasta/bppi;			// Highest number INIT_XX needed
		$display( "last initialized word address: %h (%1d), last INIT_XX: 'h%2h", lasta, lasta, lastinit );
		if( lasta >= 0 ) begin
			// Wipe out 'X' bits in INIT_XX blocks, e.g. xxxxxX000000000000000000000ff00003800004000454000000000000000000
			for( integer i=0; i<bppi*(lastinit+1); i++ )
				if( mem[i] === 32'hxxxxxxxx )
					mem[i] = 32'h0;

			outfile = $fopen( OUT_FILE );							// Write include file at OUT_FILE
			for( integer i=0; i<=lastinit; i++ )					// For each INIT_ii statement...
				for( integer m=0; m<NUM_MEM; m++ ) begin			// For each memory device...
					for( integer bp=0; bp<bppi; bp++ )				// Fill one INIT_XX statement with bit pairs
						temp[width*bp+:width] = mem[bppi*i+bp][width*m+:width];
					$swrite( inum, "%2H", i );					// Can generate 0a
					inum = inum.toupper();						// Convert to 0A
					$fdisplay( outfile, `INITSTR, m, inum, temp );	// Write init string
				end
			$display( "Last init string: %h", temp );
			$fclose( outfile );
		end else
			$display( "No initialization performed." );
	end

endmodule
