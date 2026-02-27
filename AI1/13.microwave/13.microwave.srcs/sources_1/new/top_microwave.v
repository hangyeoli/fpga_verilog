`timescale 1ns / 1ps

module top_microwave(
    input  wire       clk,
    input  wire       reset,            // SW15
    input  wire       btnU,             // motor speed up
    input  wire       btnL,             // +1 minute
    input  wire       btnC,             // door toggle
    input  wire       btnR,             // +30 sec
    input  wire       btnD,             // motor speed down
    input  wire       start_cancel_btn, // start/cancel toggle (J3)
    output wire [6:0] seg,
    output wire       dp,
    output wire [3:0] an,
    output wire       motor_pwm,
    output wire       motor_in1,
    output wire       motor_in2,
    output wire       servo_pwm,
    output wire       buzzer
);

    wire rst;
    wire pU, pL, pC, pR, pD, pSC;
    wire tick_1ms, tick_300ms, tick_1s;

    wire running;
    wire door_open;
    wire done_active;
    wire done_on;
    wire evt_button_core;
    wire evt_door;

    wire [3:0] min_tens;
    wire [3:0] min_ones;
    wire [3:0] sec_tens;
    wire [3:0] sec_ones;

    wire [3:0] fnd_an;
    wire [7:0] fnd_seg;

    wire evt_button_all = evt_button_core | pU | pD;

    reset_sync u_reset_sync (
        .clk(clk),
        .rst_async(reset),
        .rst_sync(rst)
    );

    btn_debouncer u_btnU  (.clk(clk), .reset(rst), .btn_in(btnU),             .pulse(pU),  .level());
    btn_debouncer u_btnL  (.clk(clk), .reset(rst), .btn_in(btnL),             .pulse(pL),  .level());
    btn_debouncer u_btnC  (.clk(clk), .reset(rst), .btn_in(btnC),             .pulse(pC),  .level());
    btn_debouncer u_btnR  (.clk(clk), .reset(rst), .btn_in(btnR),             .pulse(pR),  .level());
    btn_debouncer u_btnD  (.clk(clk), .reset(rst), .btn_in(btnD),             .pulse(pD),  .level());
    btn_debouncer u_btnSC (.clk(clk), .reset(rst), .btn_in(start_cancel_btn), .pulse(pSC), .level());

    tick_pulse_gen #(.COUNT_MAX(100_000))      u_tick_1ms   (.clk(clk), .reset(rst), .tick(tick_1ms));
    tick_pulse_gen #(.COUNT_MAX(30_000_000))   u_tick_300ms (.clk(clk), .reset(rst), .tick(tick_300ms));
    tick_pulse_gen #(.COUNT_MAX(100_000_000))  u_tick_1s    (.clk(clk), .reset(rst), .tick(tick_1s));

    microwave_ctrl u_microwave_ctrl (
        .clk(clk),
        .reset(rst),
        .tick_1s(tick_1s),
        .tick_300ms(tick_300ms),
        .btn_add_min(pL),
        .btn_add_30s(pR),
        .btn_door_toggle(pC),
        .btn_start_cancel(pSC),
        .running(running),
        .door_open(door_open),
        .done_active(done_active),
        .done_on(done_on),
        .evt_button(evt_button_core),
        .evt_door(evt_door),
        .min_tens(min_tens),
        .min_ones(min_ones),
        .sec_tens(sec_tens),
        .sec_ones(sec_ones)
    );

    dc_motor u_dc_motor (
        .clk(clk),
        .reset(rst),
        .speed_up(pU),
        .speed_down(pD),
        .run_en(running),
        .motor_pwm(motor_pwm),
        .motor_in1(motor_in1),
        .motor_in2(motor_in2)
    );

    servo_pwm_gen u_servo_pwm_gen (
        .clk(clk),
        .reset(rst),
        .move_trigger(evt_door),
        .door_open(door_open),
        .pwm_out(servo_pwm)
    );

    buzzer_controller u_buzzer_controller (
        .clk(clk),
        .reset(rst),
        .event_button(evt_button_all),
        .event_door(evt_door),
        .door_open(door_open),
        .done_active(done_active),
        .done_on(done_on),
        .buzzer(buzzer)
    );

    fnd_controller u_fnd_controller (
        .clk(clk),
        .reset(rst),
        .tick_1ms(tick_1ms),
        .digit3(min_tens),
        .digit2(min_ones),
        .digit1(sec_tens),
        .digit0(sec_ones),
        .done_active(done_active),
        .done_on(done_on),
        .an(fnd_an),
        .seg(fnd_seg)
    );

    assign an  = fnd_an;
    assign seg = fnd_seg[6:0];
    assign dp  = fnd_seg[7];

endmodule
