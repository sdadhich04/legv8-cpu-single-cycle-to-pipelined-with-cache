//select statements fro ALU control output
// 000 B, bypass
//	010 A + B
// 011 A - B
// 100 A and B
// 101 A or B
// 110 A xor B
`timescale 1ns/10ps
module control(
	input logic [31:0]instruction,
	//Delayed version of negative and overflow
	input logic negative,
	input logic	overflow,
	input logic zero_h,
	// do to dealy of zero_h you need to provide the non delayed zero 
	// for cbz and other operations
	input logic zero,
	output logic Reg2Loc, 
	//output logic UncondBr,
	//output logic Branch,
	output logic MemRead,
	output logic MemToReg,
	output logic [2:0]ALUOp,
	output logic MemWrite,
	output logic ALUSrc,
	output logic RegWrite,
	output logic [1:0] extended_sel,
	output logic link_sel,
	output logic branch_reg_sel,
	output logic NOOP,
	output logic control_mux_out,
	output logic hold_flags);
	
	logic control_mux;
	logic UncondBr, Branch; 
	logic BLTxorResult; //internal logic. 
	xor #50 BLTxor (BLTxorResult, negative, overflow);
	
	//internal logic.
	and #50 and1(and1_out, zero, Branch);
	or #50 signal_or(control_mux, UncondBr, and1_out);
	
	
	parameter ADDI = 11'b1001000100x;
	parameter ADDS = 11'b10101011000;
	parameter SUBS = 11'b11101011000;
	parameter B    = 11'b000101xxxxx;
	parameter BR   = 11'b11010110000;							 
	parameter BL   = 11'b100101xxxxx;
	parameter BLT  = 11'b01010100xxx;
	parameter CBZ  = 11'b10110100xxx;
	parameter LDUR = 11'b11111000010;
	parameter STUR = 11'b11111000000;
	
	
	always_comb begin
		// Default values
		casex (instruction[31:21])

			ADDI: begin 
				Reg2Loc = 1'b1;
				RegWrite = 1'b1;
				ALUSrc = 1'b1;
				ALUOp = 3'b010;
				MemWrite = 1'b0;
				MemToReg = 1'b0;
				UncondBr = 1'b0;
				Branch = 1'b0;
				extended_sel=2'b10;
				link_sel = 1'b0;
				branch_reg_sel = 1'b0;
				NOOP= 1'b0;
				hold_flags =1'b0;
				control_mux_out = control_mux;
				end
			
			
			ADDS: begin
				Reg2Loc = 1'b0;
				RegWrite = 1'b1;
				ALUSrc = 1'b0;
				ALUOp = 3'b010;
				MemWrite = 1'b0;
				MemToReg = 1'b0;
				UncondBr = 1'b0;
				Branch = 1'b0;
				//extended_sel='x;
				extended_sel = 2'b00;
				link_sel = 1'b0;
				branch_reg_sel = 1'b0;
				NOOP = 1'b0;
				hold_flags =1'b1;
				control_mux_out = control_mux;
				end
			
			B: begin
				Reg2Loc = 1'bx;
				RegWrite = 1'b0;
				ALUSrc = 1'bx;
				ALUOp = 3'bxxx;
				MemWrite = 1'b0;
				MemToReg = 1'bx;
				UncondBr = 1'b1;
				Branch = 1'b1;
				extended_sel=2'b00;
				link_sel = 1'b0;
				branch_reg_sel = 1'b0;
				NOOP = 1'b1;
				hold_flags =1'b0;
				control_mux_out = control_mux;
				end
				
			BL: begin
				Reg2Loc = 1'bx;
				RegWrite = 1'b1;
				ALUSrc = 1'b1;
				ALUOp = 3'bxxx;
				MemWrite = 1'b0;
				MemToReg = 1'b0;
				UncondBr = 1'b0;
				MemRead = 1'b0;
				Branch = 1'b1;
				extended_sel=2'b00;
				link_sel = 1'b1;
				branch_reg_sel = 1'b0;
				NOOP = 1'b1;
				hold_flags =1'b0;
				control_mux_out = Branch;
				end
			BR: begin
				Reg2Loc = 1'b1;
				RegWrite = 1'b0;
				ALUSrc = 1'bx;
				ALUOp = 3'bxxx;
				MemWrite = 1'b0;
				MemToReg = 1'bx;
				UncondBr = 1'b1;
				MemRead = 1'b0;
				Branch = 1'b1;
				extended_sel=2'bxx;
				link_sel = 1'b0;
				branch_reg_sel = 1'b1;
				NOOP = 1'b1;
				hold_flags =1'b0;
				control_mux_out = control_mux;
				end
			
			BLT: begin
				Reg2Loc = 1'b0;
				RegWrite = 1'b0;
				ALUSrc = 1'b1;
				ALUOp = 3'bxxx;
				MemWrite = 1'b0;
				MemToReg = 1'bx;
				UncondBr = 1'b0;
				//Delayed version of negative and overflow
				Branch = (negative != overflow);
				MemRead = 1'bx;
				extended_sel=2'b01;
				link_sel = 1'b0;
				branch_reg_sel = 1'b0;
				NOOP = 1'b1;
				hold_flags =1'b0;
				if(Branch)
					control_mux_out = 1'b1;
				else
					control_mux_out = 1'b0;
				end
			
			CBZ: begin
				Reg2Loc = 1'b1;
				RegWrite = 1'b0;
				ALUSrc = 1'b0;
				ALUOp = 3'b000;
				MemWrite = 1'b0;
				MemToReg = 1'bx;
				UncondBr = 1'b0;
				Branch = 1'b1;
				MemRead = 1'b0;
				extended_sel=2'b01;
				link_sel = 1'b0;
				branch_reg_sel = 1'b0;
				NOOP = 1'b0;
				hold_flags = 1'b0;
				control_mux_out = control_mux;
				end
			
			LDUR: begin
				//Might need to make UncondR 0
				Reg2Loc = 1'bx;
				RegWrite = 1'b1;
				ALUSrc = 1'b1;
				ALUOp = 3'b010;
				MemWrite = 1'b0;
				MemToReg = 1'b1;
				UncondBr = 1'b0;
				Branch = 1'b0;
				MemRead = 1'b1;
				extended_sel=2'b11;
				link_sel = 1'b0;
				branch_reg_sel = 1'b0;
				NOOP = 1'b1;
				hold_flags =1'b0;
				control_mux_out = control_mux;
				end
				
			STUR: begin
				//Might need to make UncondR 0
				Reg2Loc  = 1'b1;
				RegWrite = 1'b0;
				ALUSrc = 1'b1;
				ALUOp = 3'b010;
				MemWrite = 1'b1;
				MemToReg = 1'bx;
				UncondBr = 1'b0;
				Branch = 1'b0;
				extended_sel=2'b11;
				link_sel = 1'b0;
				branch_reg_sel = 1'b0;
				NOOP = 1'b1;
				hold_flags =1'b0;
				control_mux_out = control_mux;
				end
				
				
			SUBS: begin
				Reg2Loc = 1'b0;
				RegWrite = 1'b1;
				ALUSrc = 1'b0;
				ALUOp = 3'b011;
				MemWrite = 1'b0;
				MemToReg = 1'b0;
				UncondBr = 1'b0;
				Branch = 1'b0;
				//extended_sel='x;
				extended_sel = 2'b00;
				link_sel = 1'b0;
				branch_reg_sel = 1'b0;
				NOOP = 1'b0;
				hold_flags =1'b1;
				control_mux_out = control_mux;
				
				end
			endcase
		end
				
endmodule
