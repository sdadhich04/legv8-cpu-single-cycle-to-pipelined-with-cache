`timescale 1ns/10ps
module regfile(ReadData1, ReadData2, WriteData, 
					 ReadRegister1, ReadRegister2, WriteRegister,
					 RegWrite, clk);
	
	input logic RegWrite, clk;
	input logic	[4:0] ReadRegister1, ReadRegister2, WriteRegister;
	input logic [63:0] WriteData;
	output logic [63:0]	ReadData1, ReadData2;
	
	// Array sequence to store values of all the registers
	logic [31:0][63:0] reg_out_32;
	logic [31:0] dec_out;
	
	decoder_5x32 decoder5x32(WriteRegister, RegWrite, dec_out);
	
	// This has forced reg 31 to be zero
	assign reg_out_32[31] = 64'h0000_0000_0000_0000;
	
	
	genvar reg_num, mux_num;
	
	generate
		// Generates 30 registers 
		for(reg_num=0; reg_num<31; reg_num++) begin : eachDff
				// reset signal is set as a 1-bit value for all flip flops
				D_FF_64 Register (reg_out_32[reg_num], WriteData, 1'b0, clk, dec_out[reg_num]);
		end
		
		// Generates a 64 sequence of 32:1 muxes for read register 1
		for(mux_num=0; mux_num<64; mux_num++) begin : readRegs
				mux_32x1 read_reg1(ReadRegister1, {1'b0,
																reg_out_32[30][mux_num],
																reg_out_32[29][mux_num],
																reg_out_32[28][mux_num],
																reg_out_32[27][mux_num],
																reg_out_32[26][mux_num],
																reg_out_32[25][mux_num],
																reg_out_32[24][mux_num],
																reg_out_32[23][mux_num],
																reg_out_32[22][mux_num],
																reg_out_32[21][mux_num],
																reg_out_32[20][mux_num],
																reg_out_32[19][mux_num],
																reg_out_32[18][mux_num],
																reg_out_32[17][mux_num],
																reg_out_32[16][mux_num],
																reg_out_32[15][mux_num],
																reg_out_32[14][mux_num],
																reg_out_32[13][mux_num],
																reg_out_32[12][mux_num],
																reg_out_32[11][mux_num],
																reg_out_32[10][mux_num],
																reg_out_32[9][mux_num],
																reg_out_32[8][mux_num],
																reg_out_32[7][mux_num],
																reg_out_32[6][mux_num],
																reg_out_32[5][mux_num],
																reg_out_32[4][mux_num],
																reg_out_32[3][mux_num],
																reg_out_32[2][mux_num],
																reg_out_32[1][mux_num],
																reg_out_32[0][mux_num]
																}, ReadData1[mux_num]);
																
					// Generates a 64 sequence of 32:1 muxes for read register 2										
					mux_32x1 read_reg2(ReadRegister2, {1'b0,
																reg_out_32[30][mux_num],
																reg_out_32[29][mux_num],
																reg_out_32[28][mux_num],
																reg_out_32[27][mux_num],
																reg_out_32[26][mux_num],
																reg_out_32[25][mux_num],
																reg_out_32[24][mux_num],
																reg_out_32[23][mux_num],
																reg_out_32[22][mux_num],
																reg_out_32[21][mux_num],
																reg_out_32[20][mux_num],
																reg_out_32[19][mux_num],
																reg_out_32[18][mux_num],
																reg_out_32[17][mux_num],
																reg_out_32[16][mux_num],
																reg_out_32[15][mux_num],
																reg_out_32[14][mux_num],
																reg_out_32[13][mux_num],
																reg_out_32[12][mux_num],
																reg_out_32[11][mux_num],
																reg_out_32[10][mux_num],
																reg_out_32[9][mux_num],
																reg_out_32[8][mux_num],
																reg_out_32[7][mux_num],
																reg_out_32[6][mux_num],
																reg_out_32[5][mux_num],
																reg_out_32[4][mux_num],
																reg_out_32[3][mux_num],
																reg_out_32[2][mux_num],
																reg_out_32[1][mux_num],
																reg_out_32[0][mux_num]
																}, ReadData2[mux_num]);
		end// for
	endgenerate

endmodule//regfile

module regfile_tb();
	logic RegWrite, clock;
	logic	[4:0] ReadRegister1, ReadRegister2, WriteRegister;
	logic [63:0] WriteData;
	logic [63:0]	ReadData1, ReadData2;
	
	regfile dut(ReadData1, ReadData2, WriteData, 
					 ReadRegister1, ReadRegister2, WriteRegister,
					 RegWrite, clock);
	
	parameter clock_period = 100;

	initial begin
			clock <= 0;
			forever #(clock_period /2) clock <= ~clock;
	end
	
	initial begin
		//Test to see if all the combined modules work
		WriteData<=0; ReadRegister1<=0; ReadRegister2<=0; WriteRegister<=0; RegWrite<=1; @(posedge clock);
		// Turns off RegWrite for 10 clock cycles
		WriteData<=3; ReadRegister1<=1; ReadRegister2<=0; WriteRegister<=1; RegWrite<=1; @(posedge clock);
		WriteData<=5; ReadRegister1<=2; ReadRegister2<=0; WriteRegister<=2; RegWrite<=1; @(posedge clock);
		WriteData<=15; ReadRegister1<=3; ReadRegister2<=0; WriteRegister<=3; RegWrite<=1; @(posedge clock);
		WriteData<=15; ReadRegister1<=4; ReadRegister2<=0; WriteRegister<=4; RegWrite<=1; @(posedge clock);
		WriteData<=15; ReadRegister1<=5; ReadRegister2<=0; WriteRegister<=5; RegWrite<=1; @(posedge clock);
		WriteData<=15; ReadRegister1<=30; ReadRegister2<=0; WriteRegister<=30; RegWrite<=1; @(posedge clock);
		WriteData<=1; ReadRegister1<=0; ReadRegister2<=0; WriteRegister<=30; RegWrite<=0; repeat(15)@(posedge clock);
		WriteData<=1; ReadRegister1<=30; ReadRegister2<=0; WriteRegister<=30; RegWrite<=0; repeat(5)@(posedge clock);
		$stop;
	end


endmodule
