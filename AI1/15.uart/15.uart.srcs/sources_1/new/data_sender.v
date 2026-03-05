`timescale 1ns / 1ps

module data_sender(
    input clk,                // 100 MHz
    input reset,              // SW15
    input start_trigger,      // send start pulse
    input [7:0] send_data,    // base byte ('0' = 8'h30)
    input tx_busy,            // UART TX busy
    input tx_done,            // UART TX done (unused here)
    output reg tx_start,      // UART TX start
    output reg [7:0] tx_data  // UART TX data
);

    reg [6:0] r_send_byte_cnt = 7'd0;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            tx_start <= 1'b0;
            tx_data <= 8'h30;
            r_send_byte_cnt <= 7'd0;
        end else begin
            if (start_trigger && !tx_busy) begin
                tx_start <= 1'b1;
                tx_data <= send_data + r_send_byte_cnt; // '0'..'9'

                if (r_send_byte_cnt == 7'd9) begin
                    r_send_byte_cnt <= 7'd0;
                end else begin
                    r_send_byte_cnt <= r_send_byte_cnt + 1'b1;
                end
            end else begin
                tx_start <= 1'b0;
            end
        end
    end

endmodule
