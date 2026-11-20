`timescale 1ns/1ps
// Standalone audio logic test: the board's real 50 MHz clock, no keyboard or VGA.
module tb_audio;
    reg clk=0, reset=1, note_on=0;
    reg [1:0] note_id=0;
    wire [31:0] sample;
    wire high = (sample == 32'd10000000);
    integer errors=0, ticks;
    tone_gen dut(.clk(clk),.reset(reset),.note_id(note_id),.note_on(note_on),.sample(sample));
    always #10 clk=~clk;

    task check;
        input ok;
        input [8*80-1:0] message;
        begin
            if (ok === 1'b1) $display("PASS: %0s",message);
            else begin errors=errors+1; $display("FAIL: %0s",message); end
        end
    endtask

    task play_note;
        input [1:0] note;
        input integer expected_ticks;
        begin
            @(negedge clk); note_id=note; note_on=1;
            @(posedge high); ticks=0;
            @(negedge clk);
            while(high) begin ticks=ticks+1; @(negedge clk); end
            check(ticks==expected_ticks,"square-wave half-period matches selected note");
            $display("NOTE %0d: half-period=%0d clocks, frequency=%0.3f Hz",note,ticks,50000000.0/(2.0*ticks));
            check(sample === -32'sd10000000,"negative half has the correct amplitude");
            // Keep the note on for another full period for a readable waveform.
            repeat(2*expected_ticks) @(negedge clk);
            note_on=0; #1;
            check(sample === 32'd0,"releasing the note produces silence");
            repeat(25000) @(negedge clk);
        end
    endtask

    initial begin
        repeat(4) @(negedge clk); reset=0;
        repeat(25000) @(negedge clk);
        check(sample === 32'd0,"idle is silent");
        // Independent, hand-calculated integer divider counts at 50 MHz.
        play_note(0,95419); // C, approximately 262 Hz
        play_note(1,85034); // D, approximately 294 Hz
        play_note(2,75757); // E, approximately 330 Hz
        play_note(3,71633); // F, approximately 349 Hz
        reset=1; repeat(4) @(negedge clk);
        check(sample === 32'd0,"reset with no held note stays silent");
        if(errors==0) $display("=== ALL AUDIO TESTS PASSED ===");
        else $display("=== %0d AUDIO TESTS FAILED ===",errors);
        $stop;
    end
    initial begin #40000000; errors=errors+1; $display("FAIL: simulation timeout"); $stop; end
endmodule
