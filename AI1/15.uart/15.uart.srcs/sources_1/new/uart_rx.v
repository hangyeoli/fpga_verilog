`timescale 1ns / 1ps

module uart_rx #(
    parameter BPS = 9600
) (
    input clk,
    input reset,
    input rx,
    output reg [7:0] data_out,
    output reg rx_done
);
    localparam S_IDLE      = 2'b00;
    localparam S_START_BIT = 2'b01;
    localparam S_DATA_8BITS = 2'b10; // FIX: 이름을 사용처(S_DATA_8BITS)와 맞춤
    localparam S_STOP_BIT  = 2'b11;

    // 100 MHz system clock, 16x UART oversampling tick.
    localparam integer DIVIDER_CNT = 100_000_000 / (BPS * 16);

    reg [1:0] r_state;
    reg [3:0] r_bit_cnt;
    reg [7:0] r_data_reg;

    reg [15:0] r_baud_cnt;
    reg r_baud_tick;
    reg [3:0] r_baud_tick_cnt; // FIX: 1bit -> 4bit (0~15 카운트)


    always @(posedge clk or posedge reset) begin
        if (reset) begin
            r_baud_cnt  <= 16'd0;
            r_baud_tick <= 1'b0;
        end else begin
            if (r_baud_cnt >= DIVIDER_CNT - 1) begin
                r_baud_cnt  <= 16'd0;
                r_baud_tick <= 1'b1;
            end else begin
                r_baud_cnt  <= r_baud_cnt + 1'b1;
                r_baud_tick <= 1'b0;
            end
        end
    end

    always @(posedge clk, posedge reset) begin
        if (reset) begin
            data_out <= 8'b0;
            rx_done <= 1'b0;
            r_state <= S_IDLE;
            r_bit_cnt <= 4'd0;
            r_data_reg <= 8'b0;
            r_baud_tick_cnt <= 4'd0;
        end
        else begin
            case (r_state)
                S_IDLE: begin
                    rx_done <= 1'b0;
                    if (!rx) begin // start bit수신 (요청대로 그대로 유지)
                        r_state <= S_START_BIT;
                        r_baud_tick_cnt <= 4'd0;
                    end
                end

                S_START_BIT: begin
                    if (r_baud_tick) begin
                        r_baud_tick_cnt <= r_baud_tick_cnt + 1'b1;
                        if (r_baud_tick_cnt == 4'd7) begin // 8th tick에서 샘플링
                            r_state <= S_DATA_8BITS;
                            r_bit_cnt <= 4'd0;
                            r_baud_tick_cnt <= 4'd0;
                        end
                    end
                end

                S_DATA_8BITS: begin
                    if (r_baud_tick) begin
                        r_baud_tick_cnt <= r_baud_tick_cnt + 1'b1;
                        if (r_baud_tick_cnt == 4'd15) begin // 16th tick에서 샘플링
                            r_data_reg[r_bit_cnt] <= rx; // 데이터 비트 저장
                            if (r_bit_cnt == 4'd7) begin
                                r_state <= S_STOP_BIT;
                            end else begin
                                r_bit_cnt <= r_bit_cnt + 1'b1;
                            end
                            r_baud_tick_cnt <= 4'd0;
                        end
                    end
                end

                S_STOP_BIT: begin
                    if (r_baud_tick) begin
                        r_baud_tick_cnt <= r_baud_tick_cnt + 1'b1;
                        if (r_baud_tick_cnt == 4'd15) begin
                            r_state <= S_IDLE;
                            data_out <= r_data_reg; // 수신된 데이터 출력
                            rx_done <= 1'b1; // 수신 완료 신호                                                   
                        end
                    end
                end

                default:  r_state <= S_IDLE;
            endcase
        end
    end

endmodule