`timescale 1ns/10ps
module execute_addr_calc(
	input logic ALUSrc,
	input logic [2:0] ALUOP,
	input logic [63:0] DataMemory_mux,
	input logic [63:0] ReadData1, 
	input logic [63:0] ReadData2, 
	input logic [63:0] extended_instruct_out,
	input logic [63:0] mux_forwardA_out_r2,
	input logic [63:0] mux_forwardB_out_r2,
	output logic [63:0] alu_result,
	output logic [63:0] mux_alusrc_out,
	output logic zero, 
	output logic overflow, 
	output logic negative, 
	output logic carry_out);
	
	
	logic [63:0] mux_alusrc;
	
	assign mux_alusrc_out = mux_alusrc;
	
	//	alu alu_mem( ReadData1, mux_out, ALUOP, alu_result, negative, zero, overflow, carry_out);
	alu alu_mem( mux_forwardA_out_r2, mux_alusrc, ALUOP, alu_result, negative, zero, overflow, carry_out);
	
	genvar mux_alusrc_i;
	
	//Logic is backwards for data_mux and alu_result inside of the 4x1 mux
	generate
				//Mux that chooses between sign extension and ReadData2
		for(mux_alusrc_i=0; mux_alusrc_i<64; mux_alusrc_i++) begin : eachALUSrc
			mux_2x1 alusrc(ALUSrc, {extended_instruct_out[mux_alusrc_i], mux_forwardB_out_r2[mux_alusrc_i]}, mux_alusrc[mux_alusrc_i]);
		end
		
	endgenerate
endmodule