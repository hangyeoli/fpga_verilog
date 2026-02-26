`timescale 1ns / 1ps

module tb_top_btn;

    // DUT ports
    reg clk;
    reg reset;
    reg btnC;
    wire [1:0] led;

    // Instantiate DUT
    top_btn dut (
        .clk(clk),
        .reset(reset),
        .btnC(btnC),
        .led(led)
    );

    // 100MHz clock (10ns period)
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // 바운스 포함 버튼 누름
    task press_with_bounce;
        input integer bounce_cnt;
        input integer bounce_step_ns;
        input integer hold_ms;
        integer i;
        begin
            btnC = 0;

            // bouncing
            for (i = 0; i < bounce_cnt; i = i + 1) begin
                btnC = ~btnC;
                #(bounce_step_ns);
            end

            // 안정 HIGH
            btnC = 1;
            #(hold_ms * 1_000_000);
        end
    endtask

    // 바운스 포함 버튼 떼기
    task release_with_bounce;
        input integer bounce_cnt;
        input integer bounce_step_ns;
        input integer hold_ms;
        integer i;
        begin
            for (i = 0; i < bounce_cnt; i = i + 1) begin
                btnC = ~btnC;
                #(bounce_step_ns);
            end

            btnC = 0;
            #(hold_ms * 1_000_000);
        end
    endtask

    // 모니터
    initial begin
        $timeformat(-3,3," ms",10);
        $display("time     reset btnC led");
        $monitor("%t   %b     %b   %b",
                 $realtime/1_000_000.0, reset, btnC, led);
    end

    // Stimulus
    initial begin
        reset = 1;
        btnC  = 0;

        #100;
        reset = 0;

        // 조금 대기
        #(5_000_000); // 5ms

        // -------- Test 1 --------
        // 정상 토글 되어야 함
        press_with_bounce(8, 50_000, 60);   // 60ms 유지
        release_with_bounce(6, 50_000, 40);

        // -------- Test 2 --------
        press_with_bounce(10, 30_000, 70);
        release_with_bounce(8,  30_000, 40);

        // -------- Test 3 --------
        // 너무 짧게 눌렀을 때 (토글 안 될 가능성 확인)
        press_with_bounce(5, 20_000, 5);    // 5ms → 10ms 미만
        release_with_bounce(5, 20_000, 40);

        #(50_000_000); // 추가 50ms

        $finish;
    end

endmodule
