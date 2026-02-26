`timescale 1ns / 1ps

module tick_gen (
    input clk,        // 100MHz 클럭 (Basys3 기준)
    input reset,      // active-high reset
    output reg tick    // 500ms마다 토글되는 LED 출력
);
    parameter INPUT_FREQUENCY = 100_000_000; // 100MHz
    parameter TICK_Hz = 1000; // 1kHz tick (500ms마다 토글이므로 2Hz)
    parameter TICK_COUNT = INPUT_FREQUENCY / TICK_Hz; // 100,000,000 / 1,000 = 100,000 클럭 사이클마다 tick 토글

    reg [$clog2(TICK_COUNT)-1:0] r_tick_counter = 0; // 카운터 레지스터
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            r_tick_counter <= 0;
        end else begin
            if (r_tick_counter == TICK_COUNT - 1) begin
                r_tick_counter <= 0;
                tick<=1'b1;
            end else begin
                r_tick_counter <= r_tick_counter + 1;
                tick<=1'b0;
            end
        end
    end
endmodule
