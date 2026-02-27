`timescale 1ns / 1ps

module top_buzzer(
    input clk,
    input reset,
    input btnU,
    input btnL,
    input btnC,
    input btnR,
    input btnD,
    output [1:0] led,
    output buzzer
    );

    wire w_btnU, w_btnL, w_btnC, w_btnR, w_btnD;

    assign led[0] = w_btnU | w_btnL | w_btnC | w_btnR | w_btnD;
    assign led[1] = buzzer;
    
    debouncer u_btnU_debouncer (
        .clk(clk),
        .reset(reset),
        .noisy_btn(btnU),
        .clean_btn(w_btnU)
    );

    debouncer u_btnL_debouncer (
        .clk(clk),
        .reset(reset),
        .noisy_btn(btnL),
        .clean_btn(w_btnL)
    );

    debouncer u_btnC_debouncer (
        .clk(clk),
        .reset(reset),
        .noisy_btn(btnC),
        .clean_btn(w_btnC)
    );

    debouncer u_btnR_debouncer (
        .clk(clk),
        .reset(reset),
        .noisy_btn(btnR),
        .clean_btn(w_btnR)
    );

    debouncer u_btnD_debouncer (
        .clk(clk),
        .reset(reset),
        .noisy_btn(btnD),
        .clean_btn(w_btnD)
    );

    play_melody u_play_melody (
        .clk(clk),
        .reset(reset),
        .btnU(w_btnU),
        .btnL(w_btnL),
        .btnC(w_btnC),
        .btnR(w_btnR),
        .btnD(w_btnD),
        .buzzer(buzzer)
    );

endmodule
