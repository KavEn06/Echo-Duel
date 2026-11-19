`timescale 1ns/1ps
// Write a complete 160x120 scene into the course VGA adapter's video RAM.
// One pixel per 50 MHz cycle, plus one snapshot cycle between sweeps.
module frame_writer (
    input wire clk, reset,
    input wire [2:0] state, note_id,
    input wire note_active,
    output reg [7:0] x,
    output reg [6:0] y,
    output wire [8:0] color,
    output reg write
);
    reg [2:0] scene_state, scene_note;
    reg scene_active;
    wire [7:0] red, green, blue;
    // Reuse the scene geometry in 640x480 coordinates; the adapter scales
    // each stored 160x120 pixel to a 4x4 block on the monitor.
    note_display scene (
        .x({x,2'b00}), .y({1'b0,y,2'b00}), .active_video(1'b1),
        .state(scene_state), .note_id(scene_note), .note_active(scene_active),
        .red(red), .green(green), .blue(blue)
    );
    assign color = {red[7:5], green[7:5], blue[7:5]};
    always @(posedge clk) begin
        if (reset) begin
            x <= 0; y <= 0; write <= 0;
            scene_state <= 0; scene_note <= 0; scene_active <= 0;
        end else if (!write) begin
            scene_state <= state;
            scene_note <= note_id;
            scene_active <= note_active;
            x <= 0; y <= 0; write <= 1;
        end else if (x == 8'd159) begin
            x <= 0;
            if (y == 7'd119) begin y <= 0; write <= 0; end
            else y <= y + 1'b1;
        end else x <= x + 1'b1;
    end
endmodule
