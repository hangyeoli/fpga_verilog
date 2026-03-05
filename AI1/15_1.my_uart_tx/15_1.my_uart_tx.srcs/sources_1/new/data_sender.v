`timescale 1ns / 1ps

module data_sender(
    input clk,
    input reset,
    input btn_start,
    input [7:0] send_data,
    input tx_busy,
    input tx_done,
    output reg tx_start,
    output reg [7:0] tx_data
);

    reg btn_start_d;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            btn_start_d <= 1'b0;
            tx_start <= 1'b0;
            tx_data <= 8'h00;
        end else begin
            btn_start_d <= btn_start;
            tx_start <= 1'b0;

            if (btn_start && !btn_start_d && !tx_busy) begin
                tx_start <= 1'b1;
                tx_data <= send_data;
            end
        end
    end

endmodule
