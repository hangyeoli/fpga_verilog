`timescale 1ns / 1ps

module tb_coffee_machine;
    reg clk;
    reg reset;
    reg coin;
    reg return_coin_btn;
    reg coffee_btn;
    wire [7:0] seg;
    wire [3:0] an;

    coffee_machine #(
        .CLK_HZ(1000),
        .BREW_SEC(2),
        .DEBOUNCE_MS(1),
        .COFFEE_PRICE(300)
    ) dut (
        .clk(clk),
        .reset(reset),
        .coin(coin),
        .return_coin_btn(return_coin_btn),
        .coffee_btn(coffee_btn),
        .seg(seg),
        .an(an)
    );

    initial clk = 1'b0;
    always #5 clk = ~clk;

    task press_coin;
        begin
            @(posedge clk);
            coin = 1'b1;
            repeat (5) @(posedge clk);
            coin = 1'b0;
            repeat (5) @(posedge clk);
        end
    endtask

    task press_return;
        begin
            @(posedge clk);
            return_coin_btn = 1'b1;
            repeat (5) @(posedge clk);
            return_coin_btn = 1'b0;
            repeat (5) @(posedge clk);
        end
    endtask

    task press_coffee;
        begin
            @(posedge clk);
            coffee_btn = 1'b1;
            repeat (5) @(posedge clk);
            coffee_btn = 1'b0;
            repeat (5) @(posedge clk);
        end
    endtask

    initial begin
        reset = 1'b1;
        coin = 1'b0;
        return_coin_btn = 1'b0;
        coffee_btn = 1'b0;

        repeat (10) @(posedge clk);
        reset = 1'b0;

        press_coin();
        press_coin();
        press_coin();

        press_coffee();

        repeat (2200) @(posedge clk);

        press_return();

        repeat (200) @(posedge clk);
        $finish;
    end
endmodule
