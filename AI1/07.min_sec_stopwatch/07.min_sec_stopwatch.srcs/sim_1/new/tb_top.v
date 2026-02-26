`timescale 1ns / 1ps

module tb_top;
    reg clk; reg reset; reg [2:0] btn;
    wire [7:0] seg; wire [3:0] an;

    top uut (.clk(clk), .reset(reset), .btn(btn), .seg(seg), .an(an));

    // 100MHz 클럭 생성
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // -------------------------------------------------------
    // [가속 모드] 시간을 1,000배 압축 (RTL 수정 없이 결과 바로 확인)
    // -------------------------------------------------------
    initial begin
        force uut.tick_1ms = 0;
        force uut.tick_10ms = 0;
        forever begin
            #1000; // 1ms 대신 1us마다 발생
            force uut.tick_1ms = 1; #10; force uut.tick_1ms = 0;
            repeat(9) begin #1000; force uut.tick_1ms = 1; #10; force uut.tick_1ms = 0; end
            force uut.tick_10ms = 1; #10; force uut.tick_10ms = 0;
        end
    end

    // -------------------------------------------------------
    // 전체 동작 시나리오
    // -------------------------------------------------------
    localparam T_STEP = 1_000_000; // 시뮬레이션상 1ms (가속 후 실제 1초 분량)

    initial begin
        // 초기화
        reset = 1; btn = 0;
        #100; reset = 0;

        // [STEP 1] 시계 모드에서 잠시 대기
        #(T_STEP * 2);

        // [STEP 2] 스톱워치 모드 전환 (btn[1] - Left)
        $display("Switching to Stopwatch Mode...");
        press_button(1); 
        #(T_STEP * 3); // 3초간 숫자 증가 확인

        // [STEP 3] 스톱워치 리셋 (btn[0] - Center)
        $display("Resetting Stopwatch...");
        press_button(0); 
        #(T_STEP * 2); // 0에서 다시 증가하는지 확인

        // [STEP 4] 스톱워치 일시정지 (btn[2] - Right)
        $display("Pausing Stopwatch...");
        press_button(2); 
        #(T_STEP * 2); // 숫자가 멈춰있는지 확인

        // [STEP 5] 스톱워치 재시작 (btn[2] - Right)
        $display("Resuming Stopwatch...");
        press_button(2); 
        #(T_STEP * 3); // 다시 올라가는지 확인

        $display("All tests finished!");
        $stop;
    end

    // 버튼 누르기 태스크 (가속 환경에 최적화)
    task press_button(input integer idx);
    begin
        btn[idx] = 1;
        #50_000; // 50us 동안 유지 (디바운싱 통과용)
        btn[idx] = 0;
        #50_000;
    end
    endtask
endmodule