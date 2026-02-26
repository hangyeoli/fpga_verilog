`timescale 1ns / 1ps

module tb_add8;

    reg  [15:0] sw;        // 입력
    wire carry_out;        // 출력
    wire [7:0] sum;

    // DUT (Device Under Test)
    add8 uut (
        .sw(sw),
        .carry_out(carry_out),
        .sum(sum)
    );

    initial begin
        $monitor("t=%0t | A=%d B=%d -> sum=%d carry=%b",
                 $time, sw[7:0], sw[15:8], sum, carry_out);

        // 테스트 케이스들
        sw = 16'h0000;          // 0 + 0
        #10 sw = {8'd10, 8'd5}; // 5 + 10
        #10 sw = {8'd100,8'd50};
        #10 sw = {8'd200,8'd100};
        #10 sw = {8'd255,8'd1}; // carry 발생 테스트
        #10 sw = {8'd255,8'd255}; // 최대값 테스트
        #10 $finish;
    end

endmodule
