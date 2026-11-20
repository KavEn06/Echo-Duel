`timescale 1ns/1ps
// Fake keyboard on PS2 wires -> real PS2_Controller -> note_decoder -> tone_gen
// Each byte = start(0), 8 data bits (low bit first), parity, stop(1)
module tb_ps2_path;
    reg clk = 0, reset = 1;
    always #10 clk = ~clk;                 // 50 MHz board clock

    // PS/2 wires: pulled high, pulled low to send
    reg kb_clk_low = 0, kb_dat_low = 0;    // 1 = the fake keyboard pulls the line low
    tri1 PS2_CLK, PS2_DAT;                 // tri1 = pulled high when nobody drives it
    assign PS2_CLK = kb_clk_low ? 1'b0 : 1'bz;
    assign PS2_DAT = kb_dat_low ? 1'b0 : 1'bz;

    wire [7:0] ps2_byte;
    wire ps2_byte_en;
    PS2_Controller ps2 (
        .CLOCK_50(clk), .reset(reset),
        .the_command(8'h00), .send_command(1'b0),
        .PS2_CLK(PS2_CLK), .PS2_DAT(PS2_DAT),
        .command_was_sent(), .error_communication_timed_out(),
        .received_data(ps2_byte), .received_data_en(ps2_byte_en)
    );

    wire [1:0] note_id;
    wire player, note_on;
    note_decoder decoder (
        .clk(clk), .reset(reset), .ps2_byte(ps2_byte), .ps2_byte_en(ps2_byte_en),
        .note_id(note_id), .player(player), .note_on(note_on)
    );
    wire [31:0] audio_left;
    tone_gen tone (
        .clk(clk), .reset(reset), .note_id(note_id), .note_on(note_on), .sample(audio_left)
    );

    integer errors = 0;

    // Send one bit: set data, then pulse clock low
    // 60 us per bit (real keyboard speed)
    task send_bit; input b; begin
        kb_dat_low = ~b;
        #15000;
        kb_clk_low = 1;   #30000;
        kb_clk_low = 0;   #15000;
    end endtask

    // Send one byte
    integer i;
    task send_byte; input [7:0] b; begin
        send_bit(1'b0);                       // start bit
        for (i = 0; i < 8; i = i + 1) send_bit(b[i]);   // data, lowest bit first
        send_bit(~^b);                        // odd parity
        send_bit(1'b1);                       // stop bit
        kb_dat_low = 0;
        #100000;                              // gap between bytes
    end endtask

    task check; input ok; input [8*44-1:0] msg; begin
        if (ok) $display("PASS: %0s", msg);
        else begin $display("FAIL: %0s (byte=%h)", msg, ps2_byte); errors = errors + 1; end
    end endtask

    initial begin
        #200 reset = 0;
        #100000;

        send_byte(8'h1C);                     // press A
        check(ps2_byte == 8'h1C, "controller received A (1C)");
        check(note_id == 0 && player == 0 && note_on, "A -> note 0, P1, tone on");
        #2000000;
        check(audio_left != 0, "sound is playing while A is held");

        send_byte(8'h1C);                     // auto-repeat while held
        check(note_on && note_id == 0, "holding A (repeats) -> still on");

        send_byte(8'hF0); send_byte(8'h1C);   // release A
        check(!note_on && audio_left == 0, "release A -> silent");

        send_byte(8'h4B);                     // press L
        check(note_on && note_id == 3 && player == 1, "L -> note 3, P2");
        send_byte(8'hF0); send_byte(8'h4B);


        if (errors == 0) $display("=== ALL ps2_path TESTS PASSED ===");
        else             $display("=== %0d ps2_path TEST(S) FAILED ===", errors);
        $stop;
    end
endmodule
