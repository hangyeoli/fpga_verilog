`timescale 1ns / 1ps

module pwm_gen #(
    parameter integer WIDTH = 12
)(
    input  wire             clk,
    input  wire             reset,
    input  wire             enable,
    input  wire [WIDTH-1:0] duty,
    output wire             pwm_out
);

    reg [WIDTH-1:0] cnt;

    always @(posedge clk or posedge reset) begin
        if (reset)
            cnt <= {WIDTH{1'b0}};
        else
            cnt <= cnt + {{(WIDTH-1){1'b0}}, 1'b1};
    end

    assign pwm_out = enable && (cnt < duty);

endmodule
