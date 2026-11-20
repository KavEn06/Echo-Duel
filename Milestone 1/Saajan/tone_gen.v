`timescale 1ns/1ps

// Note -> square wave sound
module tone_gen #(
    parameter CLK_HZ = 50_000_000 // clock speed
)(
    input wire clk, // 50 MHz clock
    input wire reset, // 1 = reset
    input wire [1:0] note_id, // which note 0-3
    input wire note_on, // 1 = play, 0 = silent
    output reg [31:0] sample // sound value sent to the speaker
);
    // How many clock ticks before flipping
    // half = clock speed / (2 x note frequency)-> half is period of square wave/2
    reg [31:0] half;
    always @(*) begin
        if (note_id == 0) half = CLK_HZ / (2 * 262); // C is 262 Hz
        else if (note_id == 1) half = CLK_HZ / (2 * 294); // D is 294 Hz
        else if (note_id == 2) half = CLK_HZ / (2 * 330); // E is 330 Hz
        else half = CLK_HZ / (2 * 349); // F is 349 Hz
    end

    reg [31:0] count; // counts clock ticks
    reg wave; // 1 = high, 0 = low

    // Count ticks flip wave when the count reaches "half"
    always @(posedge clk) begin
        if (reset || note_on == 0) begin
            count <= 0; // silent: stop counting
            wave  <= 0;
        end
        else if (count >= half - 1) begin //if count is past half of period flip wave
            count <= 0; // start counting again
            wave  <= ~wave; // flip between high and low
        end
        else begin //continue counting until half
            count <= count + 1;
        end
    end

    // Wave -> sound value: high -> +10,000,000, low -> -10,000,000
    always @(*) begin
        if (note_on == 0)  sample = 0; // no key held: silent
        else if (wave)     sample = 10_000_000; // high part if wave is high
        else               sample = -10_000_000; // low part if wave is low
    end
endmodule
