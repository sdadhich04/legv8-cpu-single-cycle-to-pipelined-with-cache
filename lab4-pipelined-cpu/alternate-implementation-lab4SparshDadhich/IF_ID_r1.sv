module IF_ID_r1(
	input logic enable,
	//input logic Reg2Loc,
	//input logic link_sel,
	//input logic [1:0]extended_sel,
	//input logic ALUSrc,
	//input logic [2:0] ALUOP,
	//input logic MemRead,
	//input logic MemWrite,
	//input logic MemtoReg,
	//input logic RegWrite,
	input logic [63:0] alu_add4_result,
	input logic [63:0] pc_instruc_out,
	input logic [31:0] instruction_out,
	input logic reset,
	input logic clk,
	//output logic Reg2Loc_r1,
	//output logic link_sel_r1,
	//output logic [1:0]extended_sel_r1,
	//output logic ALUSrc_r1,
	//output logic [2:0] ALUOP_r1,
	//output logic MemRead_r1,
	//output logic MemWrite_r1,
	//output logic MemtoReg_r1,
	//output logic RegWrite_r1,
	output logic [63:0] alu_add4_result_r1,
	output logic [63:0] pc_instruc_out_r1,
	output logic [31:0] instruction_out_r1);
	
	//D_FF_enabled reg2loc   (Reg2Loc_r1,  Reg2Loc,  reset, clk, enable);
	//D_FF_enabled link      (link_sel_r1, link_sel, reset, clk, enable);
	//D_FF_2 		 extended  (extended_sel_r1, extended_sel, reset, clk, enable);
	//D_FF_enabled alusrc    (ALUSrc_r1,   ALUSrc,   reset, clk, enable);
	//D_FF_3       aluop     (ALUOP_r1,    ALUOP,    reset, clk, enable);
	//D_FF_enabled memread   (MemRead_r1,  MemRead,  reset, clk, enable);
	//D_FF_enabled memwrite  (MemWrite_r1, MemWrite, reset, clk, enable);
	//D_FF_enabled memtoreg  (MemtoReg_r1, MemtoReg, reset, clk, enable);
	//D_FF_enabled regwrite  (RegWrite_r1, RegWrite, reset, clk, enable);

	D_FF_64 alu_add4 (alu_add4_result_r1, alu_add4_result, reset, clk, enable);
	D_FF_64 pc       (pc_instruc_out_r1,  pc_instruc_out, reset, clk, enable);
	D_FF_32 instruct (instruction_out_r1, instruction_out, reset, clk, enable);
	
endmodule