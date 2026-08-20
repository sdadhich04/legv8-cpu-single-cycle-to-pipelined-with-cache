`timescale 1ns/1ps
module Opcode_Decoder(
	input logic [31:0] instruction, 
	input logic zero, negative, Overflow,
	output logic [2:0] ALU_Operation,//cntrl in alu.sv
	output logic Reg2Loc, ALUSrc, MemToReg, RegWrite, MemWrite, BrTaken, UncondBr, UseImm, BLT, BranchLink, BranchRegsiter, MemRead, CBZBranch

);


//logic [5:0] shamt; Only for LSL/LSR





always_comb begin
	//shamt = 6'b0; Only for LSL/LSR
	
	   
	Reg2Loc = 1'b0;
	ALUSrc = 1'b0;
	MemToReg = 1'b0;
	RegWrite = 1'b0;
	MemWrite = 1'b0;
	BrTaken = 1'b0;
	UncondBr = 1'b0;
	BLT = 1'b0;
	ALU_Operation = 3'b0; 
	UseImm = 1'b0;
	BranchLink = 1'b0;
	BranchRegsiter = 1'b0;
	MemRead = 1'b0;
	CBZBranch = 1'b0;
	casez (instruction[31:21])

	11'b1001000100?: begin //ADDI Type:I 
		
		ALUSrc = 1'b1;
		RegWrite = 1'b1;
		UseImm = 1'b1;
		ALU_Operation = 3'b010;//add
	end
	
	11'b10101011000: begin //ADDS Type:R
		//shamt = instruction[15:10]; Only for LSL/LSR
		
		Reg2Loc = 1'b1;
		RegWrite = 1'b1;
		ALU_Operation = 3'b010;//add
		
	end
	
	11'b11101011000: begin //SUBS Type:R 
		//shamt = instruction[15:10]; Only for LSL/LSR
		
		Reg2Loc = 1'b1;
		RegWrite = 1'b1;
		ALU_Operation = 3'b011;//sub
		
	end
	
	11'b000101?????: begin //B Type:B
		BrTaken = 1'b1;
		UncondBr = 1'b1;

	end
	
	11'b10110100???: begin //CBZ Type:CB
		ALU_Operation = 3'b000; //Pass B
		ALUSrc = 1'b0;
		Reg2Loc = 1'b0;
		CBZBranch = 1'b1;
		BrTaken = zero;
	end
	
	11'b11111000000: begin //STUR Type:D

		Reg2Loc = 1'b0;//sets Rd to ReadRegister2 in RegFile
		ALUSrc = 1'b1;
		MemWrite = 1'b1;
		ALU_Operation = 3'b010;//add
	end
	
	11'b11111000010: begin //LDUR Type: D


		MemRead = 1'b1;
		ALUSrc = 1'b1;
		MemToReg = 1'b1;
		RegWrite = 1'b1;
		ALU_Operation = 3'b010;
	end
	
	11'b01010100???: begin //B.LT Type:CB
		BrTaken = negative ^ Overflow;
		UncondBr = 1'b0;
		BLT = 1'b1;
	end
	
	11'b100101?????: begin //BL Type:B
		BrTaken = 1'b1;
		UncondBr = 1'b1;
		RegWrite = 1'b1;
		BranchLink = 1'b1;//new variable
	end
	
	11'b11010110000: begin //BR Type:R
		BranchRegsiter = 1'b1; //new variable
		
		
	end
	
	
	endcase
end


endmodule


module Opcode_Decoder_tb();
	
	
	// Declare wires for inputs and outputs
    logic [31:0] instruction;
    logic zero, negative, Overflow;
    logic [2:0] ALU_Operation;
    logic Reg2Loc, ALUSrc, MemToReg, RegWrite, MemWrite, BrTaken, UncondBr, UseImm, BLT, clk, BranchLink, BranchRegsiter;

    // Instantiate the Opcode_Decoder module
    Opcode_Decoder decoder_inst (
        .instruction(instruction),
        .zero(zero),
        .negative(negative),
		  .Overflow(Overflow),
        .ALU_Operation(ALU_Operation),
        .Reg2Loc(Reg2Loc),
        .ALUSrc(ALUSrc),
        .MemToReg(MemToReg),
        .RegWrite(RegWrite),
        .MemWrite(MemWrite),
        .BrTaken(BrTaken),
        .UncondBr(UncondBr),
        .UseImm(UseImm),
        .BLT(BLT),
		  .BranchLink(BranchLink),
		  .BranchRegsiter(BranchRegsiter)
    );


	
	// Clock setup
	parameter clock_period = 200000;

	initial begin
		clk = 0;
		forever #(clock_period / 2) clk <= ~clk;	
	end 



	initial begin
		zero = 1'b1;
		negative = 1'b1;
		Overflow = 1'b0;
		instruction = 32'b10010001000000000000001111100000; // ADDI X0, X31, #0     // X0 = 0
		@(posedge clk);
		instruction = 32'b11101011000000000000001111100001; // SUBS X1, X31, X0     // X1 = -1
		@(posedge clk);
		instruction = 32'b10101011000001000000000001100101; // ADDS X5, X3, X4      // X5 = -5
		@(posedge clk);
		instruction = 32'b10110100000000000000001010011111; // CBZ X31, FORWARD_CBZ // 3rd taken branch (+20)
		@(posedge clk);
		instruction = 32'b00010100000000000000000000001100; // B FORWARD_B 1st taken branch (+12)
		@(posedge clk);
		instruction = 32'b11111000010111111000000001100101; // LDUR X5, [X3, #-8]   // X5 = Mem[0] = 1
		@(posedge clk);
		instruction = 32'b11111000000000001000000001100010; // STUR X2, [X3, #8]    // Mem[16] = 3
		@(posedge clk);
		instruction = 32'b01010100000000000000000010001011; // B.LT SUCCESS         // Take this. (+4))
		@(posedge clk);
		instruction = 32'b10010100000000000000000000000101; // BL BL_FORWARDS (+5)         
		@(posedge clk);
		instruction = 32'b11010110000000000000000000000101; // BR X5 (END)
		@(posedge clk);
		

		$stop;
		
	end
endmodule
