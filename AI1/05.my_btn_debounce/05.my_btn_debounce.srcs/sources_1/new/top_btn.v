`timescale 1ns / 1ps

module top_btn(
    input  wire clk,
    input  wire reset,
    input  wire btnC,
    output wire [1:0] led
);

    wire btn_clean;
    wire btn_pulse;
    wire led_out;

    debounce_timer u_debounce (
        .clk(clk),
        .reset(reset),
        .btn_in(btnC),
        .btn_clean(btn_clean)
    );

    edge_detect u_edge (
        .clk(clk),
        .reset(reset),
        .signal_in(btn_clean),
        .rising_edge(btn_pulse)
    );

    led_toggle u_toggle (
        .clk(clk),
        .reset(reset),
        .toggle_pulse(btn_pulse),
        .led(led_out)
    );

    assign led[0] = led_out;
    assign led[1] = 1'b0;

endmodule
