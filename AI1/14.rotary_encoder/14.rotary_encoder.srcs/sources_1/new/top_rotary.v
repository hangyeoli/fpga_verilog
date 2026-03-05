`timescale 1ns / 1ps

module top_rotary(
    input clk,
    input reset,
    input s1,
    input s2,
    input key,
    output [15:0] led
    );

    wire w_clean_s1, w_clean_s2, w_clean_key;

    debouncer #(.DEBOUNCE_LIMIT(200_000)) u_s1_debouncer (
        .clk(clk),
        .reset(reset),
        .noisy_btn(s1),
        .clean_btn(w_clean_s1)
    );

    debouncer #(.DEBOUNCE_LIMIT(200_000)) u_s2_debouncer (
        .clk(clk),
        .reset(reset),
        .noisy_btn(s2),
        .clean_btn(w_clean_s2)
    );

    debouncer #(.DEBOUNCE_LIMIT(999_999)) u_key_debouncer (
        .clk(clk),
        .reset(reset),
        .noisy_btn(key),
        .clean_btn(w_clean_key)
    );

    rotary u_rotary (
        .clk(clk),
        .reset(reset),
        .clean_s1(w_clean_s1),
        .clean_s2(w_clean_s2),
        .clean_key(w_clean_key),
        .led(led)
    );
endmodule

module debouncer #(
    parameter integer DEBOUNCE_LIMIT = 20'd999_999
)(
    input  wire clk,
    input  wire reset,
    input  wire noisy_btn,
    output reg  clean_btn
);

    reg btn_ff0;
    reg btn_ff1;
    reg [19:0] db_cnt;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            btn_ff0 <= 1'b0;
            btn_ff1 <= 1'b0;
        end else begin
            btn_ff0 <= noisy_btn;
            btn_ff1 <= btn_ff0;
        end
    end

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            clean_btn <= 1'b0;
            db_cnt    <= 20'd0;
        end else begin
            if (btn_ff1 == clean_btn) begin
                db_cnt <= 20'd0;
            end else if (db_cnt < DEBOUNCE_LIMIT) begin
                db_cnt <= db_cnt + 20'd1;
            end else begin
                clean_btn <= btn_ff1;
                db_cnt    <= 20'd0;
            end
        end
    end

endmodule
