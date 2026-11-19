`timescale 1ns/1ps
// Draw the screen into the course VGA adapter, one pixel per clock.
// Coordinates are directly in the adapter's 160x120 resolution.
module frame_writer (
    input wire clk, reset,
    input wire [2:0] state, note_id,
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
    reg [2:0] saved_state, saved_note;
    reg saved_active;
    integer key;

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
        // Eight white keys, 14 pixels wide with a 2-pixel gap.
        for (key = 0; key < 8; key = key + 1) begin
            if (x >= 16 + 16*key && x < 30 + 16*key && y >= 70 && y < 100) begin
                color = WHITE;
                if (saved_active && saved_note == key) color = GREEN;
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
            saved_active <= 0;
        end else if (!write) begin
            // Save inputs once so the scene stays consistent for this sweep.
            saved_state <= state;
            saved_note <= note_id;
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
