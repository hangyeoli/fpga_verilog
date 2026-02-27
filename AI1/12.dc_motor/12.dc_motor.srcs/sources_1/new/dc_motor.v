`timescale 1ns / 1ps

module dc_motor(
    input clk,          // 100 MHz
    input reset,        // SW15
    input btnU,         // speed up
    input btnD,         // speed down
    input btnC,         // direction toggle
    input btnL,         // brake toggle
    output motor_pwm,   // to L298N ENA
    output motor_in1,   // to L298N IN1
    output motor_in2,   // to L298N IN2
    output [5:0] led    // status LEDs
    );

// 20 kHz PWM from 100 MHz clock: 100e6 / 20e3 = 5000
localparam integer PWM_TOP = 5000;
localparam integer DUTY_STEP = 500; // 10% steps

reg [12:0] pwm_cnt;
reg [3:0] duty_level;   // 0..10
reg dir;                // 1: forward, 0: reverse
reg brake;

reg btnU_d;
reg btnD_d;
reg btnC_d;
reg btnL_d;

wire btnU_rise = btnU & ~btnU_d;
wire btnD_rise = btnD & ~btnD_d;
wire btnC_rise = btnC & ~btnC_d;
wire btnL_rise = btnL & ~btnL_d;

wire [13:0] duty_count = duty_level * DUTY_STEP;
wire pwm_raw = (pwm_cnt < duty_count);

always @(posedge clk or posedge reset) begin
    if (reset) begin
        pwm_cnt <= 13'd0;
        duty_level <= 4'd5; // start at 50%
        dir <= 1'b1;
        brake <= 1'b0;
        btnU_d <= 1'b0;
        btnD_d <= 1'b0;
        btnC_d <= 1'b0;
        btnL_d <= 1'b0;
    end else begin
        btnU_d <= btnU;
        btnD_d <= btnD;
        btnC_d <= btnC;
        btnL_d <= btnL;

        if (pwm_cnt == PWM_TOP - 1)
            pwm_cnt <= 13'd0;
        else
            pwm_cnt <= pwm_cnt + 13'd1;

        if (btnU_rise && duty_level < 4'd10)
            duty_level <= duty_level + 4'd1;
        else if (btnD_rise && duty_level > 4'd0)
            duty_level <= duty_level - 4'd1;

        if (btnC_rise)
            dir <= ~dir;

        if (btnL_rise)
            brake <= ~brake;
    end
end

assign motor_pwm = brake ? 1'b0 : pwm_raw;
assign motor_in1 = brake ? 1'b1 : dir;
assign motor_in2 = brake ? 1'b1 : ~dir;

assign led[3:0] = duty_level; // speed level 0..10
assign led[4] = dir;          // direction
assign led[5] = brake;        // brake state

endmodule
