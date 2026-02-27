`timescale 1ns / 1ps

module play_melody(
    input clk,
    input reset,
    input btnU,
    input btnL,
    input btnC,
    input btnR,
    input btnD,
    output buzzer
    );

    localparam integer STEP_TICKS = 23'd7_000_000;  // 70ms @ 100MHz

    localparam [1:0] MODE_NONE  = 2'd0;
    localparam [1:0] MODE_POWER = 2'd1;
    localparam [1:0] MODE_OPEN  = 2'd2;

    reg [1:0] mode;
    reg [2:0] step;

    reg [22:0] step_cnt;
    reg [18:0] tone_cnt;
    reg buzzer_reg;

    reg btnL_d;
    reg btnR_d;

    wire btnL_rise = btnL & ~btnL_d;
    wire btnR_rise = btnR & ~btnR_d;

    reg [18:0] half_period;
    reg tone_enable;

    always @(*) begin
        half_period = 19'd0;
        tone_enable = 1'b0;

        case (mode)
            MODE_POWER: begin
                case (step)
                    3'd0: begin half_period = 19'd45_455; tone_enable = 1'b1; end  // 1.1kHz
                    3'd1: begin half_period = 19'd22_727; tone_enable = 1'b1; end  // 2.2kHz
                    3'd2: begin half_period = 19'd15_152; tone_enable = 1'b1; end  // 3.3kHz
                    3'd3: begin half_period = 19'd11_364; tone_enable = 1'b1; end  // 4.4kHz
                    default: begin half_period = 19'd0; tone_enable = 1'b0; end     // no beep
                endcase
            end
            MODE_OPEN: begin
                case (step)
                    3'd0: begin half_period = 19'd191_571; tone_enable = 1'b1; end // 261Hz
                    3'd1: begin half_period = 19'd151_976; tone_enable = 1'b1; end // 329Hz
                    3'd2: begin half_period = 19'd127_551; tone_enable = 1'b1; end // 392Hz
                    3'd3: begin half_period = 19'd90_253;  tone_enable = 1'b1; end // 554Hz
                    default: begin half_period = 19'd0; tone_enable = 1'b0; end     // no beep
                endcase
            end
            default: begin
                half_period = 19'd0;
                tone_enable = 1'b0;
            end
        endcase
    end

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            mode <= MODE_NONE;
            step <= 3'd0;
            step_cnt <= 23'd0;
            tone_cnt <= 19'd0;
            buzzer_reg <= 1'b0;
            btnL_d <= 1'b0;
            btnR_d <= 1'b0;
        end else begin
            btnL_d <= btnL;
            btnR_d <= btnR;

            if (mode == MODE_NONE) begin
                step <= 3'd0;
                step_cnt <= 23'd0;
                tone_cnt <= 19'd0;
                buzzer_reg <= 1'b0;

                if (btnL_rise) begin
                    mode <= MODE_POWER;
                end else if (btnR_rise) begin
                    mode <= MODE_OPEN;
                end
            end else begin
                if (step_cnt >= STEP_TICKS - 1) begin
                    step_cnt <= 23'd0;
                    tone_cnt <= 19'd0;
                    buzzer_reg <= 1'b0;

                    if (step == 3'd4) begin
                        mode <= MODE_NONE;
                        step <= 3'd0;
                    end else begin
                        step <= step + 3'd1;
                    end
                end else begin
                    step_cnt <= step_cnt + 23'd1;

                    if (tone_enable) begin
                        if (tone_cnt >= half_period - 1) begin
                            tone_cnt <= 19'd0;
                            buzzer_reg <= ~buzzer_reg;
                        end else begin
                            tone_cnt <= tone_cnt + 19'd1;
                        end
                    end else begin
                        tone_cnt <= 19'd0;
                        buzzer_reg <= 1'b0;
                    end
                end
            end
        end
    end

    assign buzzer = buzzer_reg;

endmodule
