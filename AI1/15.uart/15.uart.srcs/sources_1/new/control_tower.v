`timescale 1ns / 1ps

module control_tower(
    input clk,
    input reset,
    input [2:0] btn,
    input [7:0] sw,
    input [7:0] rx_data,
    input rx_done,
    output [13:0] seg_data,
    output reg [15:0] led
    );

    // mode definition
    parameter UP_COUNTER = 2'b01;
    parameter DOWN_COUNTER = 2'b10;
    parameter SLIDE_SW_READ = 2'b11;

    reg r_prev_btnL=0;
    reg [2:0] r_mode=3'b000;
    reg [19:0] r_counter; //10ms delay counter 10ns x 1,000,000 = 10ms
    reg [13:0] r_ms10_counter; // 1

    // mode check 
    always @(posedge clk, posedge reset) begin
        if (reset) begin
            r_mode <= 0;
            r_prev_btnL <= 0;
        end else begin
            if (btn[0] && !r_prev_btnL)
                r_mode <= (r_mode == SLIDE_SW_READ) ? UP_COUNTER : (r_mode + 1);
            if (rx_done && rx_data == 8'h4D) // 4d ---> 'M'
                r_mode <= (r_mode == SLIDE_SW_READ) ? UP_COUNTER : (r_mode + 1);
        end
        r_prev_btnL <= btn[0];
    end

// up counter
always @(posedge clk, posedge reset) begin
    if (reset) begin
        r_counter <= 0;
        r_ms10_counter <= 0;
        led[13:0] <= 0;
    end else if (r_mode == UP_COUNTER) begin
        if (r_counter == 20'd1_000_000-1) begin
            r_counter <= 0;
            if (r_ms10_counter >= 9999)
                r_ms10_counter <= 0;
            else
                r_ms10_counter <= r_ms10_counter + 1;
        end else begin
            r_counter <= r_counter + 1;    
        end
        led[13:0] <= r_ms10_counter;
    end else if (r_mode == DOWN_COUNTER) begin
        if (r_counter == 20'd1_000_000-1) begin
            r_counter <= 0;
            if (r_ms10_counter == 0)
                r_ms10_counter <= 9999;
            else
                r_ms10_counter <= r_ms10_counter - 1;
        end else begin
            r_counter <= r_counter + 1;
        end
        led[13:0] <= r_ms10_counter;
    end else begin
        r_counter <= 0;
        r_ms10_counter <= 0;
        led[13:0] <= 0;
    end
end


// --- led mode display ---
always @(r_mode) begin
    case (r_mode)
        UP_COUNTER: begin
            led[15:14] = UP_COUNTER;
        end
        DOWN_COUNTER: begin
            led[15:14] = DOWN_COUNTER;
        end
        SLIDE_SW_READ: begin
            led[15:14] = SLIDE_SW_READ;
        end
        default: led[15:14] = 2'b00;
    endcase
end
    // --- seg_data assignment ---
assign seg_data = (r_mode == UP_COUNTER) ? r_ms10_counter :
                  (r_mode == DOWN_COUNTER) ? r_ms10_counter :
                  {6'b0, sw};

endmodule
