`timescale 1ns/1ps
// Draw the screen into the course VGA adapter, one pixel per clock.
// Coordinates are directly in the adapter's 160x120 resolution.
module frame_writer (
    input wire clk, reset,
    input wire [2:0] state,
    input wire [1:0] note_id,
    input wire active_player, // 0 = Player 1 (ASDF), 1 = Player 2 (HJKL)
    input wire note_active,
    output reg [7:0] x,
    output reg [6:0] y,
    output reg [8:0] color,
    output reg write
);
    // Each group of three bits is one colour channel: RRR_GGG_BBB.
    localparam BACKGROUND = 9'b000_000_001;
    localparam WHITE      = 9'b111_111_111;
    localparam GREEN      = 9'b001_110_011;
    reg [2:0] saved_state;
    reg [1:0] saved_note;
    reg saved_player;
    reg saved_active;
    integer player, key, left;
    reg [14:0] letter;

    // Tiny 3x5 labels. Each group of three bits is one row, top to bottom.
    function [14:0] key_label;
        input integer number;
        begin
            case (number)
                0: key_label = 15'b010_101_111_101_101; // A
                1: key_label = 15'b111_100_111_001_111; // S
                2: key_label = 15'b110_101_101_101_110; // D
                3: key_label = 15'b111_100_110_100_100; // F
                4: key_label = 15'b101_101_111_101_101; // H
                5: key_label = 15'b001_001_001_101_010; // J
                6: key_label = 15'b101_101_110_101_101; // K
                7: key_label = 15'b100_100_100_100_111; // L
                default: key_label = 0;
            endcase
        end
    endfunction

    // 1. Choose the colour of the pixel at (x, y).
    always @(*) begin
        color = BACKGROUND;
        if (x >= 4 && x < 156 && y >= 6 && y < 16) begin
            case (saved_state)
                0: color = 9'b010_011_110; // IDLE: blue
                1: color = 9'b110_010_010; // RECORD: red
                2: color = 9'b111_101_010; // REPLAY: yellow
                3: color = GREEN;         // MATCH: green
                4: color = 9'b100_011_110; // RESULT: purple
                default: color = 9'b010_010_010;
            endcase
        end
        // Two groups of four keys, with a larger gap between players.
        // Both groups play C, D, E, F in left-to-right order.
        left = 0;
        letter = 0;
        for (player = 0; player < 2; player = player + 1) begin
            for (key = 0; key < 4; key = key + 1) begin
                left = 8 + 80*player + 16*key;
                if (x >= left && x < left+14 && y >= 70 && y < 100) begin
                    color = WHITE;
                    if (saved_active && saved_player == player && saved_note == key)
                        color = GREEN;
                end
                // Letter centred below this key, three pixels wide and five high.
                letter = key_label(4*player + key);
                if (x >= left+5 && x < left+8 && y >= 104 && y < 109) begin
                    if (letter[14 - (3*(y-104) + x-(left+5))]) color = WHITE;
                end
            end
        end
    end

    // 2. Walk left to right, then move down to the next row.
    always @(posedge clk) begin
        if (reset) begin
            x <= 0;
            y <= 0;
            write <= 0;
            saved_state <= 0;
            saved_note <= 0;
            saved_player <= 0;
            saved_active <= 0;
        end else if (!write) begin
            // Save inputs once so the scene stays consistent for this sweep.
            saved_state <= state;
            saved_note <= note_id;
            saved_player <= active_player;
            saved_active <= note_active;
            write <= 1;
        end else if (x < 159) begin
            x <= x + 1'b1;
        end else begin
            x <= 0;
            if (y < 119) y <= y + 1'b1;
            else begin
                y <= 0;
                write <= 0; // Screen complete; save fresh inputs next clock.
            end
        end
    end
endmodule
