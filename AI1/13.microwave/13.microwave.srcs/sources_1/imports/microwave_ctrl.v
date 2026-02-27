`timescale 1ns / 1ps

module microwave_ctrl(
    input  wire       clk,
    input  wire       reset,
    input  wire       tick_1s,
    input  wire       tick_300ms,
    input  wire       btn_add_min,
    input  wire       btn_add_30s,
    input  wire       btn_door_toggle,
    input  wire       btn_start_cancel,
    output wire       running,
    output reg        door_open,
    output wire       done_active,
    output wire       done_on,
    output wire       evt_button,
    output wire       evt_door,
    output wire [3:0] min_tens,
    output wire [3:0] min_ones,
    output wire [3:0] sec_tens,
    output wire [3:0] sec_ones
);

    localparam [2:0] ST_IDLE   = 3'd0;
    localparam [2:0] ST_SET    = 3'd1;
    localparam [2:0] ST_RUN    = 3'd2;
    localparam [2:0] ST_PAUSE  = 3'd3;
    localparam [2:0] ST_DONE   = 3'd4;

    reg [2:0] state;
    reg [2:0] done_phase;
    reg [12:0] time_sec; // 0..5999 (99:59)

    wire [6:0] minutes = time_sec / 13'd60;
    wire [5:0] seconds = time_sec % 13'd60;

    assign min_tens = minutes / 7'd10;
    assign min_ones = minutes % 7'd10;
    assign sec_tens = seconds / 6'd10;
    assign sec_ones = seconds % 6'd10;

    assign running = (state == ST_RUN);
    assign done_active = (state == ST_DONE);
    assign done_on = (done_phase[0] == 1'b0);

    assign evt_door = btn_door_toggle;
    assign evt_button = btn_add_min | btn_add_30s | btn_start_cancel;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state      <= ST_IDLE;
            door_open  <= 1'b0;    // initial: door closed
            time_sec   <= 13'd0;
            done_phase <= 3'd0;
        end else begin
            case (state)
                ST_IDLE: begin
                    if (btn_door_toggle)
                        door_open <= ~door_open;

                    if (btn_add_min) begin
                        if (time_sec <= 13'd5939)
                            time_sec <= time_sec + 13'd60;
                        else
                            time_sec <= 13'd5999;
                        state <= ST_SET;
                    end else if (btn_add_30s) begin
                        if (time_sec <= 13'd5969)
                            time_sec <= time_sec + 13'd30;
                        else
                            time_sec <= 13'd5999;
                        state <= ST_SET;
                    end else if (btn_start_cancel && !door_open && (time_sec != 13'd0)) begin
                        state <= ST_RUN;
                    end
                end

                ST_SET: begin
                    if (btn_door_toggle)
                        door_open <= ~door_open;

                    if (btn_add_min) begin
                        if (time_sec <= 13'd5939)
                            time_sec <= time_sec + 13'd60;
                        else
                            time_sec <= 13'd5999;
                    end
                    if (btn_add_30s) begin
                        if (time_sec <= 13'd5969)
                            time_sec <= time_sec + 13'd30;
                        else
                            time_sec <= 13'd5999;
                    end

                    if (btn_start_cancel) begin
                        if (!door_open && (time_sec != 13'd0)) begin
                            state <= ST_RUN;   // start
                        end else begin
                            time_sec <= 13'd0; // stop/cancel
                            state <= ST_IDLE;
                        end
                    end
                end

                ST_RUN: begin
                    if (btn_start_cancel) begin
                        // stop/cancel
                        time_sec <= 13'd0;
                        state <= ST_IDLE;
                    end else if (btn_door_toggle) begin
                        // running + door button => pause + door open
                        door_open <= 1'b1;
                        state <= ST_PAUSE;
                    end else if (tick_1s) begin
                        if (time_sec == 13'd1) begin
                            time_sec <= 13'd0;
                            done_phase <= 3'd0;
                            state <= ST_DONE;
                        end else if (time_sec != 13'd0) begin
                            time_sec <= time_sec - 13'd1;
                        end
                    end
                end

                ST_PAUSE: begin
                    if (btn_start_cancel) begin
                        // stop/cancel from pause
                        time_sec <= 13'd0;
                        state <= ST_IDLE;
                    end else if (btn_door_toggle) begin
                        // pause + door button => close and resume
                        door_open <= 1'b0;
                        if (time_sec != 13'd0)
                            state <= ST_RUN;
                        else
                            state <= ST_IDLE;
                    end
                end

                default: begin // ST_DONE
                    if (tick_300ms) begin
                        if (done_phase == 3'd5) begin
                            done_phase <= 3'd0;
                            door_open <= 1'b0;
                            state <= ST_IDLE;
                        end else begin
                            done_phase <= done_phase + 3'd1;
                        end
                    end
                end
            endcase
        end
    end

endmodule
