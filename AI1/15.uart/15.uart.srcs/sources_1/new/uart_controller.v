`timescale 1ns / 1ps

module uart_controller(
    input clk,          // 100 MHz
    input reset,        // SW15
    input [7:0] send_data, // 1 byte
    input rx,             // UART 수신 신호
    output tx,            // UART 송신 신호
    output [7:0] rx_data, // 수신된 데이터 저장
    output rx_done
    );

    wire w_tick_1Hz;
    wire w_tx_busy, w_tx_done, w_tx_start;
    wire [7:0] w_tx_data;


    tick_gen #(
        .INPUT_FREQUENCY(100_000_000), // 100MHz
        .TICK_Hz(1) // 1kHz tick (500ms마다 토글이므로 2Hz)
    ) u_tick_gen (
        .clk(clk),
        .reset(reset),
        .tick(w_tick_1Hz)
        );
    
    data_sender u_data_sender (
        .clk(clk),
        .reset(reset),
        .start_trigger(w_tick_1Hz), // 1초마다 송신 시작
        .send_data(send_data), // 외부에서 보낼 데이터 입력
        .tx_busy(w_tx_busy), // UART 송신 중 신호 (uart_tx 모듈과 연결 필요)
        .tx_done(w_tx_done), // UART 송신 완료 신호 (uart_tx 모듈과 연결 필요)
        .tx_start(w_tx_start), // UART 송신 시작 신호 (uart_tx 모듈과 연결 필요)
        .tx_data(w_tx_data) // UART로 보낼 데이터 (uart_tx 모듈과 연결 필요)
    );

    uart_tx #(
        .BPS(9600) // 보레이트 설정
    ) u_uart_tx (
        .clk(clk),
        .reset(reset),
        .tx_data(w_tx_data), // data_sender 모듈에서 보낼 데이터 연결
        .tx_start(w_tx_start), // data_sender 모듈에서 송신 시작 신호 연결
        .tx(tx), // UART 송신 신호 출력
        .tx_done(w_tx_done), // UART 송신 완료 신호 출력 (data_sender 모듈과 연결 필요)
        .tx_busy(w_tx_busy) // UART 송신 중 신호 출력 (data_sender 모듈과 연결 필요)
    );


endmodule
