`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/02/11 09:41:16
// Design Name: 
// Module Name: adder4
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

module adder4(
    input  [3:0] a,
    input  [3:0] b,
    input        cin,
    output [3:0] sum,
    output       carry_out
);

wire w_carry0, w_carry1, w_carry2;

adder1 FA0 (
    .a(a[0]),
    .b(b[0]),
    .cin(cin),          
    .sum(sum[0]),
    .carry_out(w_carry0)
);

adder1 FA1 (
    .a(a[1]),
    .b(b[1]),
    .cin(w_carry0),
    .sum(sum[1]),
    .carry_out(w_carry1)
);

adder1 FA2 (
    .a(a[2]),
    .b(b[2]),
    .cin(w_carry1),
    .sum(sum[2]),
    .carry_out(w_carry2)
);

adder1 FA3 (
    .a(a[3]),
    .b(b[3]),
    .cin(w_carry2),
    .sum(sum[3]),
    .carry_out(carry_out)
);

endmodule
