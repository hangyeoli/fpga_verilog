`timescale 1ns / 1ps

module fsm_pattern(
    input  wire clk,
    input  wire reset,      // asynchronous active-high reset
    input  wire din_bit,
    output reg  detect_out
);

localparam START = 3'd0;
localparam ST1   = 3'd1;
localparam ST2   = 3'd2;
localparam ST3   = 3'd3;
localparam ST4   = 3'd4;

reg [2:0] current_state;
reg [2:0] next_state;

// Next-state logic (Mealy FSM for pattern 0110)
always @(*) begin
    case (current_state)
        START: next_state = (din_bit == 1'b1) ? START : ST1;
        ST1:   next_state = (din_bit == 1'b1) ? ST2   : ST1;
        ST2:   next_state = (din_bit == 1'b1) ? ST3   : ST1;
        ST3:   next_state = (din_bit == 1'b1) ? START : ST4;
        ST4:   next_state = (din_bit == 1'b1) ? ST2   : ST1;
        default: next_state = START;
    endcase
end

// State register with asynchronous active-high reset
always @(posedge clk or posedge reset) begin
    if (reset)
        current_state <= START;
    else
        current_state <= next_state;
end

// Output logic: detect when final '0' of 0110 arrives (state ST3 + input 0)
always @(*) begin
    detect_out = (current_state == ST3 && din_bit == 1'b0) ? 1'b1 : 1'b0;
end

endmodule
