`timescale 1ns/1ps
module ConcatinateBits(
input logic carry_out_Arr,
input logic overflow_Arr,
input logic zero_Arr,
input logic negative_Arr,
input logic [63:0] result_Arr,
output logic [67:0] result
);

	generate 
		genvar i;
		for(i = 0; i < 64; i = i + 1)begin : loop
			
			and #50 out(result[i], 1'b1, result_Arr[i]);
		end
	endgenerate
	
	and #50 negative_(result[64], negative_Arr, 1'b1);
	and #50 zero_(result[65], zero_Arr, 1'b1);
	and #50 overflow_(result[66], overflow_Arr, 1'b1);
	and #50 carry_out_(result[67], carry_out_Arr, 1'b1);


endmodule