`timescale 1ns / 1ps

module tb_top();
    reg clk;
    reg reset;
    reg [2:0] btn;
    reg [7:0] sw;

    wire [7:0] seg;
    wire [3:0] an;
    wire [15:0] led;

    // DUT
    top u_top(
        .clk(clk),
        .reset(reset),
        .btn(btn),
        .sw(sw),
        .seg(seg),
        .an(an),
        .led(led)
    );

    // 100MHz clock (10ns period)
    always #5 clk = ~clk;

    // 버튼 1번 누르는 동작(바운스 비슷하게 0-1-0-1-0 형태)
    task btn_press;
        input integer btn_index;
        begin
            btn[btn_index] = 1;
            #100000;        // 100us 유지
            btn[btn_index] = 0;
            #100000;        // 100us 대기
            btn[btn_index] = 1;
            #100000;        // 100us 유지
            btn[btn_index] = 0;
            #100000;        // 100us 대기 (주석 닫힘 수정)
        end
    endtask

    initial begin
        // 초기값
        clk   = 0;
        reset = 1;
        btn   = 3'b000;
        sw    = 8'b00000000;

        // reset 유지 후 해제
        #100;
        reset = 0;

        // ------------------ 테스트 시나리오 ------------------

        // (1) UP_COUNTER 모드 동작 확인
        $display("MODE: UP_COUNTER");
        // 필요하면 모드가 btn[0]으로 토글된다는 가정 하에 한번 눌러서 UP로 맞추기
        // btn_press(0);

        #20000000;         // 20ms 관찰

        // (2) 모드 변경: UP -> DOWN (btn[0]이 모드 변경 버튼이라는 가정)
        $display("MODE CHANGE: UP_COUNTER -> DOWN_COUNTER");
        btn_press(0);

        #20000000;         // 20ms 관찰

        // (3) 필요하면 다시 UP으로 토글
        $display("MODE CHANGE: DOWN_COUNTER -> UP_COUNTER");
        btn_press(0);

        #20000000;         // 20ms 관찰

        $display("TB END");
        $finish;
    end

endmodule
