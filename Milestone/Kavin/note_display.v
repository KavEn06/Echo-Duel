`timescale 1ns/1ps
// Eight simple keys represent C D E F G A B C (IDs 0 through 7).
// This is a combinational pixel renderer, not a framebuffer.
module note_display (
    input wire [9:0] x,
    input wire [9:0] y,
    input wire active_video,
    input wire [2:0] state,
    input wire [2:0] note_id,
    input wire note_active,
    output reg [7:0] red,
    output reg [7:0] green,
    output reg [7:0] blue
);
    reg [23:0] colour;
    integer i;
    always @(*) begin
        colour = 24'h101820;
        // Phase band: idle blue, record red, replay yellow,
        // match green, result purple. No text/font ROM needed yet.
        if (y >= 10'd24 && y < 10'd64 && x >= 10'd16 && x < 10'd624) begin
            case (state)
                3'd0: colour = 24'h4070c0;
                3'd1: colour = 24'hd05040;
                3'd2: colour = 24'he0b040;
                3'd3: colour = 24'h30d070;
                3'd4: colour = 24'h9060d0;
                default: colour = 24'h404040;
            endcase
        end
        for (i=0; i<8; i=i+1) begin
            if (x >= (64+64*i) && x < (120+64*i) &&
                y >= 10'd280 && y < 10'd400) begin
                if (note_active && note_id == i) colour = 24'h30d070;
                else colour = 24'he8e8e8;
            end
        end
        if (!active_video) colour = 24'h000000;
        {red, green, blue} = colour;
    end
endmodule
