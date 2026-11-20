`timescale 1ns/1ps
// Test tone_gen: each note flips at the right speed
// Uses a 1 MHz clock so the test is short
module tb_tone_gen;
    reg clk = 0, reset = 1, note_on = 0;
    reg [1:0] note_id = 0;
    wire [31:0] sample;

    tone_gen #(.CLK_HZ(1_000_000)) dut (
        .clk(clk), .reset(reset), .note_id(note_id), .note_on(note_on), .sample(sample)
    );
    always #500 clk = ~clk;   // 1 MHz clock

    wire high = (sample == 32'd10_000_000);    // 1 = high part
    integer expected [0:3];
    integer n, ticks, errors = 0;

    initial begin
        expected[0] = 1_000_000 / (2*262);   // 1908 ticks
        expected[1] = 1_000_000 / (2*294);   // 1700
        expected[2] = 1_000_000 / (2*330);   // 1515
        expected[3] = 1_000_000 / (2*349);   // 1432

        repeat (3) @(posedge clk); reset = 0;

        // Off -> silent.
        repeat (3000) @(negedge clk);
        if (sample !== 0) begin $display("FAIL: not silent when off"); errors = errors + 1; end
        else $display("PASS: silent when note_on = 0");

        // Measure the high part of each note
        for (n = 0; n < 4; n = n + 1) begin
            note_id = n; note_on = 1;
            @(posedge high); ticks = 0;
            @(negedge clk);
            while (high) begin ticks = ticks + 1; @(negedge clk); end
            if (ticks == expected[n])
                $display("PASS: note %0d high for %0d ticks (correct)", n, ticks);
            else begin
                $display("FAIL: note %0d high for %0d ticks, expected %0d", n, ticks, expected[n]);
                errors = errors + 1;
            end
            if (sample !== -32'sd10_000_000) begin $display("FAIL: low part wrong"); errors = errors + 1; end
            note_on = 0; repeat (5) @(negedge clk);
            if (sample !== 0) begin $display("FAIL: not silent after off"); errors = errors + 1; end
        end

        if (errors == 0) $display("=== ALL tone_gen TESTS PASSED ===");
        else             $display("=== %0d tone_gen TEST(S) FAILED ===", errors);
        $stop;
    end
endmodule
