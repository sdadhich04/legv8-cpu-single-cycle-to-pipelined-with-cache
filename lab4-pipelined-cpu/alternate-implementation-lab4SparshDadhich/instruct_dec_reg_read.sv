`timescale 1ns/10ps
module instruct_dec_reg_read(
	input logic RegWrite,
	input logic RegWrite_r4,
	input logic MemtoReg_r4,
	input logic Reg2Loc, 
	input logic clk,
	input logic link_sel,
	input logic [1:0] ForwardA,
	input logic [1:0] ForwardB,
	input logic [63:0] alu_result,
	input logic [1:0]   extended_sel,
	input logic [31:0]  instruction,
	input logic [31:0]  instruction_out_r4,
	input logic [63:0]  DataMemory_mux,
	input logic [63:0]  alu_add4_result,
	input logic [63:0]  pc_instruc_out,
	output logic [63:0] ReadData1, 
	output logic [63:0] ReadData2,
	output logic [63:0] extended_instruct_out,
	output logic [4:0] ReadRegister2_out, 
	output logic [63:0] add_result,
	output logic [63:0] mux_forwardA_out,
	output logic [63:0] mux_forwardB_out);
	
	logic [4:0]  ReadRegister2;
	logic [4:0]  WriteRegister;
	logic [4:0]  branch_link;
	logic [63:0] WriteData;
	logic [63:0] extended_instruct;
	
	//The chosen instruction 4 through 0 from write back mux
	logic write_back_sel;
	logic [4:0] instruction_4to0;
	
	//Unused signals from adder alu
	logic negative_x, zero_x, overflow_x, carry_out_x;
	logic [63:0] mux_out;
	logic [63:0] shift_left2;
	
	//Register 30 for linking operation
	assign branch_link = 5'b11110;
	assign extended_instruct_out = extended_instruct;
	assign ReadRegister2_out = ReadRegister2;
	
	//Offset adder goes back to control mux
	alu adder_branch( pc_instruc_out, shift_left2, 3'b010, add_result, negative_x, zero_x, overflow_x, carry_out_x);
	
	// extended instruction shift left by 2
	shifter shift_module(extended_instruct, 1'b0, 6'b000010, shift_left2);
	
	
	//register logic
	regfile reg_file(ReadData1, ReadData2, WriteData, instruction[9:5], 
				ReadRegister2, WriteRegister, RegWrite, clk);
	
	// Select line for write back mux
	or #50 and1_and2(write_back_sel, MemtoReg_r4, RegWrite_r4);
					
	genvar mux_wb_i, mux_reg2_i, mux_wrReg_i, mux_wrData_i, forwardA_i, forwardB_i;
	
	generate
		
		//Mux for Reg2Loc operations
		for(mux_reg2_i=0; mux_reg2_i<5; mux_reg2_i++) begin : eachMuxReg2
			mux_2x1 mux2x1(Reg2Loc, {instruction[mux_reg2_i],instruction[16+mux_reg2_i]}, ReadRegister2[mux_reg2_i]);
		end
		
		// Mux for write back operations
		for(mux_wb_i=0; mux_wb_i<5; mux_wb_i++) begin : eachMuxwr_R4
			mux_2x1 mux2x1(write_back_sel, {instruction_out_r4[mux_wb_i], instruction[mux_wb_i]}, instruction_4to0[mux_wb_i]);
		end
		
		//Mux for linking branch operations
		for(mux_wrReg_i=0; mux_wrReg_i<5; mux_wrReg_i++) begin : eachMuxwrReg
			mux_2x1 mux2x1(link_sel, {branch_link[mux_wrReg_i], instruction_4to0[mux_wrReg_i]}, WriteRegister[mux_wrReg_i]);
		end
		
		//Mux for writing to linked operations
		for(mux_wrData_i=0; mux_wrData_i<64; mux_wrData_i++) begin : eachMuxwrData
			mux_2x1 mux2x1(link_sel, {alu_add4_result[mux_wrData_i], DataMemory_mux[mux_wrData_i]}, WriteData[mux_wrData_i]);
		end
		
		
		//Mux Forward A
		for(forwardA_i=0; forwardA_i<64; forwardA_i++) begin : eachForwardA
			mux_4x1 forwardA(ForwardA, {'x, DataMemory_mux[forwardA_i],alu_result[forwardA_i], ReadData1[forwardA_i]}, mux_forwardA_out[forwardA_i]);
		end
		
//		 mux4_64b FwdAMux (.sel(ForwardA), .A(RegDa), .B(ExALUOut), .C(WbMuxOut), .D(64'bx), .out(DecDa));
//		 mux4_64b FwdBMux (.sel(ForwardB), .A(RegDb), .B(ExALUOut), .C(WbMuxOut), .D(64'bx), .out(DecDb));
//	 
		
		//Mux Forward B
		//Mux that chooses between alusrc, alu_result_r3 and data_mux
		//Connected with the above alusrc mux
		for(forwardB_i=0; forwardB_i<64; forwardB_i++) begin : eachForwardB
			mux_4x1 forwardB(ForwardB, {'x, DataMemory_mux[forwardB_i], alu_result[forwardB_i], ReadData2[forwardB_i]}, mux_forwardB_out[forwardB_i]);
		end
	endgenerate
	
	//add sign_extend module of somesort might be possible to use math?
	// need max for the significant bit to change
	// Control signal will change parameter size
	// For extend immidate use 21 as max and array between 21:10
	// extend immidate 		    21 = max  10 = min
	// extend dt address 	    20 = max  12 = min
	// extend br address 	    25 = max   0 = min
	// extend cond br address   23 = max   5 = min
	// extend register will be undefined
	
	//Sign extendes internal and external logic
	sign_extension extend_sign(extended_sel, instruction, extended_instruct);

endmodule//instruct_dec_reg_read

module instruct_dec_reg_read_tb(); 		

	parameter ClockDelay = 5000;

	logic RegWrite, Reg2Loc, clk;
	logic [31:0] instruction;
	logic [63:0]WriteData_mux;
	logic [63:0] ReadData1, ReadData2, extended_instruct;

	instruct_dec_reg_read dut(RegWrite, Reg2Loc, WriteData_mux, instruction, 
									  ReadData1, ReadData2, extended_instruct, clk);

	// Force %t's to print in a nice format.
	initial $timeformat(-9, 2, " ns", 10);

	initial begin // Set up the clock
		clk <= 0;
		forever #(ClockDelay/2) clk <= ~clk;
	end

	initial begin
		RegWrite <=1; Reg2Loc<=0; instruction<=0; WriteData_mux<=2'b11; @(posedge clk);
		RegWrite <=0; Reg2Loc<=0; instruction<=32'hFFFFFF00; WriteData_mux<=0; @(posedge clk);
		@(posedge clk);
		$stop;
	end
endmodule //instruct_dec_reg_read_tb