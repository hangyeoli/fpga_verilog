`timescale 1ns / 1ps

module button_debounce_onepulse #(
    parameter integer DEBOUNCE_MS = 20
) (
    input  wire clk,
    input  wire reset,
    input  wire sample_tick,
    input  wire btn_in,
    output reg  btn_pulse
);

    reg stable_btn;
    reg stable_btn_d;
    reg sampled_btn;
    reg [7:0] stable_cnt;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            stable_btn   <= 1'b0;
            stable_btn_d <= 1'b0;
            sampled_btn  <= 1'b0;
            stable_cnt   <= 8'd0;
            btn_pulse    <= 1'b0;
        end else begin
            btn_pulse <= 1'b0;

            if (sample_tick) begin
                sampled_btn <= btn_in;

                if (sampled_btn == stable_btn) begin
                    stable_cnt <= 8'd0;
                end else if (stable_cnt == DEBOUNCE_MS - 1) begin
                    stable_btn <= sampled_btn;
                    stable_cnt <= 8'd0;
                end else begin
                    stable_cnt <= stable_cnt + 8'd1;
                end

                stable_btn_d <= stable_btn;

                if (stable_btn && !stable_btn_d) begin
                    btn_pulse <= 1'b1;
                end
            end
        end
    end

endmodule
