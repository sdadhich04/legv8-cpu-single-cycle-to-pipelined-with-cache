`timescale 1ns/10ps
module sign_extension(sel, instruction, extended_instruct);

	input logic  [31:0] instruction;
	input logic  [1:0]  sel;
	output logic [63:0] extended_instruct;
	
	
	logic [63:0] extend_branch;
	logic [63:0] extend_cond_branch;
	//What to do with register 
	logic [63:0] extend_immediate;
	logic [63:0] extend_memory;
	
	// extend_branch       00	B  -Type
	// extend_cond_branch  01	CB -Type
	// register				  xx	R  -Type
	// extend_immediate    10	I  -Type
	// extend_memory       11	D  -Type
	assign extend_branch      = {{64{instruction[25]}}, instruction[25:0]};
	assign extend_cond_branch = {{64{instruction[23]}}, instruction[23:5]};
	// no register extension set it to x'
	assign extend_immediate   = {{64{instruction[21]}}, instruction[21:10]};
	assign extend_memory 	  = {{64{instruction[20]}}, instruction[20:12]};
	
	genvar mux_i;
	
	generate
		for(mux_i=0; mux_i<64; mux_i++) begin : eachMux
			mux_4x1 mux4x1(sel, {extend_memory[mux_i], extend_immediate[mux_i], 
										extend_cond_branch[mux_i], extend_branch[mux_i]}, 
										extended_instruct[mux_i]);
		end
	endgenerate

endmodule