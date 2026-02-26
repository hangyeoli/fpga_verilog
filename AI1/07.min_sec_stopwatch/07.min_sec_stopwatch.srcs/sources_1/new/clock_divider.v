`timescale 1ns / 1ps

module clock_divider #(
    parameter integer CLK_HZ = 100_000_000
) (
    input  wire clk,
    input  wire reset,
    output reg  tick_10ms,
    output reg  tick_1ms
);

    localparam integer CNT_10MS_MAX = (CLK_HZ / 100) - 1;
    localparam integer CNT_1MS_MAX  = (CLK_HZ / 1000) - 1;

    reg [31:0] cnt_10ms;
    reg [31:0] cnt_1ms;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            cnt_10ms  <= 32'd0;
            cnt_1ms   <= 32'd0;
            tick_10ms <= 1'b0;
            tick_1ms  <= 1'b0;
        end else begin
            tick_10ms <= 1'b0;
            tick_1ms  <= 1'b0;

            if (cnt_10ms == CNT_10MS_MAX) begin
                cnt_10ms  <= 32'd0;
                tick_10ms <= 1'b1;
            end else begin
                cnt_10ms <= cnt_10ms + 32'd1;
            end

            if (cnt_1ms == CNT_1MS_MAX) begin
                cnt_1ms  <= 32'd0;
                tick_1ms <= 1'b1;
            end else begin
                cnt_1ms <= cnt_1ms + 32'd1;
            end
        end
    end

endmodule
