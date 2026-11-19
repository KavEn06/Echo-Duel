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
    wire [7:0] x;
    wire [6:0] y;
    wire [8:0] color;
    wire write;
    game_fsm controller (
        .clk(CLOCK_50), .reset(reset), .start(start),
        .finish_record(finish_record), .sequence_nonempty(sequence_nonempty),
        .replay_done(replay_done), .match_done(match_done), .state(game_state),
        .record_enable(record_enable), .replay_enable(replay_enable),
        .match_enable(match_enable)
    );
    frame_writer painter (
        .clk(CLOCK_50), .reset(reset), .state(game_state),
        .note_id(note_id), .note_active(note_active),
        .x(x), .y(y), .color(color), .write(write)
    );
    // Official ECE241 VGA adapter, downloaded from Quercus, unmodified.
    vga_adapter #(
        .RESOLUTION("160x120"), .COLOR_DEPTH(9),
        .BACKGROUND_IMAGE("MIF/black_160_9.mif")
    ) VGA (
        .resetn(~reset), .clock(CLOCK_50), .color(color),
        .x(x), .y(y), .write(write),
        .VGA_R(VGA_R), .VGA_G(VGA_G), .VGA_B(VGA_B),
        .VGA_CLK(VGA_CLK), .VGA_HS(VGA_HS), .VGA_VS(VGA_VS),
        .VGA_BLANK_N(VGA_BLANK_N), .VGA_SYNC_N(VGA_SYNC_N)
    );
endmodule
