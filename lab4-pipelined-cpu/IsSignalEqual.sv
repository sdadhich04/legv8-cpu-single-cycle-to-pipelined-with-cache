//Returns True if two signals are equal to one another, False otherwise. 
`timescale 1ns/1ps
module IsSignalEqual #(parameter WIDTH = 64)(
	input [WIDTH-1:0] in0, in1,
	output logic out
);

	logic flagStorage;
	logic [WIDTH-1:0] resulted;
	Bit_a_xor_b #(.WIDTH(WIDTH)) Bit_a_xor_b1 (.A(in0), .B(in1), .result(resulted), .zero(out), .negative(flagStorage));
	


endmodule 





























module IsSignalEqual_tb();
	
	parameter delay = 100000;
	logic 				clk;
	logic		[4:0]	in0, in1;
	logic					out;


	

	IsSignalEqual #(.WIDTH(5)) dut (.in0, .in1, .out);

	
	// Clock setup
	parameter clock_period = 200000;

	initial begin
		clk = 0;
		forever #(clock_period / 2) clk <= ~clk;	
	end 
	

	initial begin
		
	
		
		in0 = 5'd3;
		in1 = 5'd23;
		
		@(posedge clk);
		
		in0 = 5'd2;
		in1 = 5'd2;
		
		@(posedge clk);
		
		
		$stop;
		
	end
endmodule