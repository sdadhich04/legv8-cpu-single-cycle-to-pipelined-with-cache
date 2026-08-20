module ID_EX_r2(
	input logic enable,
	input logic ALUSrc_r1,
	input logic [2:0] ALUOP_r1,
	input logic link_sel_r1,
	input logic MemRead_r1,
	input logic MemWrite_r1,
	input logic MemtoReg_r1,
	input logic RegWrite_r1,
	input logic [63:0] extended_instruct_out,
	input logic [63:0] ReadData1,
	input logic [63:0] ReadData2,
	input logic [31:0] instruction_out_r1,
	input logic [63:0] mux_forwardA_out,
	input logic [63:0] mux_forwardB_out,
	input logic reset,
	input logic clk,
	output logic ALUSrc_r2,
	output logic [2:0] ALUOP_r2,
	output logic link_sel_r2,
	output logic MemRead_r2,
	output logic MemWrite_r2,
	output logic MemtoReg_r2,
	output logic RegWrite_r2,
	output logic [63:0] extended_instruct_out_r2,
	output logic [63:0] ReadData1_r2,
	output logic [63:0] ReadData2_r2,
	output logic [31:0] instruction_out_r2,
	output logic [63:0] mux_forwardA_out_r2,
	output logic [63:0] mux_forwardB_out_r2);
	
	D_FF_enabled alusrc    (ALUSrc_r2,   ALUSrc_r1,   reset, clk, enable);
	D_FF_3       aluop     (ALUOP_r2,    ALUOP_r1,    reset, clk, enable);
	D_FF_enabled link	     (link_sel_r2, link_sel_r1, reset, clk, enable);
	D_FF_enabled memread   (MemRead_r2,  MemRead_r1,  reset, clk, enable);
	D_FF_enabled memwrite  (MemWrite_r2, MemWrite_r1, reset, clk, enable);
	D_FF_enabled memtoreg  (MemtoReg_r2, MemtoReg_r1, reset, clk, enable);
	D_FF_enabled regwrite  (RegWrite_r2, RegWrite_r1, reset, clk, enable);

	D_FF_64 extended  (extended_instruct_out_r2, extended_instruct_out, reset, clk, enable);
	D_FF_64 readdata1 (ReadData1_r2, ReadData1, reset, clk, enable);
	D_FF_64 readdata2 (ReadData2_r2, ReadData2, reset, clk, enable);
	D_FF_32 instruct  (instruction_out_r2, instruction_out_r1, reset, clk, enable);
	D_FF_64 forwardA  (mux_forwardA_out_r2, mux_forwardA_out, reset, clk, enable);
	D_FF_64 forwardB  (mux_forwardB_out_r2, mux_forwardB_out, reset, clk, enable);
endmodule