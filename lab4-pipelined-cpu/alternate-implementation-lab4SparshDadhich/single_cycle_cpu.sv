`timescale 1ns/10ps
module single_cycle_cpu(clk, reset);
	
	input logic clk, reset;
	//	input logic Reg2Loc, Uncondbranch, Branch;
	//	input logic MemRead, MemtoReg, MemWrite, ALUSrc, RegWrite;
	//	input logic [2:0] ALUOP;
	
	// This input is to only use for testbenching cant use for anything else
	//fix this once the control unit is setup
	//input logic [1:0] sel;
	//mux sequence operation
	//  sel   output
	//  000 	 B
	//  010 	 A + B
	//  011 	 A - B
	//  100 	 A and B
	//  101 	 A or B
	//  110 	 A xor B
	
	logic control_offset_sel, control_offset_sel_delay;
	logic branch_reg_sel;
	logic [63:0] DataMemory_mux;
	logic [63:0] pc_instruc_out, pc_instruc_out_r1;
	logic [63:0] alu_add4_result, alu_add4_result_r1;
	logic [31:0] instruction_out, instruction_out_r1; 
	logic [31:0] instruction_out_r2, instruction_out_r3;
	logic [31:0] instruction_out_r4;
	logic [63:0] ReadData1, ReadData2, ReadData1_r2, ReadData2_r2;
	logic [63:0] extended_instruct_out, extended_instruct_out_r2;
	logic [63:0] add_result, alu_result;
	logic [63:0] alu_result_r3, alu_result_r4;
	logic zero, negative, overflow, carry_out;
	logic zero_h, negative_h, overflow_h, carry_out_h;
	logic hold_flags;
	logic	[63:0] read_data_mem, read_data_mem_r4;
	
   logic Reg2Loc, Reg2Loc_r1; 
	//Uncondbranch, Branch;
	logic MemRead, MemtoReg, MemWrite, ALUSrc, RegWrite;
	logic MemRead_r1, MemtoReg_r1, MemWrite_r1, ALUSrc_r1, RegWrite_r1;
	logic MemRead_r2, MemtoReg_r2, MemWrite_r2, ALUSrc_r2, RegWrite_r2;
	logic MemRead_r3, MemtoReg_r3, MemWrite_r3, RegWrite_r3;
	logic MemtoReg_r4, RegWrite_r4;
	logic [4:0]ReadRegister2_out;
	logic [2:0] ALUOP, ALUOP_r1, ALUOP_r2;
	logic NOOP;
	logic [1:0] extended_sel, extended_sel_r1;
	logic link_sel, link_sel_r1, link_sel_r2, link_sel_r3, link_sel_r4;
	
	logic [63:0] mux_alusrc_out, mux_alusrc_out_r3;
	logic [1:0] ForwardA, ForwardB;
	logic [63:0] mux_forwardA_out, mux_forwardB_out;
	logic [63:0] mux_forwardA_out_r2, mux_forwardB_out_r2;
	logic [63:0] mux_forwardB_out_r3;

	
	//logic enable_r1;
	//logic enable_r2;
	//logic enable_r3;
	//logic enable_r4;
	assign enable = 1'b1;
	
	///////////////////////////////////ENABLE SIGNAL DOES NOT EXIST//////
	/////////////////////////////////////////////////////////////////////
	//	input logic enable,
	//	input logic MemtoReg_r3,
	//	input logic RegWrite_r3,
	//	input logic [63:0] read_data_mem,
	//	input logic [63:0] alu_result_r3,
	//	input logic [31:0] instruction_out_r3,
	//	input logic reset,
	//	input logic clk,
	//	output logic MemtoReg_r4,
	//	output logic RegWrite_r4,
	//	output logic [63:0] read_data_mem_r4,
	//	output logic [63:0] alu_result_r4,
	//	output logic [31:0] instruction_out_r4		
	
				
	control cntrl(instruction_out_r1, negative_h, overflow_h, zero_h, zero, Reg2Loc, MemRead,
				MemtoReg, ALUOP, MemWrite, ALUSrc,RegWrite, extended_sel, link_sel, branch_reg_sel, 
				NOOP, control_offset_sel, hold_flags);
	
	//input logic control_offset_sel, branch_reg_sel, clk, reset;
	//input logic  [63:0] alu_offset_out; = add_result
	//input logic  [63:0] ReadData2;
	//output logic [31:0] instruction_out;
	//output logic [63:0] pc_instruc_out;
	//output logic [63:0] alu_add4_result;
	// A delayed version of branch_reg_sel was added
	//D_FF_enabled control_mux(control_offset_sel_delay, control_offset_sel, reset, clk, enable);
	instruc_fetch cpu_fetch(control_offset_sel, branch_reg_sel, add_result, ReadData2, instruction_out, 
									pc_instruc_out, alu_add4_result, clk, reset);
	
	///////////////////////////////////ENABLE SIGNAL DOES NOT EXIST//////
	/////////////////////////////////////////////////////////////////////
	//module IF_ID_r1(
	//input logic enable,
	//input logic [63:0] alu_add4_result,
	//input logic [63:0] pc_instruc_out,
	//input logic [31:0] instruction_out,
	//input logic reset,
	//input logic clk,
	//output logic [63:0] alu_add4_result_r1,
	//output logic [63:0] pc_instruc_out_r1,
	//output logic [31:0] instruction_out_r1);	
	
	IF_ID_r1 R1( enable, alu_add4_result, pc_instruc_out, instruction_out,
					 reset, clk, alu_add4_result_r1, pc_instruc_out_r1, 
					 instruction_out_r1);
	
	//	input logic RegWrite,
	//	input logic RegWrite_r4,
	//	input logic MemtoReg_r4,
	//	input logic Reg2Loc, 
	//	input logic clk,
	//	input logic link_sel,
	//	input logic [1:0] ForwardA,
	//	input logic [1:0] ForwardB,
	//	input logic [63:0] alu_result,
	//	input logic [1:0]   extended_sel,
	//	input logic [31:0]  instruction,
	//	input logic [31:0]  instruction_out_r4,
	//	input logic [63:0]  DataMemory_mux,
	//	input logic [63:0]  alu_add4_result,
	//	input logic [63:0]  pc_instruc_out,
	//	output logic [63:0] ReadData1, 
	//	output logic [63:0] ReadData2,
	//	output logic [63:0] extended_instruct_out,
	//	output logic [4:0] ReadRegister2_out, 
	//	output logic [63:0] add_result,
	//	output logic [63:0] mux_forwardA_out,
	//	output logic [63:0] mux_forwardB_out
	
//	input logic [31:0] instruction_out_r1, 
//							input logic [31:0]instruction_out_r2, 
//							input logic[31:0]instruction_out_r3,
//							input logic [4:0] ReadRegister2_out,//DecAb
//							input logic ID_EX_r2_RegWrite, //ExRegWrite
//							input logic EX_MEM_r3_RegWrite,//MemRegWrite
//							output logic[1:0] ForwardA,
//							output logic[1:0] ForwardB
	
	forwarding_unit forward(.instruction_out_r1, .instruction_out_r2, 
									.instruction_out_r3, .ReadRegister2_out, .ID_EX_r2_RegWrite(RegWrite_r2),
									.EX_MEM_r3_RegWrite(RegWrite_r3), .ForwardA, .ForwardB);	

	instruct_dec_reg_read cpu_dec_read(RegWrite_r4, RegWrite_r4, MemtoReg_r4, Reg2Loc, clk, link_sel, ForwardA, ForwardB, alu_result,
												  extended_sel, instruction_out_r1, instruction_out_r4, DataMemory_mux, 
												  alu_add4_result_r1, pc_instruc_out_r1, ReadData1, ReadData2, 
												  extended_instruct_out, ReadRegister2_out, add_result, mux_forwardA_out, mux_forwardB_out);
	
	///////////////////////////////////ENABLE SIGNAL DOES NOT EXIST//////
	/////////////////////////////////////////////////////////////////////
	//	input logic enable,
	//	input logic ALUSrc_r1,
	//	input logic [2:0] ALUOP_r1,
	//	input logic link_sel_r1,
	//	input logic MemRead_r1,
	//	input logic MemWrite_r1,
	//	input logic MemtoReg_r1,
	//	input logic RegWrite_r1,
	//	input logic [63:0] extended_instruct_out,
	//	input logic [63:0] ReadData1,
	//	input logic [63:0] ReadData2,
	//	input logic [31:0] instruction_out_r1,
	//	input logic [63:0] mux_forwardA_out,
	//	input logic [63:0] mux_forwardB_out,
	//	input logic reset,
	//	input logic clk,
	//	output logic ALUSrc_r2,
	//	output logic [2:0] ALUOP_r2,
	//	output logic link_sel_r2,
	//	output logic MemRead_r2,
	//	output logic MemWrite_r2,
	//	output logic MemtoReg_r2,
	//	output logic RegWrite_r2,
	//	output logic [63:0] extended_instruct_out_r2,
	//	output logic [63:0] ReadData1_r2,
	//	output logic [63:0] ReadData2_r2,
	//	output logic [31:0] instruction_out_r2,
	//	output logic [63:0] mux_forwardA_out_r2,
	//	output logic [63:0] mux_forwardB_out_r2
	
	ID_EX_r2 R2(enable, ALUSrc, ALUOP, link_sel, MemRead, MemWrite, MemtoReg,
					RegWrite, extended_instruct_out, ReadData1, ReadData2,
					instruction_out_r1, mux_forwardA_out, mux_forwardB_out, reset, clk, ALUSrc_r2, ALUOP_r2, link_sel_r2, MemRead_r2,
					MemWrite_r2, MemtoReg_r2, RegWrite_r2, extended_instruct_out_r2, 
					ReadData1_r2, ReadData2_r2, instruction_out_r2, mux_forwardA_out_r2, mux_forwardB_out_r2); 
					
	//	input logic ALUSrc,
	//	input logic [2:0] ALUOP,
	//	input logic [63:0] DataMemory_mux,
	//	input logic [63:0] ReadData1, 
	//	input logic [63:0] ReadData2, 
	//	input logic [63:0] extended_instruct_out,
	//	input logic [63:0] mux_forwardA_out_r2,
	//	input logic [63:0] mux_forwardB_out_r2,
	//	output logic [63:0] alu_result,
	//	output logic [63:0] mux_alusrc_out,
	//	output logic zero, 
	//	output logic overflow, 
	//	output logic negative, 
	//	output logic carry_out
	execute_addr_calc cpu_execute(ALUSrc_r2, ALUOP_r2, DataMemory_mux, 
											ReadData1_r2, ReadData2_r2, extended_instruct_out_r2, 
											mux_forwardA_out_r2, mux_forwardB_out_r2, 
											alu_result, mux_alusrc_out,
											zero, overflow, negative, carry_out);
	
	//Keeps flags on for multiple cycle operations such as ADDS, SUBS and B.LT
	D_FF_4 flags ({zero_h, negative_h, overflow_h, carry_out_h}, 
					  {zero, negative, overflow, carry_out}, reset, clk, hold_flags);
				  		  
				  
	
	
	///////////////////////////////////ENABLE SIGNAL DOES NOT EXIST//////
	/////////////////////////////////////////////////////////////////////
	//	input logic enable,
	//	input logic  link_sel_r2,
	//	input logic MemRead_r2,
	//	input logic MemWrite_r2,
	//	input logic MemtoReg_r2,
	//	input logic RegWrite_r2,
	//	input logic [63:0] alu_result,
	//	input logic [63:0] mux_alusrc_out,
	//	input logic [63:0] mux_forwardB_out_r2,
	//	input logic [31:0] instruction_out_r2,
	//	input logic reset,
	//	input logic clk,
	//	output logic link_sel_r3,
	//	output logic MemRead_r3,
	//	output logic MemWrite_r3,
	//	output logic MemtoReg_r3,
	//	output logic RegWrite_r3,
	//	output logic [63:0] alu_result_r3,
	//	output logic [63:0] mux_alusrc_out_r3
	//	output logic [63:0] mux_forwardB_out_r3,
	//	output logic [31:0] instruction_out_r3
	EX_MEM_r3 R3(enable, link_sel_r2, MemRead_r2, MemWrite_r2, 
					 MemtoReg_r2, RegWrite_r2, alu_result, mux_alusrc_out,
					 mux_forwardB_out_r2, instruction_out_r2, reset, clk,
					 link_sel_r3, MemRead_r3, MemWrite_r3, MemtoReg_r3, 
					 RegWrite_r3, alu_result_r3, mux_alusrc_out_r3, 
					 mux_forwardB_out_r3, instruction_out_r3);
	
	
	// xfer_size forced to 8
	datamem cpu_mem( alu_result_r3, MemWrite_r3, MemRead_r3, mux_forwardB_out_r3, 
						  clk, 4'b1000, read_data_mem);
	
	///////////////////////////////////ENABLE SIGNAL DOES NOT EXIST//////
	/////////////////////////////////////////////////////////////////////
	//	input logic enable,
	// input logic link_sel_r3,
	//	input logic MemtoReg_r3,
	//	input logic RegWrite_r3,
	//	input logic [63:0] read_data_mem,
	//	input logic [63:0] alu_result_r3,
	//	input logic [31:0] instruction_out_r3,
	//	input logic reset,
	//	input logic clk,
	// output logic link_sel_r4,
	//	output logic MemtoReg_r4,
	//	output logic RegWrite_r4,
	//	output logic [63:0] read_data_mem_r4,
	//	output logic [63:0] alu_result_r4,
	//	output logic [31:0] instruction_out_r4					  
						  
	MEM_WB_r4 R4(enable, link_sel_r3, MemtoReg_r3, RegWrite_r3, read_data_mem, alu_result_r3,
				 instruction_out_r3, reset, clk, link_sel_r4, MemtoReg_r4, RegWrite_r4, 
				 read_data_mem_r4, alu_result_r4, instruction_out_r4);
	
	genvar mux_i;
	
	// Mux for data memory 
	generate
		for(mux_i=0; mux_i<64; mux_i++) begin : eachMux
			mux_2x1 mux2x1(MemtoReg_r4, {read_data_mem_r4[mux_i], alu_result_r4[mux_i]}, DataMemory_mux[mux_i]);
		end
	endgenerate

endmodule//single_cycle_cpu


module single_cycle_cpu_tb(); 		

	parameter ClockDelay = 150000;
	
	logic clk, reset;

	single_cycle_cpu dut(clk, reset);

	// Force %t's to print in a nice format.
	initial $timeformat(-9, 2, " ns", 10);

	initial begin // Set up the clock
		clk <= 0;
		forever #(ClockDelay/2) clk <= ~clk;
	end
	
	// extend_branch       00
	// extend_cond_branch  01
	// register				  xx
	// extend_immediate    10
	// extend_memory       11

	initial begin
		reset<=1; @(posedge clk);
		reset<=0; @(posedge clk);
		repeat(30)@(posedge clk);
 		$stop;
	end


endmodule