
`timescale 1ns / 1ps
module fsm_pattern(
input wire clk,
input wire reset,
input wire in,
output reg out
);

// 상태 정의
parameter S0=3'd0, S1=3'd1, S2=3'd2, S3=3'd3,
S4=3'd4, S5=3'd5, S6=3'd6;

reg [2:0] current_state=S0;
reg [2:0] next_state;

//------------------------------------
// 1. Next State Logic (조합 회로)
//    현재의 상태(current_state)와 입력(in) 을 보고 
//    다음(next_state)에 어디로 갈지만 결정 한다. 
//------------------------------------
always @(*) begin
case (current_state)
    S0: next_state = (in) ? S1 : S0;
    S1: next_state = (in) ? S1 : S2;
    S2: next_state = (in) ? S3 : S0;
    S3: next_state = (in) ? S1 : S4;
    S4: next_state = (in) ? S5 : S0;
    S5: next_state = (in) ? S6 : S0;
    S6: next_state = (in) ? S1 : S0;
    default: next_state = S0; // latch 방지를 위해서
endcase

end
//------------------------------------
// 2. state register (순차 회로)
//    현재 상태를 update하는 회로(D F/F).
//    클럭의 상승에지에 맞춰서 상태를 천이
//------------------------------------
always @(posedge clk, posedge reset) begin
    if (reset)
    current_state <= S0;
    else current_state <= next_state;
end

//------------------------------------
// 3. output logic (조합 회로)
//    Melay Machine: 현재상태 + 입력에 따라서 출력이 결정 되는 회로
//    만약 moor Machine이라면 입력 조건 없이 현재의 상태 즉, current_state만으로 출력 결정
//------------------------------------

always @(*) begin
    case (current_state)
        S6: begin
            if (in == 1'b1) out = 1'b1; // 1010111을 만났으므로 LED ON
            else            out = 1'b0;
        end
        default: out = 1'b0;
    endcase
end
endmodule