`timescale 1ns / 1ps

module motor_speed_ctrl(
    input  wire        clk,
    input  wire        reset,
    input  wire        speed_up,
    input  wire        speed_down,
    output reg [11:0]  duty
);

    reg [3:0] level;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            level <= 4'd8; // default 50%
        end else begin
            if (speed_up && !speed_down && level < 4'd15)
                level <= level + 4'd1;
            else if (speed_down && !speed_up && level > 4'd0)
                level <= level - 4'd1;
        end
    end

    always @(*) begin
        duty = {level, 8'hFF};
    end

endmodule
