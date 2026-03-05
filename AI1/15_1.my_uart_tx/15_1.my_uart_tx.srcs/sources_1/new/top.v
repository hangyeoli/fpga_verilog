`timescale 1ns / 1ps

module top(
    input clk,
    input reset,
    input btn_start,
    input [7:0] sw,
    input RsRx,
    output RsTx,
    output [7:0] seg,
    output [3:0] an,
    output [15:0] led,
    output uartTx,
    input uartRx
);
    wire [7:0] w_rx_data;
    wire w_rx_done;

    wire uart_tx_busy;
    wire uart_tx_done;

    uart_controller u_uart_controller (
        .clk(clk),
        .reset(reset),
        .send_data(sw),
        .btn_start(btn_start),
        .tx(RsTx),
        .tx_busy(uart_tx_busy),
        .tx_done(uart_tx_done)
    );

    assign uartTx = RsTx;

    assign led[0] = uart_tx_busy;
    assign led[1] = uart_tx_done;
    assign led[15:2] = 14'd0;

    assign seg = 8'hFF;
    assign an = 4'hF;

    // Keep unused RX inputs to avoid lint warnings.
    wire _unused_ok;
    assign _unused_ok = RsRx ^ uartRx;

endmodule
