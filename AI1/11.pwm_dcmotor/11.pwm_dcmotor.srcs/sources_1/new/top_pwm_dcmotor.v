`timescale 1ns / 1ps

module top_pwm_dcmotor(
    input clk,                   // 100 MHz
    input reset,                 // SW15
    input increase_duty_btn,     // BTNU
    input decrease_duty_btn,     // BTND
    input [1:0] motor_direction, // SW1:SW0
    output PWM_OUT,              // to L298N ENA
    output PWM_OUT_LED,          // on-board LED
    output [1:0] in1_in2,        // to L298N IN1, IN2
    output reg [6:0] seg,
    output reg dp,
    output reg [3:0] an
    );

    wire w_clean_inc_btn;
    wire w_clean_dec_btn;
    wire [6:0] w_duty_cycle;

    reg [26:0] r_blink_cnt = 27'd0;
    reg r_blink_on = 1'b1;

    reg [15:0] r_scan_cnt = 16'd0;
    reg [1:0] r_digit_sel = 2'd0;

    reg [3:0] r_hundreds;
    reg [3:0] r_tens;
    reg [3:0] r_ones;

    reg [6:0] r_seg_data;

    localparam integer BLINK_HALF_SEC = 50_000_000 - 1; // 100MHz
    localparam integer SCAN_DIV = 25_000 - 1;           // 1kHz total scan

    localparam [6:0] SEG_CHAR_F    = 7'b0001110;
    localparam [6:0] SEG_CHAR_b    = 7'b0000011;
    localparam [6:0] SEG_CHAR_DASH = 7'b1111110;

    debouncer u_increase_duty_btn (
        .clk(clk),
        .reset(reset),
        .noisy_btn(increase_duty_btn),
        .clean_btn(w_clean_inc_btn)
    );

    debouncer u_decrease_duty_btn (
        .clk(clk),
        .reset(reset),
        .noisy_btn(decrease_duty_btn),
        .clean_btn(w_clean_dec_btn)
    );

    pwm_duty_control u_pwm_duty_control (
        .clk(clk),
        .reset(reset),
        .duty_inc(w_clean_inc_btn),
        .duty_dec(w_clean_dec_btn),
        .DUTY_CYCLE(w_duty_cycle),
        .PWM_OUT(PWM_OUT),
        .PWM_OUT_LED(PWM_OUT_LED)
    );

    assign in1_in2 = motor_direction;

    // 1Hz blink for direction digit only (on 0.5s, off 0.5s)
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            r_blink_cnt <= 27'd0;
            r_blink_on <= 1'b1;
        end else begin
            if (r_blink_cnt >= BLINK_HALF_SEC) begin
                r_blink_cnt <= 27'd0;
                r_blink_on <= ~r_blink_on;
            end else begin
                r_blink_cnt <= r_blink_cnt + 27'd1;
            end
        end
    end

    // 4-digit scan
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            r_scan_cnt <= 16'd0;
            r_digit_sel <= 2'd0;
        end else begin
            if (r_scan_cnt >= SCAN_DIV) begin
                r_scan_cnt <= 16'd0;
                r_digit_sel <= r_digit_sel + 2'd1;
            end else begin
                r_scan_cnt <= r_scan_cnt + 16'd1;
            end
        end
    end

    // split duty to decimal digits
    always @(*) begin
        r_hundreds = (w_duty_cycle >= 7'd100) ? 4'd1 : 4'd0;
        r_tens = (w_duty_cycle % 7'd100) / 7'd10;
        r_ones = w_duty_cycle % 7'd10;
    end

    // digit select and segment data (Basys3: active-low)
    always @(*) begin
        an = 4'b1111;
        dp = 1'b1;
        r_seg_data = 7'b1111111;

        case (r_digit_sel)
            2'd0: begin
                an = 4'b1110; // right-most: ones
                r_seg_data = seg_num(r_ones);
            end
            2'd1: begin
                an = 4'b1101; // tens
                r_seg_data = seg_num(r_tens);
            end
            2'd2: begin
                an = 4'b1011; // hundreds
                r_seg_data = seg_num(r_hundreds);
            end
            2'd3: begin
                an = 4'b0111; // left-most: direction char
                if (r_blink_on) begin
                    case (motor_direction)
                        2'b10: r_seg_data = SEG_CHAR_b;
                        2'b01: r_seg_data = SEG_CHAR_F;
                        default: r_seg_data = SEG_CHAR_DASH;
                    endcase
                end else begin
                    r_seg_data = 7'b1111111;
                end
            end
        endcase

        seg = r_seg_data;
    end

    function [6:0] seg_num;
        input [3:0] num;
        begin
            case (num)
                4'd0: seg_num = 7'b1000000;
                4'd1: seg_num = 7'b1111001;
                4'd2: seg_num = 7'b0100100;
                4'd3: seg_num = 7'b0110000;
                4'd4: seg_num = 7'b0011001;
                4'd5: seg_num = 7'b0010010;
                4'd6: seg_num = 7'b0000010;
                4'd7: seg_num = 7'b1111000;
                4'd8: seg_num = 7'b0000000;
                4'd9: seg_num = 7'b0010000;
                default: seg_num = 7'b1111111;
            endcase
        end
    endfunction

endmodule
