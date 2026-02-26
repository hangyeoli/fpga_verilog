`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/02/11 13:05:15
// Design Name: 
// Module Name: add4_sub4
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


module add4_sub4(
    input [7:0] sw,
    input sel, // 1:add 0: sub
    output carry_out,
    output [3:0] sum
    );

    // assign {carry_out, sum[3:0]} = sw[3:0] + sw[7:4];
    assign {carry_out, sum[3:0]} = sel ? sw[3:0] + sw[7:4] :
                                        sw[3:0] + ~sw[7:4] +4'b1;

endmodule
