module ZeroExtender #(parameter InputBits = 4)(
input logic [InputBits-1:0] in,
output logic [63:0] out
);

	assign out[InputBits-1:0] = in;

	genvar i;
	generate
		for(i = InputBits; i < 64; i = i + 1)begin  : ZeroExtend
			assign out[i] = 1'b0;
		end
	endgenerate


endmodule


module ZeroExtender_testbench();

	parameter ClockDelay = 5000;

	logic		[63:0]	out;
	logic clk;
	logic		[3:0]	in;
	
	ZeroExtender #(.InputBits(4)) dut(.in, .out);
	
	initial begin // Set up the clock
		clk <= 0;
		forever #(ClockDelay/2) clk <= ~clk;
	end
	
	integer i;
	initial begin
		in = 4'd1;
		@(posedge clk); 
		in = 4'b1011;
		@(posedge clk); 
		
		$stop;
		
	end
endmodule
