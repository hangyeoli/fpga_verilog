`timescale 1ns / 1ps

module D_FF(
    input  i_clk,
    input  i_reset,
    input  D,
    output reg Q
);

    always @(posedge i_clk, posedge i_reset) begin
        if (i_reset) begin
            Q <= 1'b0;
        end else begin
            Q <= D;
        end
    end

endmodule
