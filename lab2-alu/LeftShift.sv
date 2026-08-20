`timescale 1ps/1ps
module LeftShift #(parameter WIDTH = 32)(////WIDTH is number of bits for inVal
	input logic [WIDTH-1:0] inVal,
	output logic [WIDTH:0] shiftResult
); 


	Mux_2_1 mux1(.in0(inVal[0]), .in1(1'b0), .out(shiftResult[0]), .sel(1'b1));
	
	genvar i;
	
	generate
		for(i = 1; i < WIDTH; i = i + 1)begin  : instantiate1
			Mux_2_1 mux2(.in0(inVal[i]), .in1(inVal[i-1]), .out(shiftResult[i]), .sel(1'b1));
		end
	endgenerate


endmodule

module LeftShift_testbench();
	logic clk;
	
	logic [3:0]inVal;
	logic [3:0]shiftResult;

	
	
	
	LeftShift #(.WIDTH(4)) dut(.inVal, .shiftResult);

	
	
	
	// Clock setup
	parameter clock_period = 100;

	initial begin
		clk = 0;
		forever #(clock_period / 2) clk <= ~clk;	
	end 


	initial begin
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		inVal = 4'b0101;
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		

		
		$display("done");
		$stop; // <- make the simulation stop completely	
	end
endmodule
