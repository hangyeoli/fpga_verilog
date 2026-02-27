`timescale 1ns / 1ps

module play_melody(
    input clk,
    input reset,
    input btnU,
    input btnL,
    input btnC,
    input btnR,
    input btnD,
    output buzzer
    );

    //input clk: 100MHz
    //output frequency
    //(100MHz / division / 2)
    //DO 261.63Hz, RE 293.66Hz, MI 329.63Hz, SOL 392.00Hz, LA 440.00Hz
    localparam DO = 22'd191_112;
    localparam RE = 22'd170_262;
    localparam MI = 22'd151_686;
    localparam SOL = 22'd127_551;
    localparam LA = 22'd113_636;
    
    reg[21:0] r_clk_cnt[4:0];
    reg [4:0] r_buzzer_frequency;
    // index mapping: [0]=btnU, [1]=btnL, [2]=btnC, [3]=btnR, [4]=btnD
    wire [4:0] btn_ary = {btnD, btnR, btnC, btnL, btnU};

    integer i;  //integer : signed, 32-bit , reg [31:0] : unsigned, 32-bit
    always @(posedge clk, posedge reset) begin
    if (reset) begin
        for (i=0; i < 5; i=i+1) begin
            r_clk_cnt[i] <= 22'd0;
            r_buzzer_frequency[i] <= 1'b0;
        end
    end else begin   // update every 10ns
        // DO(btnU) 261.63Hz
        if (!btn_ary[0]) begin
            r_clk_cnt[0] <= 0;
            r_buzzer_frequency[0] <= 1'b0;
        end else if (r_clk_cnt[0] >= DO-1) begin
            r_clk_cnt[0] <= 0;
            r_buzzer_frequency[0] <= ~r_buzzer_frequency[0];
        end else r_clk_cnt[0] <= r_clk_cnt[0] + 1;
        // RE(btnL) 293.66Hz
        if (!btn_ary[1]) begin
            r_clk_cnt[1] <= 0;
            r_buzzer_frequency[1] <= 1'b0;
        end else if (r_clk_cnt[1] >= RE-1) begin
            r_clk_cnt[1] <= 0;
            r_buzzer_frequency[1] <= ~r_buzzer_frequency[1];
        end else r_clk_cnt[1] <= r_clk_cnt[1] + 1;
        // MI(btnC) 329.63Hz
        if (!btn_ary[2]) begin
            r_clk_cnt[2] <= 0;
            r_buzzer_frequency[2] <= 1'b0;
        end else if (r_clk_cnt[2] >= MI-1) begin
            r_clk_cnt[2] <= 0;
            r_buzzer_frequency[2] <= ~r_buzzer_frequency[2];
        end else r_clk_cnt[2] <= r_clk_cnt[2] + 1;
        // SOL(btnR) 392.00Hz
        if (!btn_ary[3]) begin
            r_clk_cnt[3] <= 0;
            r_buzzer_frequency[3] <= 1'b0;
        end else if (r_clk_cnt[3] >= SOL-1) begin
            r_clk_cnt[3] <= 0;
            r_buzzer_frequency[3] <= ~r_buzzer_frequency[3];
        end else r_clk_cnt[3] <= r_clk_cnt[3] + 1;
        // LA(btnD) 440.00Hz
        if (!btn_ary[4]) begin
            r_clk_cnt[4] <= 0;
            r_buzzer_frequency[4] <= 1'b0;
        end else if (r_clk_cnt[4] >= LA-1) begin
            r_clk_cnt[4] <= 0;
            r_buzzer_frequency[4] <= ~r_buzzer_frequency[4];
        end else r_clk_cnt[4] <= r_clk_cnt[4] + 1;
    end
end

    // OR reduction of all generated tones
    assign buzzer = |r_buzzer_frequency;

endmodule
