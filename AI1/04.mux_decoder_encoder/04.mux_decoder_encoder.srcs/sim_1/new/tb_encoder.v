`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/02/11 16:18:19
// Design Name: 
// Module Name: tb_encoder
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


module tb_encoder();
    reg  [3:0] d;
    wire [1:0] w_a;

    encoder u_encoder (
        .d(d),
        .a(w_a)
    );
    initial begin
        d = 4'b0000;
        #10; d = 4'b1000;
        #10; d = 4'b0100;
        #10; d = 4'b0010;
        #10; d = 4'b0001;
        #10; $finish;
    end
endmodule

