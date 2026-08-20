

//Left off: just checked CBZ, and everything looks good, (as in my outputs match expected results)
//Next check test 4, Load and Stores. 


`timescale 1ns/1ps
module Single_Cycle_CPU(
	input clk, reset
);

logic [31:0] instruction;
logic [63:0] address;


//IFetch + PCounter
logic [4:0] Rd, Rm, Rn;
logic [2:0] ALU_Operation;//cntrl in alu.sv
logic Reg2Loc, ALUSrc, MemToReg, RegWrite, MemWrite, BrTaken, UncondBr, UseImm, Reg2BLT, ALUBLT;

//ALU Logic
logic negative, zero, overflow, carry_out;//Note: Zero Flag is used for CBZ | Negative Flag is used for B.LT
logic [63:0] ALU_Result;

//Mux Reg2Loc
logic [4:0] RmRnOutput;

//Entend DAddr and ALUImm
logic [63:0] DAddrExtend, ALUImmExtend;

//Extend CondAddr
logic [63:0] CondAddrExtend;

//Mux UseImm
logic [63:0] DAddrALUImmResult;

//Mux ALUBLT
logic [63:0] DAddrALUImmCondAddrResult;

//Mux ALUSrc
logic [63:0] DAddrALUImmCondAddrDbResult;

//Data Memory
logic [63:0] Dout;

//Mux MemToReg
logic [63:0] MemToRegResult;

//negative flag from last clk cycle. 
logic DFF_Neg;
D_FF NegFlag (.q(DFF_Neg), .d(negative), .reset, .clk);


//Instruction Fetch + PC ------------------------------->
ProgramCounter PC(.clk, .UncondBr, .BrTaken, .reset, .instruction, .address);
instructmem instrmem(.address, .instruction, .clk);
Opcode_Decoder OP_Decoder(.instruction, .zero, .negative(DFF_Neg), .Rd, .Rm, .Rn, .ALU_Operation, .Reg2Loc, .ALUSrc, .MemToReg, .RegWrite, .MemWrite, .BrTaken, .UncondBr, .UseImm, .Reg2BLT, .ALUBLT);



//DataPath --------------------------------------------->

//Mux Reg2Loc
Mux_2_1_XBits #(.WIDTH(5)) RmRnOutputs(.in0(Rd), .in1(Rm), .out(RmRnOutput), .sel(Reg2Loc));

//RegFile
logic [63:0] Da, Db;
regfile RegFile(
 .ReadRegister1(Rn),
 .ReadRegister2(RmRnOutput),
 .WriteRegister(Rd),
 .WriteData(MemToRegResult),
 .RegWrite(RegWrite),
 .clk(clk),
 .ReadData1(Da),
 .ReadData2(Db));

//Entend DAddr and ALUImm
SignExtender #(.InputBits(9)) DAddr9(.in(instruction[20:12]), .out(DAddrExtend));
ZeroExtender #(.InputBits(12)) ALUImmExtended(.in(instruction[21:10]), .out(ALUImmExtend));

//Extend CondAddr
SignExtender #(.InputBits(19)) CondAddr(.in(instruction[23:5]), .out(CondAddrExtend));


//Mux UseImm
Mux_2_1_XBits #(.WIDTH(64)) MuxUseImm(.in0(DAddrExtend), .in1(ALUImmExtend), .out(DAddrALUImmResult), .sel(UseImm));

//Mux ALUBLT
Mux_2_1_XBits #(.WIDTH(64)) MuxALUBLT(.in0(DAddrALUImmResult), .in1(CondAddrExtend), .out(DAddrALUImmCondAddrResult), .sel(ALUBLT));


Mux_2_1_XBits #(.WIDTH(64)) DAddrALUImmCondAddrDbResults(.in0(Db), .in1(DAddrALUImmCondAddrResult), .out(DAddrALUImmCondAddrDbResult), .sel(ALUSrc));

//ALU
alu ALU_(.A(Da), .B(DAddrALUImmCondAddrDbResult), .cntrl(ALU_Operation), .result(ALU_Result), .negative, .zero, .overflow, .carry_out); 

//Mux ALUSrc
datamem DataMemory(.address(ALU_Result), .write_enable(MemWrite), .read_enable( 1'b1), .write_data(Db), .clk, .xfer_size(4'd8), .read_data(Dout));// xfer_size  controls the number of bytes that the data memory module reads/writes during each memory access

//Mux MemToReg
Mux_2_1_XBits #(.WIDTH(64)) MemToRegResults(.in0(ALU_Result), .in1(Dout), .out(MemToRegResult), .sel(MemToReg));





endmodule





module Single_Cycle_CPU_tb();
	
	
	logic 				clk, reset;
	logic negative, zero, overflow, carry_out;//Note: Zero Flag is used for CBZ | Negative Flag is used for B.LT
	logic [63:0] ALU_Result;

	Single_Cycle_CPU dut (.clk, .reset);
	alu ALU_(.A(64'b1), .B(64'b0), .cntrl(3'b000), .result(ALU_Result), .negative, .zero, .overflow, .carry_out); 
	
	// Clock setup
	parameter clock_period = 200000;

	initial begin
		clk = 0;
		forever #(clock_period / 2) clk <= ~clk;	
	end 



	initial begin
		
		reset = 1'b1;
		@(posedge clk);
		reset = 1'b0;
		repeat(50) @(posedge clk);
		
		$stop;
		
	end
endmodule

