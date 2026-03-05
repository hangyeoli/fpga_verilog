`timescale 1ns / 1ps

module top(
    input clk,          // 100 MHz
    input reset,        // SW15
    input [2:0] btn,      
    input [7:0] sw,
    input RsRx,
    output RsTx,
    output [7:0] seg,
    output [3:0] an,
    output [15:0] led,
    output uartTx, //JB1 for 오실로스코프 
    input uartRx   //JB2 
    );

    uart_controller u_uart_controller (
        .clk(clk),
        .reset(reset),
        .send_data(8'h30), // '0'의 ASCII 코드 (예: 0x30)
        .rx(RsRx), // UART 수신 신호 연결
        .tx(RsTx), // UART 송신 신호 연결
        .rx_data(), // 수신된 데이터 저장 (필요에 따라 연결)
        .rx_done() // 수신 완료 신호 (필요에 따라 연결)
    );

    assign uartTx = RsTx; // 오실로스코프 측정 단자
    assign uartRx = RsRx; 


endmodule
