`timescale 1ns / 1ps

module edge_detect(
    input  wire clk,
    input  wire reset,
    input  wire signal_in,
    output wire rising_edge
);

    reg signal_d = 0;

    always @(posedge clk or posedge reset) begin
        if (reset)
            signal_d <= 0;
        else
            signal_d <= signal_in;
    end

    assign rising_edge = signal_in & ~signal_d;

endmodule

