`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/02/11 10:22:13
// Design Name: 
// Module Name: adder1
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

// adder1.v
module adder1(
    input  a,
    input  b,
    input  cin,
    output sum,
    output carry_out
);

assign sum       = a ^ b ^ cin;
assign carry_out = (a & b) | (a & cin) | (b & cin);

endmodule
