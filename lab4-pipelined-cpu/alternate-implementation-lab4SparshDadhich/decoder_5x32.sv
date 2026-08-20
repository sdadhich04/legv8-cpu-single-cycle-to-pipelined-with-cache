`timescale 1ns/10ps
module decoder_5x32(dec_in, enable, dec_out);
	input logic [4:0] dec_in;
	input logic enable;
	output logic [31:0] dec_out;
	
	logic [7:0] dec1_out, dec2_out, dec3_out, dec4_out, dec5_out;
	
	decoder_3x8 dec1( {1'b0, dec_in[4], dec_in[3]}, enable, dec1_out);
	decoder_3x8 dec2( {dec_in[2],dec_in[1],dec_in[0]}, dec1_out[0], dec2_out);
	decoder_3x8 dec3( {dec_in[2],dec_in[1],dec_in[0]}, dec1_out[1], dec3_out);
	decoder_3x8 dec4( {dec_in[2],dec_in[1],dec_in[0]}, dec1_out[2], dec4_out);
	decoder_3x8 dec5( {dec_in[2],dec_in[1],dec_in[0]}, dec1_out[3], dec5_out);
	assign dec_out = {dec5_out,dec4_out,dec3_out, dec2_out};
	
endmodule

module decoder_5x32_tb();
	logic [4:0] dec_in;
	logic enable, clock;
	logic [31:0] dec_out;
	integer inc_en, inc_dec_in;

	decoder_5x32 dut(dec_in, enable, dec_out);
	
	parameter clock_period = 100;

	initial begin
			clock <= 0;
			forever #(clock_period /2) clock <= ~clock;
	end
	
	initial begin
		//Test sequence for an and gate truth table
		for(inc_en=0; inc_en<2; inc_en++) begin
			  enable = inc_en;
			  for(inc_dec_in=0; inc_dec_in<32; inc_dec_in++) begin
					dec_in = inc_dec_in; @(posedge clock);
			  end
		end
		$stop;
	end
endmodule