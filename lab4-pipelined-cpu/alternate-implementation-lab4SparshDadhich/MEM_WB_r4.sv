module MEM_WB_r4(
	input logic enable,
	input logic link_sel_r3,
	input logic MemtoReg_r3,
	input logic RegWrite_r3,
	input logic [63:0] read_data_mem,
	input logic [63:0] alu_result_r3,
	input logic [31:0] instruction_out_r3,
	input logic reset,
	input logic clk,
	output logic link_sel_r4,
	output logic MemtoReg_r4,
	output logic RegWrite_r4,
	output logic [63:0] read_data_mem_r4,
	output logic [63:0] alu_result_r4,
	output logic [31:0] instruction_out_r4);
	
	D_FF_enabled link      (link_sel_r4, link_sel_r3, reset, clk, enable);
	D_FF_enabled memtoreg  (MemtoReg_r4, MemtoReg_r3, reset, clk, enable);
	D_FF_enabled regwrite  (RegWrite_r4, RegWrite_r3, reset, clk, enable);
	
	D_FF_64 readdatamem  (read_data_mem_r4, read_data_mem, reset, clk, enable);
	D_FF_64 aluresult  	(alu_result_r4, alu_result_r3, reset, clk, enable);
	D_FF_32 instruct   	(instruction_out_r4, instruction_out_r3, reset, clk, enable);
	
endmodule