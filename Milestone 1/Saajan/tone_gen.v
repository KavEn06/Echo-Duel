`timescale 1ns/1ps

// Note -> square wave sound (high, low, high, low ...)
// Faster flipping = higher note
module tone_gen #(
    parameter CLK_HZ = 50_000_000     // clock speed (testbench uses a smaller one)
)(
    input wire clk,                   // 50 MHz clock
    input wire reset,                 // 1 = reset
    input wire [1:0] note_id,         // which note 0-3
    input wire note_on,               // 1 = play, 0 = silent
    output reg [31:0] sample          // sound value sent to the speaker
);
    // How many clock ticks to wait before flipping, ex: C -> 95419 ticks
    // half = clock speed / (2 x note frequency)
    reg [31:0] half;
    always @(*) begin
        if (note_id == 0)      half = CLK_HZ / (2 * 262);   // C (262 Hz)
        else if (note_id == 1) half = CLK_HZ / (2 * 294);   // D (294 Hz)
        else if (note_id == 2) half = CLK_HZ / (2 * 330);   // E (330 Hz)
        else                   half = CLK_HZ / (2 * 349);   // F (349 Hz)
    end

    reg [31:0] count;   // counts clock ticks
    reg wave;           // 1 = high part of the wave, 0 = low part

    // Count ticks, flip the wave when the count reaches "half"
    always @(posedge clk) begin
        if (reset || note_on == 0) begin
            count <= 0;               // silent: stop counting
            wave  <= 0;
        end
        else if (count >= half - 1) begin
            count <= 0;               // start counting again
            wave  <= ~wave;           // flip high <-> low
        end
        else begin
            count <= count + 1;
        end
    end

    // Wave -> sound value, ex: high -> +10,000,000, low -> -10,000,000
    always @(*) begin
        if (note_on == 0)  sample = 0;               // no key held: silent
        else if (wave)     sample = 10_000_000;      // high part
        else               sample = -10_000_000;     // low part
    end
endmodule
