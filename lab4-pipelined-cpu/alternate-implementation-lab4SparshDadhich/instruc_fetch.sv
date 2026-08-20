`timescale 1ns/10ps
module instruc_fetch(control_offset_sel, branch_reg_sel, alu_offset_out, ReadData2, instruction_out, 
							pc_instruc_out, alu_add4_result, clk, reset);
	
	input logic control_offset_sel, branch_reg_sel, clk, reset;
	input logic  [63:0] alu_offset_out;
	input logic  [63:0] ReadData2;
	output logic [31:0] instruction_out;
	output logic [63:0] pc_instruc_out;
	output logic [63:0] alu_add4_result;
	//alu logic sequence operation
	//  cntrl
	//  sel   output
	//  000 	 B
	//  010 	 A + B
	//  011 	 A - B
	//  100 	 A and B
	//  101 	 A or B
	//  110 	 A xor B
	
	//alu that only does PC = PC + 4
	logic [63:0] alu_add_4_out;
	//Unused values
	logic negative;
	logic zero;
	logic overflow;
	logic carry_out;
	
	//mux_2x1 64-bits
	logic [63:0] mux_add4_alu_result;
	logic [63:0] mux_out_pc;
	logic [63:0] pc_out;
	assign pc_instruc_out = pc_out;
	assign alu_add4_result = alu_add_4_out;
	
	//logic reset;
	
	// generate a 64- bit 2:1 mux
	
	
	
	
	
	genvar mux_i;
	generate
	
		// Mux for +4 and ALU result operations for offset decisions
		for(mux_i=0; mux_i<64; mux_i++) begin : eachMuxADD_ALU
			mux_2x1 mux2x1(control_offset_sel, {alu_offset_out[mux_i], alu_add_4_out[mux_i]}, mux_add4_alu_result[mux_i]);
		end
		
		// Mux for branch register signal
		for(mux_i=0; mux_i<64; mux_i++) begin : eachMuxBR
			mux_2x1 mux2x1(branch_reg_sel, {ReadData2[mux_i], mux_add4_alu_result[mux_i]}, mux_out_pc[mux_i]);
		end
	endgenerate
	
	// 64-bit flip flops that acts as storage for PC operations
	
	
	D_FF_64 PC(pc_out, mux_out_pc, reset, clk, 1'b1);
	
	// Only does +4 operations for PC = PC + 4
	// 3'b010 control forces it to be addition always
	alu alu_add_4(64'b100, pc_out, 3'b010, alu_add_4_out, negative, zero, overflow, carry_out);
	instructmem instruct_pc(pc_out, instruction_out, clk);
	
endmodule// instruc_fetch

module instruct_fetch_tb(); 		

	parameter ClockDelay = 5000;

	logic control_mux, clk, reset;
	logic [63:0] alu_offset_out;
	logic [31:0] instruction_out;
	logic [63:0] pc_instruc_out;

	instruc_fetch dut (control_mux, alu_offset_out, instruction_out, pc_instruc_out, clk, reset);

	// Force %t's to print in a nice format.
	initial $timeformat(-9, 2, " ns", 10);

	initial begin // Set up the clock
		clk <= 0;
		forever #(ClockDelay/2) clk <= ~clk;
	end

	initial begin
		reset<= 1; control_mux <= 0;alu_offset_out<=0;@(posedge clk);
		reset<= 0; control_mux <= 0;alu_offset_out<=1;@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		$stop;
	end
endmodule