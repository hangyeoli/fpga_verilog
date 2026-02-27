`timescale 1ns / 1ps

module reset_sync(
    input  wire clk,
    input  wire rst_async,
    output wire rst_sync
);

    reg rst_ff1;
    reg rst_ff2;

    always @(posedge clk or posedge rst_async) begin
        if (rst_async) begin
            rst_ff1 <= 1'b1;
            rst_ff2 <= 1'b1;
        end else begin
            rst_ff1 <= 1'b0;
            rst_ff2 <= rst_ff1;
        end
    end

    assign rst_sync = rst_ff2;

endmodule
