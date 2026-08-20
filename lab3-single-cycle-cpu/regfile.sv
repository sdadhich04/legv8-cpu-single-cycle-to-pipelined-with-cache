`timescale 1ps/1ps
//Top Level File
module regfile(
input logic	[4:0] 	ReadRegister1, ReadRegister2, WriteRegister,
input logic [63:0]	WriteData,
input logic 			RegWrite, clk,
output logic [63:0]	ReadData1, ReadData2
);


	logic [63:0] RegArr [0:31];//e.g RegArr[5] references register 4 and pulls its 64 bits
	assign RegArr[31] = 64'b0;
	
	//Decoder
	logic [31:0] decoderOutput;
	Decoder_5_32 decode(.in(WriteRegister), .out(decoderOutput), .enable(1'b1));
	
	
	
	
	genvar i, j;
	generate
		for(i = 0; i < 31; i = i + 1)begin : instantiate1
			
			logic [63:0] Mux_output [0:30];
			//Mux_2_1
			Mux_2_1_64Bit mux(
			.in0(RegArr[i]),
			.in1(WriteData),
			.sel(RegWrite & (decoderOutput[i])  ),
			.out(Mux_output[i]));
			
			
			//DFF
			D_FFx64 reg_64Bit(.d(Mux_output[i]), .q(RegArr[i]), .reset(1'b0), .clk);

		end
	endgenerate
	
	
	
	Mux_32_1x64 Mux_64x_32_1_1(.in(RegArr), .out(ReadData1), .selector(ReadRegister1));
	Mux_32_1x64 Mux_64x_32_1_2(.in(RegArr), .out(ReadData2), .selector(ReadRegister2));
	
	
	

endmodule

















module regfile_testbench();
	logic clk, reset, RegWrite;
	logic [4:0] ReadRegister1, ReadRegister2, WriteRegister;
	logic [63:0] WriteData;
	logic [63:0] ReadData1, ReadData2;
	
	
	regfile dut(.clk, .RegWrite, .ReadRegister1, .ReadRegister2, .WriteRegister, .WriteData, .ReadData1, .ReadData2);

	
	
	
	// Clock setup
	parameter clock_period = 1000;

	initial begin
		clk = 0;
		forever #(clock_period / 2) clk <= ~clk;	
	end 


	initial begin
	
		reset = 1'b1;
		@(posedge clk);
		reset = 1'b0;
	
		RegWrite = 1'b1;
		
		
		//fill up register
		for (int i = 0; i < 32; i = i + 1) begin
			WriteRegister = i;
			WriteData = i;
			@(posedge clk);
		end
		RegWrite = 1'b0;
		
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		
		//read register
		for (int i = 0; i < 32; i = i + 1) begin
			ReadRegister1 = i;
			ReadRegister2 = i-1;
			@(posedge clk);
		end
		
		
		

		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		
		$display("done");
		$stop; // <- make the simulation stop completely	
	end
endmodule
