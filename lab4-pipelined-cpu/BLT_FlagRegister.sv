`timescale 1ps/1ps
module BLT_FlagRegister(
	input logic [3:0] ALU_Flags,
	input logic AluSrc, reset, clk,
	output logic Negative, Overflow
);
	//negative is zero bit
	//overflow is first bit

	
	

	logic [1:0] SubRegIn, SubRegOut, MuxBLT_Out;
	
	
	

	Mux_2_1_XBits #(.WIDTH(2)) Mux_AluSrc(.in0(ALU_Flags[1:0]), .in1(SubRegOut), .out(SubRegIn), .sel(AluSrc));

	D_FF_XBits #(.WIDTH(2)) DFF_SubReg(.d(SubRegIn), .q(SubRegOut), .reset, .clk);

	Mux_2_1_XBits #(.WIDTH(2)) Mux_BLT(.in0(ALU_Flags[1:0]), .in1(SubRegOut), .out(MuxBLT_Out), .sel(AluSrc));

	
	and (Negative, MuxBLT_Out[0], 1'b1);
	and (Overflow, MuxBLT_Out[1], 1'b1);

endmodule







`timescale 1ns/1ps

module BLT_FlagRegister_tb();

   logic [63:0] ReadData1, ReadData2;
	logic AluSrc, BLT, reset, clk;
	logic Negative, Overflow;

    // Instantiate DUT
BLT_FlagRegister uut (
    .ReadData1(ReadData1),
    .ReadData2(ReadData2),
    .AluSrc(AluSrc),
    .BLT(BLT),
    .reset(reset),
    .clk(clk),
    .Negative(Negative),
    .Overflow(Overflow)
);

// Clock setup
	parameter clock_period = 1000;

	initial begin
		clk = 0;
		forever #(clock_period / 2) clk <= ~clk;	
	end 
    initial begin
			
			//no op stall
			reset = 1'b1;		
			@(posedge clk);
			//test branch less than (SUBS) (1-10) < 0
			reset = 1'b0;
			ReadData1 = 64'b1;
			ReadData2 = 64'b10;
			AluSrc = 1'b0;
			BLT = 1'b0;
			@(posedge clk);
			
			//test ADDI Noop
			ReadData1 = 64'b1;
			ReadData2 = 64'b1;
			AluSrc = 1'b1;
			BLT = 1'b0;
			@(posedge clk);
			
			//test ADDI Noop
			ReadData1 = 64'b1;
			ReadData2 = 64'b1;
			AluSrc = 1'b1;
			BLT = 1'b0;
			@(posedge clk);
			
			//test ADDI Noop
			ReadData1 = 64'b1;
			ReadData2 = 64'b1;
			AluSrc = 1'b1;
			BLT = 1'b0;
			@(posedge clk);
			
			//test ADDI Noop
			ReadData1 = 64'b1;
			ReadData2 = 64'b1;
			AluSrc = 1'b1;
			BLT = 1'b0;
			@(posedge clk);
			
			//test ADDI Noop
			ReadData1 = 64'b1;
			ReadData2 = 64'b1;
			AluSrc = 1'b1;
			BLT = 1'b0;
			@(posedge clk);
			
			//test ADDI Noop
			ReadData1 = 64'b1;
			ReadData2 = 64'b1;
			AluSrc = 1'b1;
			BLT = 1'b0;
			@(posedge clk);
			
			//test ADDI Noop
			ReadData1 = 64'b1;
			ReadData2 = 64'b1;
			AluSrc = 1'b1;
			BLT = 1'b0;
			@(posedge clk);

			//Branch LT
			BLT = 1'b1;
			@(posedge clk);
			@(posedge clk);
			@(posedge clk);
			@(posedge clk);
			@(posedge clk);
			@(posedge clk);
			@(posedge clk);
			@(posedge clk);
			
			
			//branch immediate
			reset = 1'b1;		
			@(posedge clk);
			//test branch less than (SUBS) (1-10) < 0
			reset = 1'b0;
			ReadData1 = 64'b1;
			ReadData2 = 64'b10;
			AluSrc = 1'b0;
			BLT = 1'b0;
			@(posedge clk);
			//Branch LT
			BLT = 1'b1;
			@(posedge clk);
			@(posedge clk);
			@(posedge clk);
			@(posedge clk);
			@(posedge clk);
			@(posedge clk);
			@(posedge clk);
			@(posedge clk);
			

        $stop;
    end

endmodule


