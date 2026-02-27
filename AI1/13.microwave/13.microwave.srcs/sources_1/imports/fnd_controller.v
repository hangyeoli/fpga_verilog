`timescale 1ns / 1ps

module fnd_controller(
    input  wire       clk,
    input  wire       reset,
    input  wire       tick_1ms,
    input  wire [3:0] digit3,
    input  wire [3:0] digit2,
    input  wire [3:0] digit1,
    input  wire [3:0] digit0,
    input  wire       done_active,
    input  wire       done_on,
    output reg  [3:0] an,
    output reg  [7:0] seg
);

    reg [1:0] scan_sel;
    reg [3:0] bcd_data;
    reg [6:0] normal_seg;

    always @(posedge clk or posedge reset) begin
        if (reset)
            scan_sel <= 2'd0;
        else if (tick_1ms)
            scan_sel <= scan_sel + 2'd1;
    end

    always @(*) begin
        case (scan_sel)
            2'd0: begin bcd_data = digit0; an = 4'b1110; end
            2'd1: begin bcd_data = digit1; an = 4'b1101; end
            2'd2: begin bcd_data = digit2; an = 4'b1011; end
            default: begin bcd_data = digit3; an = 4'b0111; end
        endcase
    end

    always @(*) begin
        case (bcd_data)
            4'd0: normal_seg = 7'b1000000;
            4'd1: normal_seg = 7'b1111001;
            4'd2: normal_seg = 7'b0100100;
            4'd3: normal_seg = 7'b0110000;
            4'd4: normal_seg = 7'b0011001;
            4'd5: normal_seg = 7'b0010010;
            4'd6: normal_seg = 7'b0000010;
            4'd7: normal_seg = 7'b1111000;
            4'd8: normal_seg = 7'b0000000;
            4'd9: normal_seg = 7'b0010000;
            default: normal_seg = 7'b1111111;
        endcase
    end

    always @(*) begin
        seg[7] = 1'b1;
        if (done_active) begin
            if (done_on)
                seg[6:0] = 7'b1000000; // 0
            else
                seg[6:0] = 7'b1111111; // blank
        end else begin
            seg[6:0] = normal_seg;
        end
    end

endmodule
