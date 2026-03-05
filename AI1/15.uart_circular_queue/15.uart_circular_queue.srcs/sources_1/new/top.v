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
    output uartTx, //JB1 for UART Tx
    input uartRx   //JB2 for UART Rx
    );

    wire [7:0] w_rx_data;
    wire w_rx_done;
    wire [13:0] w_seg_data;
    wire [2:0] w_clean_btn;
    wire [7:0] w_send_data;

    btn_debouncer u_btn_debouncer (
        .clk(clk),
        .reset(reset),
        .btn(btn),
        .debounced_btn(w_clean_btn)
    );

    control_tower u_control_tower (
        .clk(clk),
        .reset(reset),
        .btn(w_clean_btn),
        .sw(w_send_data),
        .rx_data(w_rx_data),
        .rx_done(w_rx_done), 
        .seg_data(w_seg_data),
        .led(led)
    );

    uart_controller u_uart_controller (
        .clk(clk),
        .reset(reset),
        .send_data(sw), 
        .send_data_out(w_send_data),
        .rx(RsRx), 
        .tx(RsTx),
        .rx_data(w_rx_data), 
        .rx_done(w_rx_done) 
    );

    assign uartTx = RsTx; 
    


endmodule
