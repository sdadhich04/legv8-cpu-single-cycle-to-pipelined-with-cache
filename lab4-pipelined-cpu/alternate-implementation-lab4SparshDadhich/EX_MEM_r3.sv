module EX_MEM_r3(
	input logic enable,
	input logic  link_sel_r2,
	input logic MemRead_r2,
	input logic MemWrite_r2,
	input logic MemtoReg_r2,
	input logic RegWrite_r2,
	input logic [63:0] alu_result,
	input logic [63:0] mux_alusrc_out,
	input logic [63:0] mux_forwardB_out_r2,
	input logic [31:0] instruction_out_r2,
	input logic reset,
	input logic clk,
	output logic link_sel_r3,
	output logic MemRead_r3,
	output logic MemWrite_r3,
	output logic MemtoReg_r3,
	output logic RegWrite_r3,
	output logic [63:0] alu_result_r3,
	output logic [63:0] mux_alusrc_out_r3,
	output logic [63:0] mux_forwardB_out_r3,
	output logic [31:0] instruction_out_r3);
	
	D_FF_enabled link      (link_sel_r3,  link_sel_r2,  reset, clk, enable);
	D_FF_enabled memread   (MemRead_r3,  MemRead_r2,  reset, clk, enable);
	D_FF_enabled memwrite  (MemWrite_r3, MemWrite_r2, reset, clk, enable);
	D_FF_enabled memtoreg  (MemtoReg_r3, MemtoReg_r2, reset, clk, enable);
	D_FF_enabled regwrite  (RegWrite_r3, RegWrite_r2, reset, clk, enable);
	
	D_FF_64 aluresult    (alu_result_r3, alu_result, reset, clk, enable);
	D_FF_64 muxalusrc    (mux_alusrc_out_r3, mux_alusrc_out, reset, clk, enable);
	D_FF_64 muxforwardb  (mux_forwardB_out_r3, mux_forwardB_out_r2, reset, clk, enable);
	D_FF_32 instruct     (instruction_out_r3, instruction_out_r2, reset, clk, enable);
	
endmodule