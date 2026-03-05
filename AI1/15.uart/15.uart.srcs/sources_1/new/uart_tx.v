`timescale 1ns / 1ps


module uart_tx#(
    parameter BPS = 9600          // 보레이트 (예: 9600bps)
) (
    input clk,
    input reset,
    input [7:0] tx_data,
    input tx_start,
    output reg tx,
    output reg tx_done,
    output reg tx_busy
);
    parameter S_IDLE = 2'b00;
    parameter S_START_BIT = 2'b01;
    parameter S_DATA_8BITS = 2'b10;
    parameter S_STOP_BIT = 2'b11;
    parameter DIVIDER_CNT = 100_000_000 / BPS;

    reg [1:0] r_state;
    reg [3:0] r_bit_cnt;
    reg [7:0] r_data_reg;
    reg [15:0] r_baud_cnt; // 10416ns
    reg r_baud_tick;  // 10416ns마다 1 tick 발생

    // 10416ns 마다 1 tick 발생

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            r_baud_cnt <= 0;
            r_baud_tick <= 0;
        end else begin
            if (r_baud_cnt >= DIVIDER_CNT - 1) begin
                r_baud_cnt <= 0;
                r_baud_tick <= 1; // tick 발생
            end else begin
                r_baud_cnt <= r_baud_cnt + 1;
                r_baud_tick <= 0; // tick 비활성화
            end
        end
    end

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            r_state <= S_IDLE;
            r_bit_cnt <= 0;
            r_data_reg <= 0;
            tx_done <= 0;
            tx_busy <= 0;
            tx <= 1; // idle 상태에서는 tx 라인이 high
        end else begin
            case (r_state)
                S_IDLE: begin
                    tx_done <= 0;
                    if (tx_start) begin
                        r_state <= S_START_BIT;
                        r_data_reg <= tx_data; 
                        tx_busy <= 1'b1; 
                        r_bit_cnt <= 0;
                    end
                end
                S_START_BIT: begin
                    if(r_baud_tick) begin
                        tx <= 1'b0; // start bit는 low
                        r_state <= S_DATA_8BITS; // 데이터 비트 상태로 전환
                    end
                end
                S_DATA_8BITS: begin
                    if (r_baud_tick) begin
                        tx <= r_data_reg[r_bit_cnt]; // 데이터 비트 송신 (LSB부터)
                        if (r_bit_cnt == 4'd7) begin
                            r_state <= S_STOP_BIT; // 마지막 비트 송신 후 stop bit 상태로 전환
                        end else begin
                            r_bit_cnt <= r_bit_cnt + 1; // 다음 비트로 이동
                        end
                    end
                end
                S_STOP_BIT: begin
                    if (r_baud_tick) begin
                        tx <= 1'b1; // stop bit는 high
                        tx_done <= 1; // 송신 완료 신호 활성화
                        tx_busy <= 0; 
                        r_state <= S_IDLE; 
                    end 
                end
                default: r_state <= S_IDLE;
            endcase
        end
    end



endmodule
