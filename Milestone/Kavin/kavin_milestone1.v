`timescale 1ns/1ps
// Integration top for Kavin's milestone-1 logic, not a complete board top.
// Connect these synchronous inputs to Saajan's modules in the board wrapper.
module kavin_milestone1 (
    input wire CLOCK_50,
    input wire reset,
    input wire start,
    input wire finish_record,
    input wire sequence_nonempty,
    input wire replay_done,
    input wire match_done,
    input wire [2:0] note_id,
    input wire note_active,
    output wire [2:0] game_state,
    output wire record_enable,
    output wire replay_enable,
    output wire match_enable,
    output wire [7:0] VGA_R,
    output wire [7:0] VGA_G,
    output wire [7:0] VGA_B,
    output wire VGA_CLK,
    output wire VGA_HS,
    output wire VGA_VS,
    output wire VGA_BLANK_N,
    output wire VGA_SYNC_N
);
    wire [9:0] x, y;
    game_fsm controller (
        .clk(CLOCK_50), .reset(reset), .start(start),
        .finish_record(finish_record), .sequence_nonempty(sequence_nonempty),
        .replay_done(replay_done), .match_done(match_done), .state(game_state),
        .record_enable(record_enable), .replay_enable(replay_enable),
        .match_enable(match_enable)
    );
    vga_timing timing (
        .clk(CLOCK_50), .reset(reset), .pixel_clk(VGA_CLK), .x(x), .y(y),
        .active_video(VGA_BLANK_N), .hsync_n(VGA_HS), .vsync_n(VGA_VS)
    );
    note_display display (
        .x(x), .y(y), .active_video(VGA_BLANK_N), .state(game_state),
        .note_id(note_id), .note_active(note_active),
        .red(VGA_R), .green(VGA_G), .blue(VGA_B)
    );
    assign VGA_SYNC_N = 1'b0;
endmodule
