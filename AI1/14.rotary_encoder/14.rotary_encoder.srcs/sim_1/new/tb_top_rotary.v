`timescale 1ns / 1ps

// sim 속도를 높이기 위해서 debouncer의 DEBOUNCE_LIMIT을 200으로 줄였습니다. (원래 200_000)
module tb_top_rotary();
    reg clk;
    reg reset;
    reg s1;
    reg s2;
    reg key;

    wire [15:0] led;

    top_rotary u_top_rotary (
        .clk(clk),
        .reset(reset),
        .s1(s1),
        .s2(s2),
        .key(key),
        .led(led)
    );

    always #5 clk = ~clk; // 100 MHz

    //일괄적으로 50ns x3 noise를 만든다.
    task make_btn_noise(input integer sw);
        begin
            repeat(3) begin
                if (sw==0) s1 = ~s1;
                else if (sw==1) s2 = ~s2;
                else if (sw==2) key = ~key;
                #50; // 채터링 간격은 50ns 
            end
        end
    endtask

    initial begin
        clk = 0; reset = 1; s1 = 0; s2 = 0; key = 0;
        #100;
        reset = 0;
        #100;
        // CW 00 --> 10 --> 11 --> 01 --> 00
        $display("CW TEST start......");
        make_btn_noise(0); s1 =1; #3000; // 200cycle (10us x 200) : noise 보다 긴 3000ns 대기
        

    end

endmodule
