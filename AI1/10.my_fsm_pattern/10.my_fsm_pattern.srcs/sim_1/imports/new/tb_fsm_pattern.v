`timescale 1ns / 1ps

module tb_fsm_pattern;

    reg clk;
    reg reset;
    reg din_bit;
    wire detect_out;

    integer i;
    reg [12:0] stimulus;
    reg [12:0] expected;

    fsm_pattern dut (
        .clk(clk),
        .reset(reset),
        .din_bit(din_bit),
        .detect_out(detect_out)
    );

    // 100 MHz clock (10 ns period)
    always #5 clk = ~clk;

    initial begin
        clk = 1'b0;
        reset = 1'b1;
        din_bit = 1'b0;

        // Problem 11-19 example sequence
        stimulus = 13'b0101100100110;
        expected = 13'b0000010000101;

        #12;
        reset = 1'b0;

        $display("time\tidx\tdin\tdetect\texpected\tstate");
        for (i = 12; i >= 0; i = i - 1) begin
            @(negedge clk);
            din_bit = stimulus[i];

            @(posedge clk);
            #1;
            $display("%0t\t%0d\t%b\t%b\t%b\t\t%0d",
                     $time, 12 - i, din_bit, detect_out, expected[i], dut.current_state);

            if (detect_out !== expected[i]) begin
                $display("[FAIL] index=%0d din=%b detect_out=%b expected=%b",
                         12 - i, din_bit, detect_out, expected[i]);
                $finish;
            end
        end

        $display("[PASS] 0110 pattern detection matched expected output sequence.");
        #20;
        $finish;
    end

endmodule
