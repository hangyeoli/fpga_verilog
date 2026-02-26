`timescale 1ns / 1ps

module add8(
    input  [15:0] sw,   // sw[7:0] = A, sw[15:8] = B
    output carry_out,
    output [7:0] sum
);

    assign {carry_out, sum} = sw[7:0] + sw[15:8];

endmodule
