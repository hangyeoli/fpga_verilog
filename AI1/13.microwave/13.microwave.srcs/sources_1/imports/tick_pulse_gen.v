`timescale 1ns / 1ps

module tick_pulse_gen #(
    parameter integer COUNT_MAX = 100_000
)(
    input  wire clk,
    input  wire reset,
    output reg  tick
);

    reg [$clog2(COUNT_MAX)-1:0] cnt;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            cnt  <= {($clog2(COUNT_MAX)){1'b0}};
            tick <= 1'b0;
        end else if (cnt == COUNT_MAX - 1) begin
            cnt  <= {($clog2(COUNT_MAX)){1'b0}};
            tick <= 1'b1;
        end else begin
            cnt  <= cnt + 1'b1;
            tick <= 1'b0;
        end
    end

endmodule
