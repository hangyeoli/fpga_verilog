`timescale 1ns / 1ps

module coffee_machine #(
    parameter integer CLK_HZ = 100_000_000,
    parameter integer BREW_SEC = 5,
    parameter integer DEBOUNCE_MS = 20,
    parameter integer COFFEE_PRICE = 300
) (
    input  wire       clk,
    input  wire       reset,            // SW15 (active high)
    input  wire       coin,             // BTN L: add 100 won
    input  wire       return_coin_btn,  // BTN C: return all coins
    input  wire       coffee_btn,       // BTN R: start coffee
    output reg  [7:0] seg,
    output reg  [3:0] an
);
    localparam integer BREW_CYCLES = CLK_HZ * BREW_SEC;
    localparam integer ANIM_TICK_CYCLES = CLK_HZ / 5; // 0.2 s

    wire coin_pulse;
    wire return_pulse;
    wire coffee_pulse;

    btn_onepulse #(.CLK_HZ(CLK_HZ), .DEBOUNCE_MS(DEBOUNCE_MS)) u_coin_btn (
        .clk(clk), .reset(reset), .btn_in(coin), .pulse(coin_pulse)
    );

    btn_onepulse #(.CLK_HZ(CLK_HZ), .DEBOUNCE_MS(DEBOUNCE_MS)) u_return_btn (
        .clk(clk), .reset(reset), .btn_in(return_coin_btn), .pulse(return_pulse)
    );

    btn_onepulse #(.CLK_HZ(CLK_HZ), .DEBOUNCE_MS(DEBOUNCE_MS)) u_coffee_btn (
        .clk(clk), .reset(reset), .btn_in(coffee_btn), .pulse(coffee_pulse)
    );

    reg [15:0] coin_val;
    reg        brewing;
    reg [31:0] brew_counter;
    reg [31:0] anim_tick_counter;
    reg [2:0]  anim_step;

    always @(posedge clk) begin
        if (reset) begin
            coin_val <= 16'd0;
            brewing <= 1'b0;
            brew_counter <= 32'd0;
            anim_tick_counter <= 32'd0;
            anim_step <= 3'd0;
        end else begin
            if (!brewing) begin
                if (coin_pulse) begin
                    coin_val <= coin_val + 16'd100;
                end

                if (return_pulse) begin
                    coin_val <= 16'd0;
                end

                if (coffee_pulse && (coin_val >= COFFEE_PRICE)) begin
                    brewing <= 1'b1;
                    brew_counter <= 32'd0;
                    anim_tick_counter <= 32'd0;
                    anim_step <= 3'd0;
                end
            end else begin
                if (brew_counter == BREW_CYCLES - 1) begin
                    brewing <= 1'b0;
                    coin_val <= coin_val - COFFEE_PRICE;
                    brew_counter <= 32'd0;
                    anim_tick_counter <= 32'd0;
                    anim_step <= 3'd0;
                end else begin
                    brew_counter <= brew_counter + 1;

                    if (anim_tick_counter == ANIM_TICK_CYCLES - 1) begin
                        anim_tick_counter <= 32'd0;
                        if (anim_step == 3'd5) begin
                            anim_step <= 3'd0;
                        end else begin
                            anim_step <= anim_step + 1;
                        end
                    end else begin
                        anim_tick_counter <= anim_tick_counter + 1;
                    end
                end
            end
        end
    end

    reg [16:0] scan_counter;
    always @(posedge clk) begin
        if (reset) begin
            scan_counter <= 17'd0;
        end else begin
            scan_counter <= scan_counter + 1;
        end
    end

    wire [1:0] scan_sel = scan_counter[16:15];

    wire [3:0] digit_thousands = (coin_val / 1000) % 10;
    wire [3:0] digit_hundreds  = (coin_val / 100) % 10;
    wire [3:0] digit_tens      = (coin_val / 10) % 10;
    wire [3:0] digit_ones      = coin_val % 10;

    function [7:0] seg_digit;
        input [3:0] val;
        begin
            case (val)
                4'd0: seg_digit = 8'b11000000;
                4'd1: seg_digit = 8'b11111001;
                4'd2: seg_digit = 8'b10100100;
                4'd3: seg_digit = 8'b10110000;
                4'd4: seg_digit = 8'b10011001;
                4'd5: seg_digit = 8'b10010010;
                4'd6: seg_digit = 8'b10000010;
                4'd7: seg_digit = 8'b11111000;
                4'd8: seg_digit = 8'b10000000;
                4'd9: seg_digit = 8'b10010000;
                default: seg_digit = 8'b11111111;
            endcase
        end
    endfunction

    function [7:0] seg_anim;
        input [2:0] step;
        begin
            case (step)
                3'd0: seg_anim = 8'b11111110; // a
                3'd1: seg_anim = 8'b11111101; // b
                3'd2: seg_anim = 8'b11111011; // c
                3'd3: seg_anim = 8'b11110111; // d
                3'd4: seg_anim = 8'b11101111; // e
                3'd5: seg_anim = 8'b11011111; // f
                default: seg_anim = 8'b11111111;
            endcase
        end
    endfunction

    always @(*) begin
        case (scan_sel)
            2'b00: begin
                an = 4'b1110;
                seg = brewing ? seg_anim(anim_step) : seg_digit(digit_ones);
            end
            2'b01: begin
                an = 4'b1101;
                seg = brewing ? seg_anim(anim_step) : seg_digit(digit_tens);
            end
            2'b10: begin
                an = 4'b1011;
                seg = brewing ? seg_anim(anim_step) : seg_digit(digit_hundreds);
            end
            default: begin
                an = 4'b0111;
                seg = brewing ? seg_anim(anim_step) : seg_digit(digit_thousands);
            end
        endcase
    end
endmodule

module btn_onepulse #(
    parameter integer CLK_HZ = 100_000_000,
    parameter integer DEBOUNCE_MS = 20
) (
    input  wire clk,
    input  wire reset,
    input  wire btn_in,
    output reg  pulse
);
    localparam integer DB_COUNT_MAX = (CLK_HZ / 1000) * DEBOUNCE_MS;

    reg [1:0] btn_sync;
    reg       btn_stable;
    reg [31:0] db_count;

    always @(posedge clk) begin
        if (reset) begin
            btn_sync <= 2'b00;
        end else begin
            btn_sync <= {btn_sync[0], btn_in};
        end
    end

    always @(posedge clk) begin
        if (reset) begin
            btn_stable <= 1'b0;
            db_count <= 32'd0;
            pulse <= 1'b0;
        end else begin
            pulse <= 1'b0;

            if (btn_sync[1] == btn_stable) begin
                db_count <= 32'd0;
            end else if (db_count == DB_COUNT_MAX - 1) begin
                btn_stable <= btn_sync[1];
                db_count <= 32'd0;
                if (btn_sync[1]) begin
                    pulse <= 1'b1;
                end
            end else begin
                db_count <= db_count + 1;
            end
        end
    end
endmodule
