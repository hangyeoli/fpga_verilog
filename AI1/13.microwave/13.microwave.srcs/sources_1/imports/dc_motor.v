`timescale 1ns / 1ps

module dc_motor(
    input  wire clk,          // 100MHz
    input  wire reset,
    input  wire speed_up,     // one-pulse
    input  wire speed_down,   // one-pulse
    input  wire run_en,
    output wire motor_pwm,
    output wire motor_in1,
    output wire motor_in2
);

    // 20kHz PWM: 100MHz / 5000
    localparam integer PWM_TOP   = 5000;
    localparam integer DUTY_STEP = 500; // 10% per level

    reg [12:0] pwm_cnt;
    reg [3:0]  duty_level; // 0..10

    wire [13:0] duty_count = duty_level * DUTY_STEP;
    wire pwm_raw = (pwm_cnt < duty_count);

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            pwm_cnt <= 13'd0;
            duty_level <= 4'd5; // default 50%
        end else begin
            if (pwm_cnt == PWM_TOP - 1)
                pwm_cnt <= 13'd0;
            else
                pwm_cnt <= pwm_cnt + 13'd1;

            if (run_en) begin
                if (speed_up && !speed_down && duty_level < 4'd10)
                    duty_level <= duty_level + 4'd1;
                else if (speed_down && !speed_up && duty_level > 4'd0)
                    duty_level <= duty_level - 4'd1;
            end
        end
    end

    assign motor_pwm = run_en ? pwm_raw : 1'b0;
    assign motor_in1 = run_en ? 1'b1 : 1'b0; // forward
    assign motor_in2 = 1'b0;

endmodule
