`timescale 1ns / 1ps

module fsm_mode_control(
    input  wire clk,
    input  wire reset,
    input  wire btn_left,
    output reg  mode_sw
);

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            mode_sw <= 1'b0;
        end else if (btn_left) begin
            mode_sw <= ~mode_sw;
        end
    end

endmodule
