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

    // --- UART circular queue for command parsing ---
    localparam integer Q_DEPTH = 16;
    localparam [3:0] Q_LAST    = Q_DEPTH - 1;
    reg [7:0] r_rx_queue [0:Q_DEPTH-1];
    reg [3:0] r_q_head;
    reg [3:0] r_q_tail;
    reg [4:0] r_q_count;

    reg       r_pop_valid;
    reg [7:0] r_pop_data;

    reg [7:0] r_cmd_buf [0:6]; // "led0off" max 7 chars
    reg [2:0] r_cmd_len;
    reg       r_led0_cmd;
    integer   i;

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
        led[13:1] <= 0;
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
        led[13:1] <= r_ms10_counter[13:1];
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
        led[13:1] <= r_ms10_counter[13:1];
    end else begin
        r_counter <= 0;
        r_ms10_counter <= 0;
        led[13:1] <= 0;
    end
end

// --- UART RX circular queue push/pop ---
always @(posedge clk, posedge reset) begin
    if (reset) begin
        r_q_head   <= 0;
        r_q_tail   <= 0;
        r_q_count  <= 0;
        r_pop_valid <= 1'b0;
        r_pop_data <= 8'h00;
    end else begin
        r_pop_valid <= 1'b0;

        // push on RX done (if queue not full)
        if (rx_done && (r_q_count < Q_DEPTH)) begin
            r_rx_queue[r_q_tail] <= rx_data;
            if (r_q_tail == Q_LAST)
                r_q_tail <= 0;
            else
                r_q_tail <= r_q_tail + 1'b1;
            r_q_count <= r_q_count + 1'b1;
        end
        // pop when queue has data
        else if (r_q_count != 0) begin
            r_pop_data  <= r_rx_queue[r_q_head];
            r_pop_valid <= 1'b1;
            if (r_q_head == Q_LAST)
                r_q_head <= 0;
            else
                r_q_head <= r_q_head + 1'b1;
            r_q_count <= r_q_count - 1'b1;
        end
    end
end

// --- command parser: led0on / led0off ---
always @(posedge clk, posedge reset) begin
    if (reset) begin
        r_cmd_len  <= 0;
        r_led0_cmd <= 1'b0;
        for (i = 0; i < 7; i = i + 1)
            r_cmd_buf[i] <= 8'h00;
    end else if (r_pop_valid) begin
        // delimiters: CR/LF/SPACE
        if ((r_pop_data == 8'h0D) || (r_pop_data == 8'h0A) || (r_pop_data == 8'h20)) begin
            if ((r_cmd_len == 3'd6) &&
                (r_cmd_buf[0] == 8'h6C) && // l
                (r_cmd_buf[1] == 8'h65) && // e
                (r_cmd_buf[2] == 8'h64) && // d
                (r_cmd_buf[3] == 8'h30) && // 0
                (r_cmd_buf[4] == 8'h6F) && // o
                (r_cmd_buf[5] == 8'h6E))   // n
                r_led0_cmd <= 1'b1;
            else if ((r_cmd_len == 3'd7) &&
                (r_cmd_buf[0] == 8'h6C) && // l
                (r_cmd_buf[1] == 8'h65) && // e
                (r_cmd_buf[2] == 8'h64) && // d
                (r_cmd_buf[3] == 8'h30) && // 0
                (r_cmd_buf[4] == 8'h6F) && // o
                (r_cmd_buf[5] == 8'h66) && // f
                (r_cmd_buf[6] == 8'h66))   // f
                r_led0_cmd <= 1'b0;

            r_cmd_len <= 0;
        end else begin
            // no delimiter mode support: "led0on"/"led0off" itself triggers
            if ((r_cmd_len == 3'd5) &&
                (r_cmd_buf[0] == 8'h6C) && // l
                (r_cmd_buf[1] == 8'h65) && // e
                (r_cmd_buf[2] == 8'h64) && // d
                (r_cmd_buf[3] == 8'h30) && // 0
                (r_cmd_buf[4] == 8'h6F) && // o
                (r_pop_data   == 8'h6E))   // n
            begin
                r_led0_cmd <= 1'b1;
                r_cmd_len <= 0;
            end else if ((r_cmd_len == 3'd6) &&
                (r_cmd_buf[0] == 8'h6C) && // l
                (r_cmd_buf[1] == 8'h65) && // e
                (r_cmd_buf[2] == 8'h64) && // d
                (r_cmd_buf[3] == 8'h30) && // 0
                (r_cmd_buf[4] == 8'h6F) && // o
                (r_cmd_buf[5] == 8'h66) && // f
                (r_pop_data   == 8'h66))   // f
            begin
                r_led0_cmd <= 1'b0;
                r_cmd_len <= 0;
            end else if (r_cmd_len < 3'd7) begin
                r_cmd_buf[r_cmd_len] <= r_pop_data;
                r_cmd_len <= r_cmd_len + 1'b1;
            end else begin
                for (i = 0; i < 6; i = i + 1)
                    r_cmd_buf[i] <= r_cmd_buf[i+1];
                r_cmd_buf[6] <= r_pop_data;
                r_cmd_len <= 3'd7;
            end
        end
    end
end

// LED0 is command-controlled
always @(posedge clk, posedge reset) begin
    if (reset)
        led[0] <= 1'b0;
    else
        led[0] <= r_led0_cmd;
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
