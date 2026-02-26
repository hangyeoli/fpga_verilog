`timescale 1ns / 1ps

module top(
    input  wire       clk,
    input  wire       reset,
    input  wire [2:0] btn,
    output wire [7:0] seg,
    output wire [3:0] an
);

    wire tick_10ms;
    wire tick_1ms;

    wire btn_center_pulse;
    wire btn_left_pulse;
    wire btn_right_pulse;

    wire mode_sw;
    wire sw_paused;

    wire [15:0] clock_bcd;
    wire [15:0] sw_bcd;

    clock_divider #(
        .CLK_HZ(100_000_000)
    ) u_clock_divider (
        .clk(clk),
        .reset(reset),
        .tick_10ms(tick_10ms),
        .tick_1ms(tick_1ms)
    );

    button_debounce_onepulse u_btn_center (
        .clk(clk),
        .reset(reset),
        .sample_tick(tick_1ms),
        .btn_in(btn[0]),
        .btn_pulse(btn_center_pulse)
    );

    button_debounce_onepulse u_btn_left (
        .clk(clk),
        .reset(reset),
        .sample_tick(tick_1ms),
        .btn_in(btn[1]),
        .btn_pulse(btn_left_pulse)
    );

    button_debounce_onepulse u_btn_right (
        .clk(clk),
        .reset(reset),
        .sample_tick(tick_1ms),
        .btn_in(btn[2]),
        .btn_pulse(btn_right_pulse)
    );

    fsm_mode_control u_fsm_mode (
        .clk(clk),
        .reset(reset),
        .btn_left(btn_left_pulse),
        .mode_sw(mode_sw)
    );

    minute_second_clock u_minute_second_clock (
        .clk(clk),
        .reset(reset),
        .tick_10ms(tick_10ms),
        .clock_bcd(clock_bcd)
    );

    stopwatch u_stopwatch (
        .clk(clk),
        .reset(reset),
        .tick_10ms(tick_10ms),
        .mode_sw(mode_sw),
        .btn_center_reset(btn_center_pulse),
        .btn_right_pause(btn_right_pulse),
        .sw_bcd(sw_bcd),
        .sw_paused(sw_paused)
    );

    fnd_display u_fnd_display (
        .clk(clk),
        .reset(reset),
        .tick_1ms(tick_1ms),
        .mode_sw(mode_sw),
        .sw_paused(sw_paused),
        .clock_bcd(clock_bcd),
        .sw_bcd(sw_bcd),
        .seg(seg),
        .an(an)
    );

endmodule
