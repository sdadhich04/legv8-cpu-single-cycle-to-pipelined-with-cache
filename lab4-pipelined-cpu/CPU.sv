`timescale 1ns/1ps //D_FF_XBits #(.WIDTH()) dut(.d(), .q(), .reset, .clk);
module CPU(
	input clk, reset
);






//logic variables


//Instruction Fetch------------------------------------------>

//BrTaken Mux
logic [63:0] BrTakenOut;

//+4 adder | Adder doesn't use the flags
logic [3:0] unused_flags_plus4;
logic [63:0] PC_add4;

//Branch Regsiter (BR)
logic [63:0] PC_input;

//Branch Regsiter 4_1 mux hazard prevention
logic [63:0] BranchRegister_Hazard_Mux_out;

//PC
logic [63:0] address;

//Instruction Mem
logic [31:0] instruction;

//Pipeline Registers
logic [63:0] PC_add4_IF_ID, address_IF_ID;
logic [31:0] instruction_IF_ID;


//RegFile--------------------------------------------------->

wire [4:0] Rd, Rn, Rm;

assign Rd = instruction_IF_ID[4:0];
assign Rm = instruction_IF_ID[20:16];
assign Rn = instruction_IF_ID[9:5];

//Control
logic [2:0] ALU_Operation;
logic Reg2Loc, ALUSrc, MemToReg, RegWrite, MemWrite, BrTaken, UncondBr, UseImm, BLT, BranchLink, BranchRegsiter, MemRead, CBZBranch;

//RegFile
logic [63:0] Da_IF_ID, Db_IF_ID;

//Regfile Muxes
logic [4:0] Reg2Loc_Mux_Out, BranchLink_Mux1_Out;

//BLT_FlagRegister
logic Negative, Overflow;

//isZero (readData2)
logic [63:0] Db_zero_IF_ID;

//Sign Extender
logic [63:0] CondAddr, BrAddr, Alu_Imm, DAddr;

//shifter
logic [63:0] MultipliedValue;

//branch addr
logic [3:0] unused_flags_branch_USELESS;
logic [63:0] BranchVal_IF_ID;

//BranchLnk Mux 2
logic [63:0] BranchLink_Mux2_Out;

//BranchingMux
logic [63:0] UseImm_out, UncondBr_out;

//ID/EX pipeline
logic [63:0] Da_ID_EX, Db_ID_EX, ALUBLT_out_ID_EX;
logic [4:0] Rd_ID_EX, Rn_ID_EX, Rm_ID_EX;
logic [2:0] ALU_Operation_ID_EX;
logic MemToReg_ID_EX, RegWrite_ID_EX, MemRead_ID_EX, MemWrite_ID_EX, ALUSrc_ID_EX;


//Alu---------------------------------------->

//ForwardingUnit
logic ForwardC, ForwardE, ForwardG;
logic[1:0] ForwardA, ForwardB, ForwardD, ForwardF;

//ForwardA_Mux //ForwardB_Mux 
logic [63:0] ForwardA_out, ForwardB_out, ForwardG_out;

//AluSrc_Mux
logic [63:0] AluSrc_out;

//Alu
logic [63:0] ALU_Result;
logic [3:0] ALU_Flags;

//Pipeline
logic MemToReg_EX_MEM, RegWrite_EX_MEM, MemRead_EX_MEM, MemWrite_EX_MEM;
logic [4:0] Rd_EX_MEM;
logic [63:0] ALU_Result_EX_MEM, Din_EX_MEM; 


//DataMemory---------------------------------------->


//DataMemory module
logic [63:0] read_data;

//pipeline
logic MemToReg_MEM_WB, RegWrite_MEM_WB;
logic [4:0] Rd_MEM_WB;
logic [63:0] read_data_MEM_WB, ALU_Result_MEM_WB;


//WriteBack---------------------------------------->

//MemToReg_Mux
logic [63:0] MemToReg_out;




//Module Instantiation




//Instruction Fetch --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------->


//BrTaken Mux
Mux_2_1_XBits BrTaken_Mux (.in0(PC_add4), .in1(BranchVal_IF_ID), .out(BrTakenOut), .sel(BrTaken));

//+4 addr
alu addFour (.A(address), .B(64'd4), .cntrl(3'b010), .result(PC_add4),
 .negative(unused_flags_plus4[0]), .zero(unused_flags_plus4[1]), .overflow(unused_flags_plus4[2]), .carry_out(unused_flags_plus4[3]));

//Stall
//Mux_2_1_XBits Stall_Mux (.in0(BrTakenOut), .in1(PC_Zero), .out(stallOut), .sel(stall));

//Branch Regsiter (BR)
Mux_2_1_XBits BranchRegister_Mux (.in0(BrTakenOut), .in1(BranchRegister_Hazard_Mux_out), .out(PC_input), .sel(BranchRegsiter));


//Branch Regsiter 4_1 mux hazard prevention
Mux_4_1_XBit	 BranchRegister_Hazard_Mux (.in0(Db_IF_ID), .in1(ALU_Result), .in2(ForwardG_out), .in3(64'd0), .out(BranchRegister_Hazard_Mux_out), .sel(ForwardD));

//PC
D_FFx64 PC(.d(PC_input), .q(address), .reset, .clk);

//Instruction Mem
instructmem instrmem(.address, .instruction, .clk);

//IF_ID Pipeline
D_FF_XBits dut_PC_add4(.d(PC_add4), .q(PC_add4_IF_ID), .reset, .clk);//PC_add4_IF_ID
D_FF_XBits address_DFF(.d(address), .q(address_IF_ID), .reset, .clk);//address_IF_ID
D_FF_XBits #(.WIDTH(32)) instruction_register(.d(instruction), .q(instruction_IF_ID), .reset, .clk);//instruction_IF_ID

//Instruction Decode (RegFile) ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------->



//Control
Opcode_Decoder decoder_inst (
        .instruction(instruction_IF_ID),
        .zero(Db_zero_IF_ID), .negative(Negative), .Overflow(Overflow),
        .ALU_Operation(ALU_Operation),
        .Reg2Loc(Reg2Loc), .ALUSrc(ALUSrc), .MemToReg(MemToReg), .RegWrite(RegWrite),
		  .MemWrite(MemWrite), .BrTaken(BrTaken), .UncondBr(UncondBr), .UseImm(UseImm), 
		  .BLT(BLT), .BranchLink(BranchLink), .BranchRegsiter(BranchRegsiter), .MemRead(MemRead), .CBZBranch(CBZBranch)
);

//Hazard Detection (Load Hazard) 
//HazardDetection HazardDetectionUnit(.Rm(Rm), .Rn(Rn), .ID_EX_Rd, .ID_EX_MEM_Read, .stall(stall));

//register file
regfile RegFile(
 .ReadRegister1(Rn),
 .ReadRegister2(Reg2Loc_Mux_Out),
 .WriteRegister(Rd_MEM_WB),
 .WriteData(MemToReg_out),
 .RegWrite(RegWrite_MEM_WB),
 .clk(~clk),
 .ReadData1(Da_IF_ID),
 .ReadData2(Db_IF_ID)
);

logic [63:0] ForwardF_out;

Mux_4_1_XBit CBZMux(.in0(Db_IF_ID), .in1(ALU_Result), .in2(ALU_Result_EX_MEM), .in3(64'd0), .out(ForwardF_out), .sel(ForwardF));

//CBZ ReadData2
isZero test(.in(ForwardF_out), .out(Db_zero_IF_ID));

//Reg2Loc Mux
Mux_2_1_XBits #(.WIDTH(5)) Reg2Loc_Mux (.in0(Rd), .in1(Rm), .out(Reg2Loc_Mux_Out), .sel(Reg2Loc));

//BranchLink Mux 1
Mux_2_1_XBits #(.WIDTH(5)) BranchLink_Mux1 (.in0(Rd), .in1(5'd30), .out(BranchLink_Mux1_Out), .sel(BranchLink));




//------------------------------------------------------------------------------------------Regfile Branching------>
//Sign Extender
SignExtender #(.InputBits(19)) CondAddr19_SignExtend(.in(instruction_IF_ID[23:5]), .out(CondAddr)); //Cond_Addr19
SignExtender #(.InputBits(9)) DAddr_9_SignExtend(.in(instruction_IF_ID[20:12]), .out(DAddr)); //DAddr_9
SignExtender #(.InputBits(12)) Alu_Imm_SignExtend(.in(instruction_IF_ID[21:10]), .out(Alu_Imm)); //BrAddr
SignExtender #(.InputBits(26)) BrAddr_SignExtend(.in(instruction_IF_ID[25:0]), .out(BrAddr)); //BrAddr

//BranchingMux

Mux_2_1_XBits #(.WIDTH(64)) UseImm_Mux (.in0(DAddr), .in1(Alu_Imm), .out(UseImm_out), .sel(UseImm));//UseImm_Mux
Mux_2_1_XBits #(.WIDTH(64)) UncondBr_Mux (.in0(CondAddr), .in1(BrAddr), .out(UncondBr_out), .sel(UncondBr));//UncondBr_Mux


shifter MultiplyFour(.value(UncondBr_out), .direction(1'b0), .distance(6'd2), .result(MultipliedValue));


//branch adder
alu addBranch (.A(MultipliedValue), .B(address_IF_ID), .cntrl(3'b010), .result(BranchVal_IF_ID), 
.negative(unused_flags_branch_USELESS[0]), .zero(unused_flags_branch_USELESS[1]), 
.overflow(unused_flags_branch_USELESS[2]), .carry_out(unused_flags_branch_USELESS[3]));//BranchVal_IF_ID

//------------------------------------------------------------------------------------------Regfile Branching------>



//ID/EX pipeline
logic [63:0] PC_add4_ID_EX;
D_FF_XBits #(.WIDTH(64)) PC_add4_(.d(PC_add4_IF_ID), .q(PC_add4_ID_EX), .reset, .clk);//PC_add4_ID_EX
D_FF_XBits #(.WIDTH(64)) dut_ID_EX1(.d(Da_IF_ID), .q(Da_ID_EX), .reset, .clk);//Da_ID_EX//
D_FF_XBits #(.WIDTH(64)) dut_ID_EX2(.d(Db_IF_ID), .q(Db_ID_EX), .reset, .clk);//Db_ID_EX//
D_FF_XBits #(.WIDTH(64)) dut_ID_EX3(.d(UseImm_out), .q(ALUBLT_out_ID_EX), .reset, .clk);//ALUBLT_out_ID_EX//
D_FF_XBits #(.WIDTH(5)) dut_ID_EX4(.d(BranchLink_Mux1_Out), .q(Rd_ID_EX), .reset, .clk);//Rd_ID_EX//
D_FF_XBits #(.WIDTH(5)) dut_ID_EX5(.d(Rn), .q(Rn_ID_EX), .reset, .clk);//Rn_ID_EX//
D_FF_XBits #(.WIDTH(5)) dut_ID_EX6(.d(Rm), .q(Rm_ID_EX), .reset, .clk);//Rm_ID_EX//

logic BranchLink_ID_EX;
//cntrl pipeline
D_FF_XBits #(.WIDTH(1)) dut_ID_EX7(.d(MemToReg), .q(MemToReg_ID_EX), .reset, .clk);//MemToReg_ID_EX//
D_FF_XBits #(.WIDTH(1)) dut_ID_EX8(.d(RegWrite), .q(RegWrite_ID_EX), .reset, .clk);//RegWrite_ID_EX//
D_FF_XBits #(.WIDTH(1)) dut_ID_EX9(.d(MemRead), .q(MemRead_ID_EX), .reset, .clk);//MemRead_ID_EX//
D_FF_XBits #(.WIDTH(1)) dut_ID_EX10(.d(MemWrite), .q(MemWrite_ID_EX), .reset, .clk);//MemWrite_ID_EX//
D_FF_XBits #(.WIDTH(1)) dut_ID_EX11(.d(ALUSrc), .q(ALUSrc_ID_EX), .reset, .clk);//ALUSrc_ID_EX//
D_FF_XBits #(.WIDTH(1)) dut_ID_EX12(.d(BranchLink), .q(BranchLink_ID_EX), .reset, .clk);//BranchLink_ID_EX//
D_FF_XBits #(.WIDTH(3)) dut_ID_EX13(.d(ALU_Operation), .q(ALU_Operation_ID_EX), .reset, .clk);//ALU_Operation_ID_EX//





//Executable Address Calc (ALU)----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------->

ForwardingUnit forwardUnit(.ID_EX_Rn(Rn_ID_EX), .ID_EX_Rm(Rm_ID_EX), .MEM_WB_Rd(Rd_MEM_WB), .EX_MEM_Rd(Rd_EX_MEM), .ID_EX_RD(Rd_ID_EX), .ID_RT(Rd),
 .EX_MEM_RegWrite(RegWrite_EX_MEM), .MEM_WB_RegWrite(RegWrite_MEM_WB), .BranchRegister(BranchRegsiter), .MemWrite_EX_MEM(MemWrite_EX_MEM), .MemWrite_ID_EX(MemWrite_ID_EX), .CBZBranch(CBZBranch), .MemRead_EX_MEM(MemRead_EX_MEM), 
 .ForwardA(ForwardA), .ForwardB(ForwardB), .ForwardD(ForwardD), .ForwardF(ForwardF), .ForwardC(ForwardC), .ForwardE(ForwardE), .ForwardG(ForwardG));


Mux_4_1_XBit ForwardA_Mux(.in0(Da_ID_EX), .in1(MemToReg_out), .in2(ALU_Result_EX_MEM), .in3(64'd0),
 .out(ForwardA_out), .sel(ForwardA));


Mux_4_1_XBit ForwardB_Mux(.in0(Db_ID_EX), .in1(MemToReg_out), .in2(ALU_Result_EX_MEM), .in3(64'd0),
 .out(ForwardB_out), .sel(ForwardB));


Mux_2_1_XBit AluSrc_Mux(.in0(ForwardB_out), .in1(ALUBLT_out_ID_EX), .out(AluSrc_out), .sel(ALUSrc_ID_EX));



//ALU_Flags 0 = negative, 2 = zero, 1 = overflow, 3 = carry_out
//ALU
alu ALU_(.A(ForwardA_out), .B(AluSrc_out), .cntrl(ALU_Operation_ID_EX), .result(ALU_Result), 
.negative(ALU_Flags[0]), .zero(ALU_Flags[2]), .overflow(ALU_Flags[1]), .carry_out(ALU_Flags[3])); 

//Branch Link Mux 2
Mux_2_1_XBits #(.WIDTH(64)) BranchLink_Mux2 (.in0(ALU_Result), .in1(PC_add4_ID_EX), .out(BranchLink_Mux2_Out), .sel(BranchLink_ID_EX));


//flag register 
BLT_FlagRegister flagRegister(
	 .ALU_Flags(ALU_Flags),
    .AluSrc(ALUSrc_ID_EX),
    .reset(reset),
    .clk(clk),
    .Negative(Negative),
    .Overflow(Overflow)
);

//Forward E
logic [63:0] ForwardE_out;
Mux_2_1_XBit ForwardE_Mux(.in0(Db_ID_EX), .in1(MemToReg_out), .out(ForwardE_out), .sel(ForwardE));

//Cntl Pipeline
D_FF_XBits #(.WIDTH(1)) dut_EX_MEM1(.d(MemToReg_ID_EX), .q(MemToReg_EX_MEM), .reset, .clk);//MemToReg_EX_MEM//
D_FF_XBits #(.WIDTH(1)) dut_EX_MEM2(.d(RegWrite_ID_EX), .q(RegWrite_EX_MEM), .reset, .clk);//RegWrite_EX_MEM//
D_FF_XBits #(.WIDTH(1)) dut_EX_MEM3(.d(MemRead_ID_EX), .q(MemRead_EX_MEM), .reset, .clk);//MemRead_EX_MEM//
D_FF_XBits #(.WIDTH(1)) dut_EX_MEM4(.d(MemWrite_ID_EX), .q(MemWrite_EX_MEM), .reset, .clk);//MemWrite_EX_MEM//

//Ex_Mem Pipeline
D_FF_XBits #(.WIDTH(64)) dut_EX_MEM5(.d(BranchLink_Mux2_Out), .q(ALU_Result_EX_MEM), .reset, .clk);//ALU_Result_EX_MEM//
D_FF_XBits #(.WIDTH(64)) dut_EX_MEM6(.d(ForwardE_out), .q(Din_EX_MEM), .reset, .clk);//Din_EX_MEM//
D_FF_XBits #(.WIDTH(5)) dut_EX_MEM7(.d(Rd_ID_EX), .q(Rd_EX_MEM), .reset, .clk);//Rd_EX_MEM//

//MEM ---------------------------------------------------------------------------------------------------------------------------------------->

//Forward C
logic [63:0] ForwardC_out;

Mux_2_1_XBit ForwardC_Mux(.in0(Din_EX_MEM), .in1(MemToReg_out), .out(ForwardC_out), .sel(ForwardC));

datamem DataMemory(.address(ALU_Result_EX_MEM), .write_enable(MemWrite_EX_MEM), .read_enable(MemRead_EX_MEM),
 .write_data(ForwardC_out), .clk, .xfer_size(4'd8), .read_data(read_data)
);// xfer_size  controls the number of bytes that the data memory module reads/writes during each memory access

Mux_2_1_XBit ForwardG_Mux(.in0(ALU_Result_EX_MEM), .in1(read_data), .out(ForwardG_out), .sel(ForwardG));
 
D_FF_XBits #(.WIDTH(1)) dut_MEM_WB1(.d(MemToReg_EX_MEM), .q(MemToReg_MEM_WB), .reset, .clk);//MemToReg_MEM_WB//
D_FF_XBits #(.WIDTH(1)) dut_MEM_WB2(.d(RegWrite_EX_MEM), .q(RegWrite_MEM_WB), .reset, .clk);//RegWrite_MEM_WB//

//Data Memory
D_FF_XBits #(.WIDTH(64)) dut_MEM_WB3(.d(read_data), .q(read_data_MEM_WB), .reset, .clk);//read_data_MEM_WB//
D_FF_XBits #(.WIDTH(64)) dut_MEM_WB4(.d(ALU_Result_EX_MEM), .q(ALU_Result_MEM_WB), .reset, .clk);//ALU_Result_MEM_WB//
D_FF_XBits #(.WIDTH(5)) dut_MEM_WB5(.d(Rd_EX_MEM), .q(Rd_MEM_WB), .reset, .clk);//Rd_MEM_WB//


//Writeback ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------->

//MemToReg_Mux
Mux_2_1_XBits #(.WIDTH(64)) MemToReg_Mux(.in0(ALU_Result_MEM_WB), .in1(read_data_MEM_WB), .out(MemToReg_out), .sel(MemToReg_MEM_WB));




endmodule




//testbench
module CPU_tb();
	
	
	logic 				clk, reset;
	

	CPU dut (.clk(clk), .reset(reset));
	
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
		repeat(400) @(posedge clk);//change depending on file
		
		$stop;
		
	end
endmodule

