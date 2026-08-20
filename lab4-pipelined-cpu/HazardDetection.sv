`timescale 1ns/1ps
module HazardDetection(
	input logic [4:0] Rm, Rn, ID_EX_Rd,
	input logic ID_EX_MEM_Read,
	output logic stall
);

always_comb begin
	
	if((Rm == ID_EX_Rd || Rn == ID_EX_Rd) && ID_EX_MEM_Read) begin 
		stall = 1'b1;
	end
	
	else begin
		stall = 1'b0;
	end
end


endmodule




module HazardDetection_tb();

    // Inputs
    logic [4:0] Rm, Rn, ID_EX_Rd;
    logic ID_EX_MEM_Read;

    // Outputs
    logic stall;

    // Instantiate DUT
    HazardDetection dut (.Rm, .Rn, .ID_EX_Rd, .ID_EX_MEM_Read, .stall);


    initial begin

			Rm = 5'd1;
			Rn = 5'd0;
			ID_EX_Rd = 5'd1;
			ID_EX_MEM_Read = 1'b1;
			//stall = 1
			#500;
			
			Rm = 5'd0;
			Rn = 5'd0;
			ID_EX_Rd = 5'd1;
			ID_EX_MEM_Read = 1'b1;
			//stall = 0
			#500;
			
			Rm = 5'd0;
			Rn = 5'd1;
			ID_EX_Rd = 5'd1;
			ID_EX_MEM_Read = 1'b1;
			//stall = 1
			#500;
			
			Rm = 5'd0;
			Rn = 5'd1;
			ID_EX_Rd = 5'd1;
			ID_EX_MEM_Read = 1'b0;
			//stall = 0
			#500;
			
			
			
        $stop;
    end

endmodule
