`timescale 1ns/1ps

// Keyboard byte -> which note is playing, ex: A (1C) -> note 0, player 1
module note_decoder (
    input wire clk,  // 50 MHz clock
    input wire reset, // 1 = reset
    input wire [7:0] ps2_byte, // byte from keyboard, ex: A -> 1C
    input wire ps2_byte_en, // 1 = new byte arrived (one clock)
    output reg [1:0] note_id, // which note: A/H=0, S/J=1, D/K=2, F/L=3
    output reg player, // 0 = player 1 (ASDF), 1 = player 2 (HJKL)
    output reg note_on // 1 = a note key is held down
);
    reg got_f0; // 1 = last byte was F0, so next byte is a key being released
    reg [7:0] held_key; // byte of the note key playing now, ex: 1C if A is held

    always @(posedge clk) begin
        if (reset) begin //active high reset (assigns everything to 0)
            got_f0   <= 0;
            held_key <= 0;
            note_on  <= 0;
            note_id  <= 0;
            player   <= 0;
        end

        else if (ps2_byte_en) begin //if flag for new byte is 1

            // F0 = a key is released, the key comes in the next byte
            if (ps2_byte == 8'hF0)
                got_f0 <= 1;

            // Key released: stop the sound if key playing now
            else if (got_f0) begin
                got_f0 <= 0;
                if (ps2_byte == held_key)
                    note_on <= 0;//note not being held anymore
            end

            // Key pressed: check which key it is
            else begin
                case (ps2_byte) //check which key byte was input from keyboard: each notes number representative and hex 8 bit combination
                    // Player 1
                    8'h1C: begin note_id <= 0; player <= 0; note_on <= 1; held_key <= 8'h1C; end // A ->8'h1C
                    8'h1B: begin note_id <= 1; player <= 0; note_on <= 1; held_key <= 8'h1B; end // S
                    8'h23: begin note_id <= 2; player <= 0; note_on <= 1; held_key <= 8'h23; end // D
                    8'h2B: begin note_id <= 3; player <= 0; note_on <= 1; held_key <= 8'h2B; end // F
                    // Player 2
                    8'h33: begin note_id <= 0; player <= 1; note_on <= 1; held_key <= 8'h33; end // H
                    8'h3B: begin note_id <= 1; player <= 1; note_on <= 1; held_key <= 8'h3B; end // J
                    8'h42: begin note_id <= 2; player <= 1; note_on <= 1; held_key <= 8'h42; end // K
                    8'h4B: begin note_id <= 3; player <= 1; note_on <= 1; held_key <= 8'h4B; end // L
                    default:;// Any other key: do nothing
                endcase
            end
        end
    end
endmodule
