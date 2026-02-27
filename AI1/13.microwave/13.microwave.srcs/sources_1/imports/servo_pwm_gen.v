`timescale 1ns / 1ps

module servo_pwm_gen #(
    parameter integer CLK_HZ   = 100_000_000,
    parameter integer PWM_HZ   = 50,
    parameter integer CLOSE_US = 1000,
    parameter integer OPEN_US  = 2000,
    parameter integer STOP_US  = 1500,
    parameter integer MOVE_MS  = 250
)(
    input  wire clk,
    input  wire reset,
    input  wire move_trigger,
    input  wire door_open,
    output wire pwm_out
);

    localparam integer PERIOD_CNT = CLK_HZ / PWM_HZ;
    localparam integer CLOSE_CNT  = (CLK_HZ / 1_000_000) * CLOSE_US;
    localparam integer OPEN_CNT   = (CLK_HZ / 1_000_000) * OPEN_US;
    localparam integer STOP_CNT   = (CLK_HZ / 1_000_000) * STOP_US;
    localparam integer MOVE_TICKS = (CLK_HZ / 1_000) * MOVE_MS;

    localparam integer CNT_W = $clog2(PERIOD_CNT);
    localparam integer MOVE_W = $clog2(MOVE_TICKS);

    reg [CNT_W-1:0] cnt;
    wire [CNT_W-1:0] hi_cnt;
    reg              move_active;
    reg              move_to_open;
    reg [MOVE_W-1:0] move_cnt;

    assign hi_cnt = move_active ? (move_to_open ? OPEN_CNT : CLOSE_CNT) : STOP_CNT;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            cnt <= {CNT_W{1'b0}};
            move_active <= 1'b0;
            move_to_open <= 1'b0;
            move_cnt <= {MOVE_W{1'b0}};
        end else begin
            if (cnt == PERIOD_CNT - 1)
                cnt <= {CNT_W{1'b0}};
            else
                cnt <= cnt + 1'b1;

            // btnC event: rotate only for a short duration, then stop
            if (move_trigger) begin
                move_active <= 1'b1;
                move_to_open <= ~door_open;
                move_cnt <= MOVE_TICKS - 1;
            end else if (move_active) begin
                if (move_cnt == 0) begin
                    move_active <= 1'b0;
                end else begin
                    move_cnt <= move_cnt - 1'b1;
                end
            end
        end
    end

    assign pwm_out = (cnt < hi_cnt);

endmodule
