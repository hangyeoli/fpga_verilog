`timescale 1ns / 1ps

module minute_second_clock(
    input  wire       clk,
    input  wire       reset,
    input  wire       tick_10ms,
    output wire [15:0] clock_bcd
);

    reg [3:0] sec_ones;
    reg [3:0] sec_tens;
    reg [3:0] min_ones;
    reg [3:0] min_tens;
    reg [6:0] cs_cnt;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            sec_ones <= 4'd0;
            sec_tens <= 4'd0;
            min_ones <= 4'd0;
            min_tens <= 4'd0;
            cs_cnt   <= 7'd0;
        end else if (tick_10ms) begin
            if (cs_cnt == 7'd99) begin
                cs_cnt <= 7'd0;

                if (sec_ones == 4'd9) begin
                    sec_ones <= 4'd0;
                    if (sec_tens == 4'd5) begin
                        sec_tens <= 4'd0;
                        if (min_ones == 4'd9) begin
                            min_ones <= 4'd0;
                            if (min_tens == 4'd5) begin
                                min_tens <= 4'd0;
                            end else begin
                                min_tens <= min_tens + 4'd1;
                            end
                        end else begin
                            min_ones <= min_ones + 4'd1;
                        end
                    end else begin
                        sec_tens <= sec_tens + 4'd1;
                    end
                end else begin
                    sec_ones <= sec_ones + 4'd1;
                end
            end else begin
                cs_cnt <= cs_cnt + 7'd1;
            end
        end
    end

    assign clock_bcd = {min_tens, min_ones, sec_tens, sec_ones};

endmodule
