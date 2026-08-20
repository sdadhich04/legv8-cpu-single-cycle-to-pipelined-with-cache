`timescale 1ns/1ps
module isZero(
    input  logic [63:0] in,
    output logic        out
);

    logic tmp [0:64];
    assign tmp[0] = 1'b1;

    generate
        genvar i;
        for(i = 0; i < 64; i = i + 1) begin : zeroChecker
            assign tmp[i+1] = ~(in[i] | 1'b0) & tmp[i];
        end
    endgenerate

    //assign out = tmp[64];
	 and #50 out1(out, tmp[64], 1'b1);

endmodule
