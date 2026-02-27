`timescale 1ns / 1ps

module buzzer_controller(
    input  wire       clk,
    input  wire       reset,
    input  wire       event_button,
    input  wire       event_door,
    input  wire       door_open,
    input  wire       done_active,
    input  wire       done_on,
    output wire       buzzer
);

    localparam [1:0] MODE_IDLE = 2'd0;
    localparam [1:0] MODE_BTN  = 2'd1;
    localparam [1:0] MODE_DOOR = 2'd2;
    localparam [1:0] MODE_DONE = 2'd3;

    localparam integer BTN_LEN  = 8_000_000;   // 80ms
    localparam integer DOOR_LEN = 12_000_000;  // 120ms

    localparam [16:0] BTN_HALF       = 17'd20_833; // ~2.4kHz
    localparam [16:0] DOOR_OPEN_HALF = 17'd50_000;
    localparam [16:0] DOOR_CLOSE_HALF= 17'd31_250;
    localparam [16:0] DONE_HALF      = 17'd25_000;

    reg [1:0]  mode;
    reg [26:0] len_cnt;
    reg [16:0] tone_cnt;
    reg        buzz;

    wire done_beep = done_active && done_on;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            mode <= MODE_IDLE;
            len_cnt <= 27'd0;
            tone_cnt <= 17'd0;
            buzz <= 1'b0;
        end else begin
            case (mode)
                MODE_IDLE: begin
                    buzz <= 1'b0;
                    tone_cnt <= 17'd0;
                    len_cnt <= 27'd0;

                    if (done_beep) begin
                        mode <= MODE_DONE;
                    end else if (event_door) begin
                        mode <= MODE_DOOR;
                        len_cnt <= DOOR_LEN;
                    end else if (event_button) begin
                        mode <= MODE_BTN;
                        len_cnt <= BTN_LEN;
                    end
                end

                MODE_BTN: begin
                    if (done_beep) begin
                        mode <= MODE_DONE;
                        tone_cnt <= 17'd0;
                    end else if (event_door) begin
                        mode <= MODE_DOOR;
                        len_cnt <= DOOR_LEN;
                        tone_cnt <= 17'd0;
                    end else if (len_cnt == 27'd0) begin
                        mode <= MODE_IDLE;
                        buzz <= 1'b0;
                        tone_cnt <= 17'd0;
                    end else begin
                        len_cnt <= len_cnt - 27'd1;
                        if (tone_cnt >= BTN_HALF - 1) begin
                            tone_cnt <= 17'd0;
                            buzz <= ~buzz;
                        end else begin
                            tone_cnt <= tone_cnt + 17'd1;
                        end
                    end
                end

                MODE_DOOR: begin
                    if (done_beep) begin
                        mode <= MODE_DONE;
                        tone_cnt <= 17'd0;
                    end else if (event_door) begin
                        mode <= MODE_DOOR;
                        len_cnt <= DOOR_LEN;
                        tone_cnt <= 17'd0;
                    end else if (len_cnt == 27'd0) begin
                        mode <= MODE_IDLE;
                        buzz <= 1'b0;
                        tone_cnt <= 17'd0;
                    end else begin
                        len_cnt <= len_cnt - 27'd1;
                        if (door_open) begin
                            if (tone_cnt >= DOOR_OPEN_HALF - 1) begin
                                tone_cnt <= 17'd0;
                                buzz <= ~buzz;
                            end else begin
                                tone_cnt <= tone_cnt + 17'd1;
                            end
                        end else begin
                            if (tone_cnt >= DOOR_CLOSE_HALF - 1) begin
                                tone_cnt <= 17'd0;
                                buzz <= ~buzz;
                            end else begin
                                tone_cnt <= tone_cnt + 17'd1;
                            end
                        end
                    end
                end

                default: begin // MODE_DONE
                    if (!done_beep) begin
                        mode <= MODE_IDLE;
                        buzz <= 1'b0;
                        tone_cnt <= 17'd0;
                    end else begin
                        if (tone_cnt >= DONE_HALF - 1) begin
                            tone_cnt <= 17'd0;
                            buzz <= ~buzz;
                        end else begin
                            tone_cnt <= tone_cnt + 17'd1;
                        end
                    end
                end
            endcase
        end
    end

    assign buzzer = buzz;

endmodule
