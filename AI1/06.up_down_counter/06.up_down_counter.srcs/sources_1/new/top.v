`timescale 1ns / 1ps

module top(
    input clk,
    input reset,   // sw[15]
    input [2:0] btn,   // btn[0]: btnL btn[1]: btnC btn[2]: btnR
    input [7:0] sw,
    output [7:0] seg,
    output [3:0] an,
    output [15:0] led
    );

    wire [2:0] w_debounced_btn;
    wire [13:0] w_seg_data;
    wire w_tick;
    
    //wire [15:0] w_ct_led;

    btn_debouncer u_btn_debouncer(
        .clk(clk),
        .reset(reset),
        .btn(btn),  // 3개의 버튼 입력: btn[2:0] → 각각 btnL, btnC, btnR
        .debounced_btn(w_debounced_btn)
    );

    control_tower u_control_tower(
        .clk(clk),
        .reset(reset),
        .btn(w_debounced_btn),
        .sw(sw),
        .seg_data(w_seg_data), // 연결되지 않음
        .mode_led(w_mode_led)       // 연결되지 않음
    );

    fnd_controller u_fnd_controller(
        .clk(clk),
        .reset(reset),
        .tick(w_tick),
        .in_data(w_seg_data), // 연결되지 않음
        .an(an),
        .seg(seg)
    );
    tick_gen u_tick_gen(
        .clk(clk),
        .reset(reset),
        .tick(w_tick)
    );
    assign led[0]   = w_tick;     // 500ms 토글
    assign led[15:14] = w_mode_led;   // 모드 표시
    assign led[13:1]  = 13'b0;        // 나머지는 0 (원하면 sw값 표시 등으로 바꿔도 됨)

    //assign JXADC = w_debounced_btn; // 디바운스된 버튼 상태를 JXADC 포트로 출력
    // assign led = w_debounced_btn;   // 디바운스된 버튼 상태를 LED로 출력

endmodule
