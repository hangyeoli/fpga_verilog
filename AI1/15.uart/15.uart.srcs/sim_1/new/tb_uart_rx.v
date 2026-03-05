`timescale 1ns / 1ps
module tb_uart_rx();

    reg clk;
    reg reset;
    reg rx;

    wire [7:0] data_out;
    wire rx_done;

    




    uart_rx #(
        .BPS(9600)
    ) u_uart_rx (
        .clk(clk),
        .reset(reset),
        .rx(rx),
        .data_out(data_out),
        .rx_done(rx_done)
    );


    initial clk = 0;
    always #5 clk = ~clk; // 100 MHz
    // clk 1주기 10ns (5ns 상승, 5ns 하강)

    localparam CLK_FREQUENCY = 100000000; // 100 MHz
    localparam BIT_PER_CLK_NUMBER = CLK_FREQUENCY / 9600; 
    localparam CLK_PERIOD_10NS = 10; // 10ns
    localparam BAUD_PERIOD = BIT_PER_CLK_NUMBER * CLK_PERIOD_10NS;// sim wait 시간

    always @(posedge rx_done) begin
        $display("Received byte: %h", data_out);        
    end

    //UART RX simulaor
    //ASCII 'U'와 'u'를 uart_rx로 전송하는 시뮬레이터
    initial begin
        #00 reset = 1; rx = 1; clk = 0; 
        #100 reset = 0; // Reset 해제
        #200;
        //-----'U' 0x55 (0101_0101) 전송-----
        #BAUD_PERIOD; rx = 0; // Start bit
        #BAUD_PERIOD; rx = 1; // Bit 0
        #BAUD_PERIOD; rx = 0; // Bit 1
        #BAUD_PERIOD; rx = 1; // Bit 2
        #BAUD_PERIOD; rx = 0; // Bit 3
        #BAUD_PERIOD; rx = 1; // Bit 4
        #BAUD_PERIOD; rx = 0; // Bit 5
        #BAUD_PERIOD; rx = 1; // Bit 6
        #BAUD_PERIOD; rx = 0; // Bit 7
        #BAUD_PERIOD; rx = 1; // Stop bit
        #10000000 //1ms
        $display("UART RX test finish ...");
        $finish;
    end

endmodule
