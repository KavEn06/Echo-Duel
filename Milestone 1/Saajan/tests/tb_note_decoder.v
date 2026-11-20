`timescale 1ns/1ps
// Test note_decoder: send bytes, check outputs
module tb_note_decoder;
    reg clk = 0, reset = 1;
    reg [7:0] ps2_byte = 0;
    reg ps2_byte_en = 0;
    wire [1:0] note_id;
    wire player, note_on;

    note_decoder dut (
        .clk(clk), .reset(reset), .ps2_byte(ps2_byte), .ps2_byte_en(ps2_byte_en),
        .note_id(note_id), .player(player), .note_on(note_on)
    );
    always #10 clk = ~clk;   // 50 MHz clock

    integer errors = 0;

    // Send one byte (like PS2_Controller)
    task send; input [7:0] b; begin
        @(negedge clk) begin ps2_byte = b; ps2_byte_en = 1; end
        @(negedge clk) ps2_byte_en = 0;
        repeat (4) @(negedge clk);
    end endtask
    task press;  input [7:0] k; send(k);                      endtask
    task let_go; input [7:0] k; begin send(8'hF0); send(k); end endtask

    task check; input ok; input [8*40-1:0] msg; begin
        if (ok) $display("PASS: %0s", msg);
        else begin $display("FAIL: %0s", msg); errors = errors + 1; end
    end endtask

    initial begin
        repeat (3) @(negedge clk); reset = 0;

        // 1. Press, hold, release A
        press(8'h1C);
        check(note_id == 0 && player == 0 && note_on, "A -> note 0, player 1, on");
        press(8'h1C); press(8'h1C);
        check(note_id == 0 && note_on, "holding A (repeats) -> still on");
        let_go(8'h1C);
        check(!note_on, "release A -> off");

        // 2. Every key
        press(8'h1B); check(note_id == 1 && player == 0 && note_on, "S -> note 1, player 1"); let_go(8'h1B);
        press(8'h23); check(note_id == 2 && player == 0 && note_on, "D -> note 2, player 1"); let_go(8'h23);
        press(8'h2B); check(note_id == 3 && player == 0 && note_on, "F -> note 3, player 1"); let_go(8'h2B);
        press(8'h33); check(note_id == 0 && player == 1 && note_on, "H -> note 0, player 2"); let_go(8'h33);
        press(8'h3B); check(note_id == 1 && player == 1 && note_on, "J -> note 1, player 2"); let_go(8'h3B);
        press(8'h42); check(note_id == 2 && player == 1 && note_on, "K -> note 2, player 2"); let_go(8'h42);
        press(8'h4B); check(note_id == 3 && player == 1 && note_on, "L -> note 3, player 2"); let_go(8'h4B);
        check(!note_on, "all released -> off");

        // 3. Other keys do nothing
        press(8'h34); let_go(8'h34);                                     // G
        press(8'h29); let_go(8'h29);                                     // Space
        press(8'h5A); let_go(8'h5A);                                     // Enter
        send(8'hE0); send(8'h75); send(8'hE0); send(8'hF0); send(8'h75);  // up arrow
        check(!note_on && note_id == 3 && player == 1, "G, Space, Enter, arrow ignored");

        // 4. Hold A, press D, let go of A -> D keeps playing
        press(8'h1C); press(8'h23); let_go(8'h1C);
        check(note_on && note_id == 2, "A+D, let go of A -> D still on");
        let_go(8'h23);
        check(!note_on, "let go of D -> off");

        // 5. Hold A, tap Space, let go of A -> off
        press(8'h1C); press(8'h29); let_go(8'h29);
        check(note_on && note_id == 0, "A held, Space tapped -> A still on");
        let_go(8'h1C);
        check(!note_on, "let go of A -> off");

        // 6. Reset
        press(8'h2B);
        @(negedge clk) reset = 1; @(negedge clk) reset = 0;
        check(!note_on, "reset -> off");

        if (errors == 0) $display("=== ALL note_decoder TESTS PASSED ===");
        else             $display("=== %0d note_decoder TEST(S) FAILED ===", errors);
        $stop;
    end
endmodule
