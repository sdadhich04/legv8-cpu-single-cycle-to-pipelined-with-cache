`timescale 1ns/1ps
//returns TRUE if number is zero
module isZero #(parameter WIDTH = 64)(
    input  logic [WIDTH-1:0] in,
    output logic        out
);

    logic tmp [0:WIDTH];
    assign tmp[0] = 1'b1;

    generate
        genvar i;
        for(i = 0; i < WIDTH; i = i + 1) begin : zeroChecker
            assign tmp[i+1] = ~(in[i] | 1'b0) & tmp[i];
        end
    endgenerate


	 and #50 out1(out, tmp[WIDTH], 1'b1);

endmodule
