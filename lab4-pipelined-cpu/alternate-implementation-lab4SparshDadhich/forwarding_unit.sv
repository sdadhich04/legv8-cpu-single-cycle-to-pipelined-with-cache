module forwarding_unit( input logic [31:0] instruction_out_r1, 
							input logic [31:0]instruction_out_r2, 
							input logic[31:0]instruction_out_r3,
							input logic [4:0] ReadRegister2_out,//DecAb
							input logic ID_EX_r2_RegWrite, //ExRegWrite
							input logic EX_MEM_r3_RegWrite,//MemRegWrite
							output logic[1:0] ForwardA,
							output logic[1:0] ForwardB);
							
							
		//Aw = instruction_out_rx_[4:0]
		
		//DecAa = ReadRegister1_out
		//DecAb = ReadRegister2_out
		//ExAw = Instruction_out_r2_rd[4:0]
		//MemAw =  instruction_out_r3_rd[4:0]
		//ExRegWrite = ID_EX_r2_RegWrite
		//MemRegWrite = EX_MEM_r3_RegWrite
	

	logic [4:0] ID_EX_Rd, EX_MEM_Rd;
	//Everything that is EX_MEM is now ID_EX and everything that is MEM_WB is now EX_MEM
	
	assign ReadRegister1 = instruction_out_r1[9:5];//DecAa
	assign ID_EX_Rd =  instruction_out_r2[4:0];// ExAw
	assign EX_MEM_Rd = instruction_out_r3[4:0];// MemAw
	
	
	always_comb begin
		if (ID_EX_r2_RegWrite && (ID_EX_Rd == ReadRegister1) && (ID_EX_Rd != 5'd31)) begin
			ForwardA = 2'b01;
		end
		
		else if (EX_MEM_r3_RegWrite && (EX_MEM_Rd != 5'd31) && (EX_MEM_Rd == ReadRegister1) 
		&& (~ID_EX_r2_RegWrite || (ID_EX_Rd != ReadRegister1) 
		|| (ID_EX_Rd == 5'd31))) begin
			ForwardA = 2'b10;
		end
		
		else begin
			ForwardA = 2'b00;
		end
		
		if (ID_EX_r2_RegWrite && (ID_EX_Rd == ReadRegister2_out) && (ID_EX_Rd != 5'd31)) begin
			ForwardB = 2'b01;
		end
		
		else if (EX_MEM_r3_RegWrite && (EX_MEM_Rd != 5'd31) && (EX_MEM_Rd == ReadRegister2_out) 
		&& (~ID_EX_r2_RegWrite || (ID_EX_Rd != ReadRegister2_out) 
		|| (ID_EX_Rd== 5'd31))) begin
			ForwardB = 2'b10;
		end
		
		else begin
			ForwardB = 2'b00;
		end
	end
	/*always_comb begin		// Forward A EX Hazard
			if (EX_MEM_r3_RegWrite && (EX_MEM_Rd != 5'd31) && (EX_MEM_Rd == ID_EX_Rn)) begin
				ForwardA = 2'b10;
			end
	//check IDEX and EX MEM register values
	//check the output odf
			else if (MEM_WB_r4_RegWrite 
			&& (MEM_WB_Rd != 5'd31) 
			//removed the not from here
			&& !(EX_MEM_r3_RegWrite && (EX_MEM_Rd != 5'd31) // )
			&& (EX_MEM_Rd != ID_EX_Rn)) // )
			&& (MEM_WB_Rd == ID_EX_Rn)) begin
				ForwardA = 2'b01;
			end
		
			else begin
				ForwardA = 2'b00;
			end
				
	
			if (EX_MEM_r3_RegWrite && (EX_MEM_Rd != 5'd31) && (EX_MEM_Rd == ID_EX_Rm)) begin
				ForwardB = 2'b10;
			end
		
			else if (MEM_WB_r4_RegWrite && (MEM_WB_Rd != 5'd31) 
			//removed the not from here
			&& !(EX_MEM_r3_RegWrite && (EX_MEM_Rd != 5'd31) 
			&& (EX_MEM_Rd != ID_EX_Rm)) 
			&& (MEM_WB_Rd == ID_EX_Rm)) begin
				ForwardB = 2'b01;
			end		
	
			else begin
				ForwardB = 2'b00;
			end
	end*/
endmodule
				
	
