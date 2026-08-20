`timescale 1ns/1ps
module ForwardingUnit(
input logic [4:0] ID_EX_Rn, ID_EX_Rm, MEM_WB_Rd, EX_MEM_Rd, ID_EX_RD, ID_RT,
input logic EX_MEM_RegWrite, MEM_WB_RegWrite, BranchRegister, MemWrite_EX_MEM, MemWrite_ID_EX, CBZBranch, MemRead_EX_MEM,
output logic [1:0] ForwardA, ForwardB, ForwardD, ForwardF,
output logic ForwardC, ForwardE, ForwardG
);


always_comb begin
	ForwardA = 2'b00;
	ForwardB = 2'b00;
	ForwardD = 2'b00;
	ForwardF = 2'b00;

	ForwardC = 1'b0;
	ForwardE = 1'b0;
	ForwardG = 1'b0;
	
	//Forward A
	if(EX_MEM_RegWrite && EX_MEM_Rd != 5'd31 && (EX_MEM_Rd == ID_EX_Rn))
		ForwardA = 2'b10;
	if(EX_MEM_RegWrite && EX_MEM_Rd != 5'd31 && (EX_MEM_Rd == ID_EX_Rm))
		ForwardB = 2'b10;
		
	//Forward B 
	if(MEM_WB_RegWrite && MEM_WB_Rd != 5'd31 &&
	~(EX_MEM_RegWrite && EX_MEM_Rd != 5'd31 && (EX_MEM_Rd == ID_EX_Rn)) && 
	MEM_WB_Rd == ID_EX_Rn)
		ForwardA = 2'b01;
		
	if(MEM_WB_RegWrite && MEM_WB_Rd != 5'd31 &&
	~(EX_MEM_RegWrite && EX_MEM_Rd != 5'd31 && (EX_MEM_Rd == ID_EX_Rm)) && 
	MEM_WB_Rd == ID_EX_Rm)
		ForwardB = 2'b01;
	
	
	//case D
	if(BranchRegister && (ID_EX_RD == ID_RT))begin
		ForwardD = 2'b01;
	end
	
	if(BranchRegister && (EX_MEM_Rd == ID_RT))begin
		ForwardD = 2'b10;
	end
	
	if((MemRead_EX_MEM) && BranchRegister && (EX_MEM_Rd == ID_RT))
			ForwardG = 1'b1;
	
	//Forward C
	if((MemWrite_EX_MEM) && (MEM_WB_Rd == EX_MEM_Rd) && (MEM_WB_Rd != 5'd31))
		ForwardC = 1'b1;
	
	//Forward E
	if((MemWrite_ID_EX) && (MEM_WB_Rd == ID_EX_RD) && (MEM_WB_Rd != 5'd31))
		ForwardE = 1'b1;
	
	
	//Forward F
	if((ID_RT == ID_EX_RD)  && (ID_EX_RD != 5'd31) && CBZBranch)
		ForwardF = 2'b01;
	
	if((ID_RT == EX_MEM_Rd)  && (ID_EX_RD != 5'd31) && CBZBranch)
		ForwardF = 2'b10;
end

endmodule


`timescale 1ns/1ps

module ForwardingUnit_tb();

    // Inputs
    logic [4:0] ID_EX_Rn, ID_EX_Rm, MEM_WB_Rd, EX_MEM_Rd;
    logic EX_MEM_RegWrite, MEM_WB_RegWrite;

    // Outputs
    logic [1:0] ForwardA, ForwardB;

    // Instantiate DUT
    ForwardingUnit dut (
        .ID_EX_Rn(ID_EX_Rn),
        .ID_EX_Rm(ID_EX_Rm),
        .MEM_WB_Rd(MEM_WB_Rd),
        .EX_MEM_Rd(EX_MEM_Rd),
        .EX_MEM_RegWrite(EX_MEM_RegWrite),
        .MEM_WB_RegWrite(MEM_WB_RegWrite),
        .ForwardA(ForwardA),
        .ForwardB(ForwardB)
    );


    initial begin


        // No forwarding (default)
        ID_EX_Rn = 5'd1;
        ID_EX_Rm = 5'd2;
        EX_MEM_Rd = 5'd0;
        MEM_WB_Rd = 5'd0;
        EX_MEM_RegWrite = 0;
        MEM_WB_RegWrite = 0;
        #500;


        // ForwardA from EX/MEM 10
        ID_EX_Rn = 5'd5;
        EX_MEM_Rd = 5'd5;
        EX_MEM_RegWrite = 1;
        MEM_WB_RegWrite = 0;
        #500;


        // ForwardB from EX/MEM 10
        ID_EX_Rm = 5'd10;
        EX_MEM_Rd = 5'd10;
        EX_MEM_RegWrite = 1;
        #500;


        // ForwardA from MEM/WB 01
        ID_EX_Rn = 5'd15;
        EX_MEM_Rd = 5'd0; // Different from ID_EX_Rn
        EX_MEM_RegWrite = 0;
        MEM_WB_Rd = 5'd15;
        MEM_WB_RegWrite = 1;
        #500;


        // ForwardB from MEM/WB 01
        ID_EX_Rm = 5'd20;
        MEM_WB_Rd = 5'd20;
        MEM_WB_RegWrite = 1;
        #500;


        // Do not forward if destination is XZR (reg 31)
        ID_EX_Rn = 5'd31;
        EX_MEM_Rd = 5'd31;
        MEM_WB_Rd = 5'd31;
        EX_MEM_RegWrite = 1;
        MEM_WB_RegWrite = 1;
        #500;

        $stop;
    end

endmodule
