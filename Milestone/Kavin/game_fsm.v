`timescale 1ns/1ps
// Initial phase controller. All inputs are synchronous to clk.
// Command and completion inputs are one-clock pulses, qualified by the caller.
module game_fsm (
    input wire clk,
    input wire reset,             // Synchronous, active high.
    input wire start,
    input wire finish_record,
    input wire sequence_nonempty,
    input wire replay_done,
    input wire match_done,
    output reg [2:0] state,
    output wire record_enable,
    output wire replay_enable,
    output wire match_enable
);
    localparam IDLE=3'd0, RECORD=3'd1, REPLAY=3'd2,
               MATCH=3'd3, RESULT=3'd4;
    reg [2:0] next_state;

    always @(*) begin
        next_state = state;
        case (state)
            IDLE:   if (start) next_state = RECORD;
            RECORD: if (finish_record && sequence_nonempty) next_state = REPLAY;
            REPLAY: if (replay_done) next_state = MATCH;
            MATCH:  if (match_done) next_state = RESULT;
            RESULT: if (start) next_state = RECORD;
            default: next_state = IDLE;
        endcase
    end

    always @(posedge clk) begin
        if (reset) state <= IDLE;
        else       state <= next_state;
    end

    assign record_enable = (state == RECORD);
    assign replay_enable = (state == REPLAY);
    assign match_enable  = (state == MATCH);
endmodule
