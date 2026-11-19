`timescale 1ns/1ps
// VGA-only demo: SW[1:0] = note, SW[2] = player, SW[3] = highlight.
// KEY[0] resets. Keyboard/audio are deliberately not emulated here.
module kavin_board_demo (
    input wire CLOCK_50,
    input wire [3:0] SW,
    input wire [0:0] KEY,
    output wire [7:0] VGA_R, VGA_G, VGA_B,
    output wire VGA_CLK, VGA_HS, VGA_VS, VGA_BLANK_N, VGA_SYNC_N
);
    reg [1:0] reset_pipe;
    reg [3:0] sw_meta, sw_sync;
    // Asynchronous assertion, synchronous release of the pushbutton reset.
    always @(posedge CLOCK_50 or negedge KEY[0]) begin
        if (!KEY[0]) reset_pipe <= 2'b11;
        else reset_pipe <= {reset_pipe[0],1'b0};
    end
    always @(posedge CLOCK_50) begin
        if (reset_pipe[1]) begin sw_meta <= 0; sw_sync <= 0; end
        else begin sw_meta <= SW; sw_sync <= sw_meta; end
    end
    kavin_milestone1 core (
        .CLOCK_50(CLOCK_50), .reset(reset_pipe[1]),
        .start(1'b0), .finish_record(1'b0), .sequence_nonempty(1'b0),
        .replay_done(1'b0), .match_done(1'b0),
        .note_id(sw_sync[1:0]), .active_player(sw_sync[2]), .note_active(sw_sync[3]),
        .game_state(), .record_enable(), .replay_enable(), .match_enable(),
        .VGA_R(VGA_R), .VGA_G(VGA_G), .VGA_B(VGA_B),
        .VGA_CLK(VGA_CLK), .VGA_HS(VGA_HS), .VGA_VS(VGA_VS),
        .VGA_BLANK_N(VGA_BLANK_N), .VGA_SYNC_N(VGA_SYNC_N)
    );
endmodule
