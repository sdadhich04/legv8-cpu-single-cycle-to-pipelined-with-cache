`timescale 1ps/1ps
module Mux_4_1_XBit #(parameter WIDTH = 64)(  
	input  logic [WIDTH-1:0] in0, in1,in2, in3,
	output logic [WIDTH-1:0] out,
	input logic [1:0] sel
);

	logic [WIDTH-1:0] outA, outB;
	
	Mux_2_1_XBit #(.WIDTH(WIDTH)) mux2_1A (.in0(in0), .in1(in1), .out(outA), .sel(sel[0]));
	Mux_2_1_XBit #(.WIDTH(WIDTH)) mux2_1B (.in0(in2), .in1(in3), .out(outB), .sel(sel[0]));
	
	

	Mux_2_1_XBit #(.WIDTH(WIDTH)) mux2_1C (.in0(outA), .in1(outB), .out(out), .sel(sel[1]));
	

endmodule 




























module Mux_4_1_XBit_tb();
	logic clk;

	logic [63:0] out;
	logic [1:0] sel;
	logic [31:0]input_val;
	
	logic [63:0] in0, in1, in2, in3;
	Mux_4_1_XBit asddsa(.in0, .in1, .in2, .in3, .out, .sel);

	
	
	
	// Clock setup
	parameter clock_period = 10000;

	initial begin
		clk = 0;
		forever #(clock_period / 2) clk <= ~clk;	
	end 


	initial begin
		
		
		in0 = 64'd1;
		in1 = 64'd2;
		in2 = 64'd3;
		in3 = 64'd4;
		
		for (input_val = 0; input_val < 4; input_val = input_val + 1) begin
		  sel = input_val;
		  @(posedge clk);
		 
		end

		@(posedge clk);
		
		
		$display("done");
		$stop; 
	end
endmodule