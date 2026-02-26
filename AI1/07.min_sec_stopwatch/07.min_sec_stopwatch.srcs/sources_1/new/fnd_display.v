`timescale 1ns / 1ps

module fnd_display(
    input  wire        clk,
    input  wire        reset,
    input  wire        tick_1ms,
    input  wire        mode_sw,
    input  wire        sw_paused,
    input  wire [15:0] clock_bcd,
    input  wire [15:0] sw_bcd,
    output reg  [7:0]  seg,
    output reg  [3:0]  an
);

    reg [1:0] scan_sel;
    reg [3:0] digit_bcd;
    reg [6:0] anim_ms_cnt;
    reg [3:0] anim_phase;
    reg [6:0] anim_seg7;
    reg [2:0] seg_idx;

    wire [15:0] display_bcd;
    wire [6:0] seg7;

    seven_seg_decoder u_seven_seg_decoder (
        .bcd(digit_bcd),
        .seg7(seg7)
    );

    assign display_bcd = mode_sw ? sw_bcd : clock_bcd;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            scan_sel <= 2'd0;
        end else if (tick_1ms) begin
            scan_sel <= scan_sel + 2'd1;
        end
    end

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            anim_ms_cnt <= 7'd0;
            anim_phase  <= 4'd0;
        end else if (tick_1ms) begin
            if (mode_sw && sw_paused) begin
                if (anim_ms_cnt == 7'd79) begin
                    anim_ms_cnt <= 7'd0;
                    if (anim_phase == 4'd11) begin
                        anim_phase <= 4'd0;
                    end else begin
                        anim_phase <= anim_phase + 4'd1;
                    end
                end else begin
                    anim_ms_cnt <= anim_ms_cnt + 7'd1;
                end
            end
        end
    end

    always @(*) begin
        case (scan_sel)
            2'd0: begin
                an       = 4'b1110;
                digit_bcd = display_bcd[3:0];
            end
            2'd1: begin
                an       = 4'b1101;
                digit_bcd = display_bcd[7:4];
            end
            2'd2: begin
                an       = 4'b1011;
                digit_bcd = display_bcd[11:8];
            end
            default: begin
                an       = 4'b0111;
                digit_bcd = display_bcd[15:12];
            end
        endcase
    end

    always @(*) begin
        anim_seg7 = 7'b1111111;
        seg_idx   = 3'd7;

        case (anim_phase)
            4'd0:  begin if (scan_sel == 2'd3) seg_idx = 3'd0; end
            4'd1:  begin if (scan_sel == 2'd2) seg_idx = 3'd0; end
            4'd2:  begin if (scan_sel == 2'd1) seg_idx = 3'd0; end
            4'd3:  begin if (scan_sel == 2'd0) seg_idx = 3'd0; end
            4'd4:  begin if (scan_sel == 2'd0) seg_idx = 3'd1; end
            4'd5:  begin if (scan_sel == 2'd0) seg_idx = 3'd2; end
            4'd6:  begin if (scan_sel == 2'd0) seg_idx = 3'd3; end
            4'd7:  begin if (scan_sel == 2'd1) seg_idx = 3'd3; end
            4'd8:  begin if (scan_sel == 2'd2) seg_idx = 3'd3; end
            4'd9:  begin if (scan_sel == 2'd3) seg_idx = 3'd3; end
            4'd10: begin if (scan_sel == 2'd3) seg_idx = 3'd4; end
            4'd11: begin if (scan_sel == 2'd3) seg_idx = 3'd5; end
            default: begin end
        endcase

        if (seg_idx < 3'd7) begin
            anim_seg7[seg_idx] = 1'b0;
        end

        if (mode_sw && sw_paused) begin
            seg[6:0] = anim_seg7;
        end else begin
            seg[6:0] = seg7;
        end

        seg[7] = 1'b1;
    end

endmodule
