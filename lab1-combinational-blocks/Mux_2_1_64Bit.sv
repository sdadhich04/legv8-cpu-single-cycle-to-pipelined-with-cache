`timescale 1ps/1ps
module Mux_2_1_64Bit(
	input logic[63:0]  in0, in1,
	output logic[63:0]  out,
	input logic sel
);



	genvar i;
	generate
		for(i = 0; i < 64; i = i + 1)begin : Mux_2_1_64Bit
			Mux_2_1 mux(.in0(in0[i]), .in1(in1[i]), .sel(sel), .out(out[i]));
			
			
		end
	endgenerate
	
endmodule


module Mux_2_1_64Bit_testbench();
	logic clk;
	
	logic [63:0] in0, in1;
	logic [63:0] out;
	logic sel;
	
	Mux_2_1_64Bit mux(.in0, .in1, .sel, .out);
	
	
	
	// Clock setup
	parameter clock_period = 200;

	initial begin
		clk = 0;
		forever #(clock_period / 2) clk <= ~clk;	
	end 


	initial begin
		in0 = 64'd123123;
		in1 = 64'd1;
		
		sel = 1'b1;
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		sel = 1'b0;
		
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);

		$display("done");
		$stop; // <- make the simulation stop completely	
	end
endmodule
