`timescale 1ns / 1ps

module btn_debouncer #(
    parameter integer DEBOUNCE = 20'd999_999
)(
    input  wire clk,
    input  wire reset,
    input  wire btn_in,
    output reg  pulse,
    output reg  level
);

    reg btn_ff0;
    reg btn_ff1;
    reg [19:0] db_cnt;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            btn_ff0 <= 1'b0;
            btn_ff1 <= 1'b0;
        end else begin
            btn_ff0 <= btn_in;
            btn_ff1 <= btn_ff0;
        end
    end

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            level  <= 1'b0;
            pulse  <= 1'b0;
            db_cnt <= 20'd0;
        end else begin
            pulse <= 1'b0;

            if (btn_ff1 == level) begin
                db_cnt <= 20'd0;
            end else if (db_cnt < DEBOUNCE) begin
                db_cnt <= db_cnt + 20'd1;
            end else begin
                level <= btn_ff1;
                db_cnt <= 20'd0;
                if (btn_ff1)
                    pulse <= 1'b1;
            end
        end
    end

endmodule
