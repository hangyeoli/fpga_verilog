`timescale 1ns / 1ps

module clock_80Hz(
    input  i_clk,    // 100MHz
    input  i_reset,  // reset
    output reg o_clk  // 80Hz (토글)
);

    reg [$clog2(1250000)-1:0] r_counter = 0;

    always @(posedge i_clk, posedge i_reset) begin
        if (i_reset) begin
            r_counter <= 0;
            o_clk <= 0;
        end else begin
            if (r_counter == (1_250_000/2)-1) begin
                r_counter <= 0;
                o_clk <= ~o_clk;
            end else begin
                r_counter <= r_counter + 1;
            end
        end
    end

endmodule
