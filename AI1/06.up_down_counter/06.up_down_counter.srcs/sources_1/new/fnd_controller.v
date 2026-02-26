`timescale 1ns / 1ps

module fnd_controller(
    input clk,
    input reset,
    input tick,
    input [13:0] in_data,
    output [3:0] an,
    output [7:0] seg
    );

    wire [1:0] w_sel;
    wire [3:0] w_d1, w_d10, w_d100, w_d1000;

    fnd_digit_select u_fnd_digit_select(
    //    .clk(clk),
        .reset(reset),
        .tick(tick),
        .sel(w_sel)
    );

    bin2bcd4digit u_bin2bcd4digit(
        .in_data(in_data),
        .d1(w_d1),
        .d10(w_d10),
        .d100(w_d100),
        .d1000(w_d1000)
    );

    fnd_digit_display u_fnd_digit_display(
        .digit_sel(w_sel),
        .d1(w_d1),
        .d10(w_d10),
        .d100(w_d100),
        .d1000(w_d1000),
        .an(an),
        .seg(seg)
    );

endmodule

//------------------------
// 1ms마다 fnd를 display하기 위해서 digit 1자리씩 선택하는 logic
// 4ms까지는 잔상 효과가 있다. 그 이상의 시간 지연을 주면 깜박임 현상 발생 주의
//-------------------------
module fnd_digit_select(
//    input clk,
    input reset,
    input tick,
    output reg [1:0] sel
);
    //reg[$clog2(100_000):0] r_1ms_counter=0; // 1ms delay counter 10ns x 100,000 = 1ms
    
    always @(posedge reset, posedge tick) begin
        if (reset) begin
            sel <= 0;
        end else begin
            if (tick) begin // 1ms elapsed
                sel <= sel + 1; // rotate through digits 0 to 3
            end
        end
        // always @(posedge clk, posedge reset, posedge tick) begin
        // if (reset) begin
        //     r_1ms_counter <= 0;
        //     sel <= 0;
        // end else begin
        //     if (r_1ms_counter == 100_000 - 1) begin // 1ms elapsed
        //         r_1ms_counter <= 0;
        //         sel <= sel + 1; // rotate through digits 0 to 3
        //     end else begin
        //         r_1ms_counter <= r_1ms_counter + 1;
        //     end
        // end
    end
endmodule 


//------------------------
// input [13:0] in_data는 최대 9999까지 표현 가능
//-------------------------
module bin2bcd4digit(
    input [13:0] in_data,
    output [3:0] d1,
    output [3:0] d10,
    output [3:0] d100,
    output [3:0] d1000
);
    assign d1 = in_data % 10;
    assign d10 = (in_data / 10) % 10;
    assign d100 = (in_data / 100) % 10;
    assign d1000 = (in_data / 1000) % 10;
endmodule 

module fnd_digit_display(
    input [1:0] digit_sel,
    input [3:0] d1,
    input [3:0] d10,
    input [3:0] d100,
    input [3:0] d1000,
    output reg [3:0] an,
    output reg [7:0] seg
);
    reg [3:0] bcd_data;
    always @(digit_sel) begin
        case (digit_sel)
            2'b00: begin bcd_data = d1; an = 4'b1110; end // digit 1
            2'b01: begin bcd_data = d10; an = 4'b1101; end // digit 2
            2'b10: begin bcd_data = d100; an = 4'b1011; end // digit 3
            2'b11: begin bcd_data = d1000; an = 4'b0111; end // digit 4
            default: begin bcd_data = 4'b0000; an = 4'b1111; end
        endcase
    end

    always @(bcd_data) begin
        case (bcd_data)
            4'd0: seg = 8'b11000000; // 0
            4'd1: seg = 8'b11111001; // 1
            4'd2: seg = 8'b10100100; // 2
            4'd3: seg = 8'b10110000; // 3
            4'd4: seg = 8'b10011001; // 4
            4'd5: seg = 8'b10010010; // 5
            4'd6: seg = 8'b10000010; // 6
            4'd7: seg = 8'b11111000; // 7
            4'd8: seg = 8'b10000000; // 8
            4'd9: seg = 8'b10010000; // 9
            default: seg = 8'b11111111; // blank
        endcase
    end
endmodule
