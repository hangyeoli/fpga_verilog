`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/02/11 15:23:00
// Design Name: 
// Module Name: decoder
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


// module decoder(
//     input [1:0] a,
//     output [3:0] led
//     );
//     assign led = (a==2'b00) ? 4'b0001 : 
//                  (a==2'b01) ? 4'b0010 :
//                  (a==2'b10) ? 4'b0100 : 4'b1000;   
// endmodule

module decoder(
    input  [1:0] a,
    output reg [3:0] led   // ★ reg로 변경
);

    always @(*) begin
        if (a == 2'b00)      led = 4'b0001;
        else if (a == 2'b01) led = 4'b0010;
        else if (a == 2'b10) led = 4'b0100;
        else                 led = 4'b1000;
    end
endmodule
