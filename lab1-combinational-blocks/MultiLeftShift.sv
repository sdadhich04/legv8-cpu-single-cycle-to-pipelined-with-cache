`timescale 1ps/1ps
module MultiLeftShift #(parameter WIDTH = 32, NUMSHIFT = 1) (
	input logic [WIDTH-1:0] inVal,
	output logic [WIDTH-1:0] shiftResult
	
); 

	logic [WIDTH-1:0] tempArr [NUMSHIFT:0];
	
	LeftShift #(.WIDTH(WIDTH)) Lshifter(.inVal(inVal), .shiftResult(tempArr[0]));
	genvar i;
	generate
		for(i = 1; i < NUMSHIFT; i = i + 1)begin  : instantiate1
			LeftShift #(.WIDTH(WIDTH)) Lshifter(.inVal(tempArr[i-1]), .shiftResult(tempArr[i]));
		end
	endgenerate

	assign shiftResult = tempArr[NUMSHIFT-1];
endmodule


module MultiLeftShift_testbench();
	logic clk;
	
	logic [7:0]inVal;
	logic [7:0]shiftResult;
	
	
	
	MultiLeftShift #(.WIDTH(8)) dut(.inVal, .shiftResult);

	
	
	
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
		inVal = 8'b00000101;
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		

		
		$display("done");
		$stop; // <- make the simulation stop completely	
	end
endmodule
