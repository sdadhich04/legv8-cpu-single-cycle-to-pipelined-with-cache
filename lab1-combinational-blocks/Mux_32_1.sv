`timescale 1ps/1ps
module Mux_32_1(input logic [0:31] in,
	output logic out,
	input logic [4:0] selector 
);

	logic [15:0] stage1;//32->16
	logic [7:0] stage2;//16->8
	logic [3:0] stage3;//8 ->4
	logic [1:0] stage4;//4 ->2
	
	//32->16
	genvar i;
	generate
		for(i = 0; i < 16; i = i + 1)begin : instantiate0
			//assign stage1[i] = selector[0] ? in[i<<1] : in[(i<<1) + 1'b1];
			
			logic [3:0] output0;
			LeftShift #(.WIDTH(4)) input1(.inVal(i), .shiftResult(output0));

			Mux_2_1 mux2_1 (.in0(in[output0 + 1'b1]), .in1(in[output0]), .out(stage1[i]), .sel(selector[0]));
			
			//Mux_2_1 mux2_1 (.in0(in[(i<<1) + 1'b1]), .in1(in[i<<1]), .out(stage1[i]), .sel(selector[0]));
		end
	endgenerate
	
	
	
	//16->8
	genvar j;
	generate
		for(j = 0; j < 8; j = j + 1)begin : instantiate1
			//assign stage2[j] = selector[1] ? stage1[j<<1] : stage1[(j<<1) + 1'b1];
			
			
			logic [2:0] output1;
			LeftShift #(.WIDTH(3)) input1(.inVal(j), .shiftResult(output1));
			
			Mux_2_1 mux2_1 (.in0(stage1[output1 + 1'b1]), .in1(stage1[output1]), .out(stage2[j]), .sel(selector[1]));
			
			//Mux_2_1 mux2_1 (.in0(stage1[output1 + 1'b1]), .in1(stage1[output1]), .out(stage2[j]), .sel(selector[1]));
			
		end
	endgenerate
	
	
	
	
	//8 ->4
	genvar k;
	generate
		for(k = 0; k < 4; k = k + 1)begin : instantiate2
			//assign stage3[k] = selector[2] ? stage2[k<<1] : stage2[(k<<1) + 1'b1];
			
			logic [1:0] output2;
			LeftShift #(.WIDTH(2)) input1(.inVal(k), .shiftResult(output2));
			
			Mux_2_1 mux2_1 (.in0(stage2[output2 + 1'b1]), .in1(stage2[output2]), .out(stage3[k]), .sel(selector[2]));
			
		end
	endgenerate
	
	
	
	
	//4 ->2
	genvar l;
	generate
		for(l = 0; l < 2; l = l + 1)begin : instantiate3
			//assign stage4[l] = selector[3] ? stage3[l<<1] : stage3[(l<<1) + 1'b1];
			
			logic output3;
			LeftShift #(.WIDTH(1)) input1(.inVal(l), .shiftResult(output3));
			
			Mux_2_1 mux2_1 (.in0(stage3[output3 + 1'b1]), .in1(stage3[output3]), .out(stage4[l]), .sel(selector[3]));
			
		end
	endgenerate
	
	
	
	//2 -> 1

	Mux_2_1 mux2_1 (.in0(stage4[1]), .in1(stage4[0]), .out(out), .sel(selector[4]));
	

endmodule

module mux_32_1_testbench();
	logic clk;
	
	logic [31:0] in;
	logic out;
	logic [4:0] selector;
	logic [31:0]input_val;
	
	
	Mux_32_1 dut(.in, .out, .selector);

	
	
	
	// Clock setup
	parameter clock_period = 1000;

	initial begin
		clk = 0;
		forever #(clock_period / 2) clk <= ~clk;	
	end 


	initial begin
		in = 32'b10101010101010101010101010101010;
		@(posedge clk);
		for (input_val = 0; input_val < 32; input_val = input_val + 1) begin
		  selector = input_val;
		  @(posedge clk);
		  @(posedge clk);
		  $display("Time: %0t | input_val = %0d | out = %b", $time, input_val, out);
		end

		
		$display("done");
		$stop; // <- make the simulation stop completely	
	end
endmodule
