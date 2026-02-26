`timescale 1ns / 1ps
// 1010111

module shift_register(
    input clk,
    input reset,    // SW15
    input btnU,     // 1 input
    input btnD,     // 0 input
    output [15:0] led
);

reg [6:0] sr7;
reg btnU_d;
reg btnD_d;
wire btnU_rise;
wire btnD_rise;
wire match;

assign btnU_rise = btnU & ~btnU_d;
assign btnD_rise = btnD & ~btnD_d;

always @(posedge clk or posedge reset) begin
    if (reset) begin
        sr7 <= 7'b0000000;
        btnU_d <= 1'b0;
        btnD_d <= 1'b0;
    end else begin
        btnU_d <= btnU;
        btnD_d <= btnD;

        if (btnU_rise) begin
            sr7 <= {sr7[5:0], 1'b1}; // shift in 1
        end else if (btnD_rise) begin
            sr7 <= {sr7[5:0], 1'b0}; // shift in 0
        end
    end
end

assign match = (sr7 == 7'b1010111);
assign led[7:1] = sr7;      // show shift register on LED1~LED7
assign led[0] = match;      // turn on LED0 when pattern matched
assign led[15:8] = 8'b0;

endmodule