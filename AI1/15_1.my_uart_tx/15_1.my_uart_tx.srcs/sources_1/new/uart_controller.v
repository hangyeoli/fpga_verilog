`timescale 1ns / 1ps

module uart_controller(
    input clk,
    input reset,
    input [7:0] send_data,
    input btn_start,
    output tx,
    output tx_busy,
    output tx_done
);

    wire w_tx_busy;
    wire w_tx_done;
    wire w_tx_start;
    wire [7:0] w_tx_data;

    data_sender u_data_sender (
        .clk(clk),
        .reset(reset),
        .btn_start(btn_start),
        .send_data(send_data),
        .tx_busy(w_tx_busy),
        .tx_done(w_tx_done),
        .tx_start(w_tx_start),
        .tx_data(w_tx_data)
    );

    uart_tx #(
        .BPS(9600)
    ) u_uart_tx (
        .clk(clk),
        .reset(reset),
        .tx_data(send_data),
        .tx_start(w_tx_start),
        .tx(tx),
        .tx_done(w_tx_done),
        .tx_busy(w_tx_busy)
    );

    uart_rx #(
        .BPS(9600)
    ) u_uart_rx (
        .clk(clk),
        .reset(reset),
        .rx(tx), // Loopback for testing
        .rx_data(), // 수신된 데이터 저장 (필요에 따라 연결)
        .rx_done() // 수신 완료 신호 (필요에 따라 연결)
    );

    assign tx_busy = w_tx_busy;
    assign tx_done = w_tx_done;

endmodule
