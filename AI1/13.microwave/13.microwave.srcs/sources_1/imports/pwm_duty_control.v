`timescale 1ns / 1ps

module pwm_duty_control(
    input clk,
    input reset,
    input duty_inc,
    input duty_dec,
    output [6:0] DUTY_CYCLE,   // duty percent: 1..100
    output PWM_OUT,
    output PWM_OUT_LED
    );

    reg [6:0] r_DUTY_CYCLE = 7'd50; // default 50%
    reg [6:0] r_counter_PWM = 7'd0; // 0..99
    reg r_prev_duty_inc = 1'b0;
    reg r_prev_duty_dec = 1'b0;

    wire w_duty_inc = duty_inc & ~r_prev_duty_inc;
    wire w_duty_dec = duty_dec & ~r_prev_duty_dec;

    // duty control: 1..100%
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            r_DUTY_CYCLE <= 7'd50;
            r_prev_duty_inc <= 1'b0;
            r_prev_duty_dec <= 1'b0;
        end else begin
            r_prev_duty_inc <= duty_inc;
            r_prev_duty_dec <= duty_dec;

            if (w_duty_inc && !w_duty_dec && r_DUTY_CYCLE < 7'd100)
                r_DUTY_CYCLE <= r_DUTY_CYCLE + 7'd1;
            else if (w_duty_dec && !w_duty_inc && r_DUTY_CYCLE > 7'd1)
                r_DUTY_CYCLE <= r_DUTY_CYCLE - 7'd1;
        end
    end

    // PWM generator: 100 MHz / 100 = 1 MHz
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            r_counter_PWM <= 7'd0;
        end else begin
            if (r_counter_PWM >= 7'd99)
                r_counter_PWM <= 7'd0;
            else
                r_counter_PWM <= r_counter_PWM + 7'd1;
        end
    end

    assign PWM_OUT = (r_counter_PWM < r_DUTY_CYCLE) ? 1'b1 : 1'b0;
    assign PWM_OUT_LED = PWM_OUT;
    assign DUTY_CYCLE = r_DUTY_CYCLE;

endmodule
