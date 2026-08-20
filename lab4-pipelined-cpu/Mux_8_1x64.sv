`timescale 1ps/1ps
module Mux_8_1x64(//EDITED for 68 Bits  
	input  logic [67:0] in [0:7],
	output logic [67:0] out,
	input logic [2:0] selector 
);


	logic [67:0] stage3 [3:0];//8 ->4
	logic [67:0] stage4 [1:0];//4 ->2
	
	
	//8 ->4
	genvar k;
	generate
		for(k = 0; k < 4; k = k + 1)begin  : instantiate2
			//assign stage3[k] = selector[2] ? stage2[(k<<1) + 1'b1] : stage2[(k<<1)];
			
			logic [2:0] output2;
			LeftShift input3(.inVal(k), .shiftResult(output2));
			
			Mux_2_1_XBit #(.WIDTH(68)) mux2_1 (.in0(in[output2]), .in1(in[output2 + 1'b1]), .out(stage3[k]), .sel(selector[0]));
			
		end
	endgenerate
	
	
	//4 ->2
	genvar l;
	generate
		for(l = 0; l < 2; l = l + 1)begin  : instantiate3
			//assign stage4[l] = selector[3] ? stage3[(l<<1) + 1'b1] : stage3[(l<<1)];
			
			logic [1:0] output3;
			LeftShift input4(.inVal(l), .shiftResult(output3));
			
			Mux_2_1_XBit #(.WIDTH(68)) mux2_1 (.in0(stage3[output3]), .in1(stage3[output3 + 1'b1]), .out(stage4[l]), .sel(selector[1]));
			
		end
	endgenerate
	
	
	//2 -> 1

	Mux_2_1_XBit #(.WIDTH(68)) mux2_1 (.in0(stage4[0]), .in1(stage4[1]), .out(out), .sel(selector[2]));
	


	
endmodule

module Mux_8_1x64_tb();
	logic clk;
	logic [67:0] arr [0:7];
	logic [67:0] out;
	logic [2:0] selector;
	logic [31:0]input_val;
	
	
	Mux_8_1x64 asddsa(.in(arr), .out, .selector);

	
	
	
	// Clock setup
	parameter clock_period = 10000;

	initial begin
		clk = 0;
		forever #(clock_period / 2) clk <= ~clk;	
	end 


	initial begin
		for (int i = 0; i < 8; i = i + 1) begin
			arr[i] = i+64'd100; 
			$display("Time: %0t | i = %0d | arr[i] = %0d", $time, i, arr[i]);
		end
		
		
		
		
		
		for (input_val = 0; input_val < 8; input_val = input_val + 1) begin
		  selector = input_val;
		  @(posedge clk);
		 
		end

		@(posedge clk);
		
		
		$display("done");
		$stop; 
	end
endmodule
