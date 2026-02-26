`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/02/11 10:24:28
// Design Name: 
// Module Name: tb_adder4
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


module tb_adder4(

);
    reg [3:0] a; 
    reg [3:0] b;
    reg cin; // 1bit
    wire [3:0] sum; 
    wire carry_out;

    adder4 dut (
        .a(a),
        .b(b),
        .cin(cin), // 1bit
        .sum(sum),
        .carry_out(carry_out)
    );

    initial begin
        #00 a=0; b=0; cin=0;
        #10 a=0; b=2;
        #10 a=7; b=9;
        #10 a=9; b=9;
        #10 a=7; b=7;
        for (integer i=0; i < 20; i= i+1) begin
            #10 a=i;
            #10 $finish;
        end
    end
endmodule
