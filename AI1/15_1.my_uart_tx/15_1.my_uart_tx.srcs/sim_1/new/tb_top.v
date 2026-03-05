`timescale 1ns / 1ps

module tb_top;
    reg clk;
    reg reset;
    reg btn_start;
    reg [7:0] sw;
    reg RsRx;
    reg uartRx;

    wire RsTx;
    wire [7:0] seg;
    wire [3:0] an;
    wire [15:0] led;
    wire uartTx;

    top u_top (
        .clk(clk),
        .reset(reset),
        .btn_start(btn_start),
        .sw(sw),
        .RsRx(RsRx),
        .RsTx(RsTx),
        .seg(seg),
        .an(an),
        .led(led),
        .uartTx(uartTx),
        .uartRx(uartRx)
    );

    always #5 clk = ~clk; // 100 MHz

    task send_byte(input [7:0] data);
        begin
            sw = data;
            #20;
            btn_start = 1'b1;
            #10;
            btn_start = 1'b0;
            @(posedge led[1]); // tx_done pulse
            #20;
        end
    endtask

    initial begin
        clk = 1'b0;
        reset = 1'b1;
        btn_start = 1'b0;
        sw = 8'h00;
        RsRx = 1'b1;
        uartRx = 1'b1;

        #100;
        reset = 1'b0;
        #100;

        send_byte(8'h4C); // 'L'
        send_byte(8'h48); // 'H'
        send_byte(8'h47); // 'G'

        #1000;
        $finish;
    end

endmodule
