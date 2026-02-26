`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/02/11 16:17:32
// Design Name: 
// Module Name: encoder
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


module encoder(
    input  [3:0] d,
    output reg [1:0] a
);

    always @(*) begin
        if (d[3])      a = 2'b11;
        else if (d[2]) a = 2'b10;
        else if (d[1]) a = 2'b01;
        else if (d[0]) a = 2'b00;
        else           a = 2'b00;   // 입력이 모두 0일 때
    end

endmodule
