`timescale 1ns/1ps
module FullAdd(
input logic A, B, Cin,
output logic Sum, Cout
);


	assign Cout = (A&B) | (B&Cin) | (A&Cin);
	assign Sum = (A&~B&~Cin) | (~A&B&~Cin) | (~A&~B&Cin) | (A&B&Cin);




endmodule