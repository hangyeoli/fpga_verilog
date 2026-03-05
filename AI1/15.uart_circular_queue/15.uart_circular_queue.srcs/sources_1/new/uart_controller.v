`timescale 1ns / 1ps

module uart_controller(
    input clk,          // 100 MHz
    input reset,        // SW15
    input [7:0] send_data, // 1 byte
    input rx,             // UART ?섏떊 ?좏샇
    output tx,            // UART ?≪떊 ?좏샇
    output [7:0] rx_data, // ?섏떊???곗씠?????    output rx_done
    output rx_done,
    output [7:0] send_data_out
    );

    wire w_tick_1Hz;
    wire w_tx_busy, w_tx_done, w_tx_start;
    wire [7:0] w_tx_data;


    tick_gen #(
        .INPUT_FREQUENCY(100_000_000), // 100MHz
        .TICK_Hz(1) // 1kHz tick (500ms留덈떎 ?좉??대?濡?2Hz)
    ) u_tick_gen (
        .clk(clk),
        .reset(reset),
        .tick(w_tick_1Hz)
        );
    
    data_sender u_data_sender (
        .clk(clk),
        .reset(reset),
        .start_trigger(w_tick_1Hz), 
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
        .tx_data(w_tx_data), // data_sender 
        .tx_start(w_tx_start), // data_sender 
        .tx(tx), // UART
        .tx_done(w_tx_done), // UART 
        .tx_busy(w_tx_busy) // UART 
    );

    uart_rx #(
        .BPS(9600)
    ) u_uart_rx (
        .clk(clk),
        .reset(reset),
        .rx(rx),
        .data_out(rx_data),
        .rx_done(rx_done)
    );

    assign send_data_out = send_data;


endmodule
