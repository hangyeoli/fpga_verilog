`timescale 1ns / 1ps

module stopwatch(
    input  wire        clk,
    input  wire        reset,
    input  wire        tick_10ms,
    input  wire        mode_sw,
    input  wire        btn_center_reset,
    input  wire        btn_right_pause,
    output wire [15:0] sw_bcd,
    output reg         sw_paused
);

    reg [3:0] sec_ones;
    reg [3:0] sec_tens;
    reg [3:0] cs_ones;
    reg [3:0] cs_tens;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            sec_ones <= 4'd0;
            sec_tens <= 4'd0;
            cs_ones  <= 4'd0;
            cs_tens  <= 4'd0;
            sw_paused <= 1'b0;
        end else begin
            if (mode_sw && btn_center_reset) begin
                sec_ones <= 4'd0;
                sec_tens <= 4'd0;
                cs_ones  <= 4'd0;
                cs_tens  <= 4'd0;
                sw_paused <= 1'b0;
            end else begin
                if (mode_sw && btn_right_pause) begin
                    sw_paused <= ~sw_paused;
                end

                if (mode_sw && tick_10ms && !sw_paused) begin
                    if (cs_ones == 4'd9) begin
                        cs_ones <= 4'd0;
                        if (cs_tens == 4'd9) begin
                            cs_tens <= 4'd0;
                            if (sec_ones == 4'd9) begin
                                sec_ones <= 4'd0;
                                if (sec_tens == 4'd5) begin
                                    sec_tens <= 4'd0;
                                end else begin
                                    sec_tens <= sec_tens + 4'd1;
                                end
                            end else begin
                                sec_ones <= sec_ones + 4'd1;
                            end
                        end else begin
                            cs_tens <= cs_tens + 4'd1;
                        end
                    end else begin
                        cs_ones <= cs_ones + 4'd1;
                    end
                end
            end
        end
    end

    assign sw_bcd = {sec_tens, sec_ones, cs_tens, cs_ones};

endmodule
