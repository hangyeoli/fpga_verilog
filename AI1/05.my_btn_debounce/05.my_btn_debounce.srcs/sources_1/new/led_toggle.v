`timescale 1ns / 1ps

module led_toggle(
    input  wire clk,
    input  wire reset,
    input  wire toggle_pulse,
    output reg  led
);

    always @(posedge clk or posedge reset) begin
        if (reset)
            led <= 0;
        else if (toggle_pulse)
            led <= ~led;
    end

endmodule
