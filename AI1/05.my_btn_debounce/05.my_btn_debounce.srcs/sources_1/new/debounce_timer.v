`timescale 1ns / 1ps

module debounce_timer #(
    parameter CLK_FREQ = 100_000_000,   // 100MHz
    parameter DEBOUNCE_MS = 10          // 10ms
)(
    input  wire clk,
    input  wire reset,
    input  wire btn_in,
    output reg  btn_clean
);

    localparam COUNT_MAX = (CLK_FREQ/1000) * DEBOUNCE_MS;  // 1,000,000

    reg [$clog2(COUNT_MAX):0] counter = 0;
    reg btn_sync = 0;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            counter   <= 0;
            btn_clean <= 0;
            btn_sync  <= 0;
        end
        else begin
            // 버튼 상태가 바뀌면 카운터 시작
            if (btn_in != btn_sync) begin
                counter <= counter + 1;

                if (counter >= COUNT_MAX) begin
                    btn_sync  <= btn_in;
                    btn_clean <= btn_in;
                    counter   <= 0;
                end
            end
            else begin
                counter <= 0;  // 상태 유지되면 카운터 리셋
            end
        end
    end

endmodule
