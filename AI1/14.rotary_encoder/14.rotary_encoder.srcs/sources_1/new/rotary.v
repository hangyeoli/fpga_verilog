`timescale 1ns / 1ps

module rotary(
    input clk,          // 100 MHz
    input reset,        // SW15
    input clean_s1,
    input clean_s2,
    input clean_key,
    output [15:0] led
    );

    reg[1:0] r_direction = 2'b00; // 00: no turn, 01: CW, 10: CCW
    reg[1:0] r_prev_state = 2'b00; // previous state of s1 and s2
    reg[1:0] r_current_state = 2'b00; // current state of s1 and s2
    reg[7:0] r_counter = 8'h00; // count of turns
    reg[1:0] r_step = 2'b00; // step for debouncing

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            r_direction <= 2'b00;
            r_prev_state <= 2'b00;
            r_current_state <= 2'b00;
            r_counter <= 8'h00;
            r_step <= 2'b00;
        end else begin
            r_prev_state <= r_current_state;
            r_current_state <= {clean_s1, clean_s2};

            case ({r_prev_state, r_current_state})
                4'b0010, 4'b1011, 4'b1101, 4'b0100: begin // CW
                    if (r_counter < 8'hFF && r_step ==2'b11)
                        r_counter <= r_counter + 1;
                    r_step <= r_step + 1; // step 증가
                    r_direction <= 2'b01;
                end
                4'b0001, 4'b0111, 4'b1110, 4'b1000: begin // CCW
                    if (r_counter > 8'h00 && r_step ==2'b11)
                        r_counter <= r_counter - 1;
                    r_step <= r_step + 1; // step 증가
                    r_direction <= 2'b10;
                end
                // default: begin
                //     r_direction<=2'b00;
                // end
            endcase
        end
    end

    //key 
    reg r_led_toggle = 1'b0;
    reg r_prev_key = 1'b0;
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            r_led_toggle <= 1'b0;
            r_prev_key <= 1'b0;
        end else begin
            r_prev_key <= clean_key;
            if (!r_prev_key && clean_key) begin
                r_led_toggle <= ~r_led_toggle;
            end
        end
    end

    assign led[15:14] = r_direction;
    assign led[13] = r_led_toggle;
    assign led[7:0] = r_counter;
    assign led[12:8] = 5'b00000; // unused
endmodule