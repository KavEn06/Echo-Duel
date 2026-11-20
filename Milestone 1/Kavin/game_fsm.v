`timescale 1ns/1ps
// Initial phase controller. All inputs are synchronous to clk.
// Command and completion inputs are one-clock pulses, qualified by the caller.
module game_fsm (
    // Clock/reset and events supplied by the other game modules.
    input wire clk,
    input wire reset,             // Synchronous, active high.
    input wire start,
    input wire finish_record,
    input wire sequence_nonempty,
    input wire replay_done,
    input wire match_done,
    // Current phase and signals that enable each part of the game.
    output reg [2:0] state,
    output wire record_enable,
    output wire replay_enable,
    output wire match_enable
);
    // Readable names for the five three-bit state values.
    localparam IDLE=3'd0, RECORD=3'd1, REPLAY=3'd2,
               MATCH=3'd3, RESULT=3'd4;
    // At each clock edge, advance only when this phase is finished.
    // With no matching condition, the state register keeps its value.
    always @(posedge clk) begin
        if (reset) state <= IDLE;
        else begin
            case (state)
                // Wait for a new round.
                IDLE:   if (start) state <= RECORD;
                // Replay is allowed only after at least one note was stored.
                RECORD: if (finish_record && sequence_nonempty) state <= REPLAY;
                // Hand over to Player 2 after the reference melody ends.
                REPLAY: if (replay_done) state <= MATCH;
                // Show the result after Player 2 finishes.
                MATCH:  if (match_done) state <= RESULT;
                // Another start begins a fresh recording round.
                RESULT: if (start) state <= RECORD;
                // Recover if the state register holds an unused value.
                default: state <= IDLE;
            endcase
        end
    end

    // These outputs are high only during their corresponding phase.
    assign record_enable = (state == RECORD);
    assign replay_enable = (state == REPLAY);
    assign match_enable  = (state == MATCH);
endmodule
