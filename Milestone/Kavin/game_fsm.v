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
    // At each clock edge, advance only when this phase is finished.
    // With no matching condition, the state register keeps its value.
    always @(posedge clk) begin
        if (reset) state <= IDLE;
        else begin
            case (state)
                IDLE:   if (start) state <= RECORD;
                RECORD: if (finish_record && sequence_nonempty) state <= REPLAY;
                REPLAY: if (replay_done) state <= MATCH;
                MATCH:  if (match_done) state <= RESULT;
                RESULT: if (start) state <= RECORD;
                default: state <= IDLE;
            endcase
        end
    end

    assign record_enable = (state == RECORD);
    assign replay_enable = (state == REPLAY);
    assign match_enable  = (state == MATCH);
endmodule
