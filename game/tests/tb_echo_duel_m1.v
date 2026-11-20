`timescale 1ns/1ps
// Whole board: key press -> LEDs, sound and VGA key turns green
// Uses the simulation stand-ins in tests/sim for the course PS/2 and audio.
module tb_echo_duel_m1;
    reg CLOCK_50 = 0;
    reg [0:0] KEY = 1'b0;          // Held down = reset.
    wire PS2_CLK, PS2_DAT, AUD_BCLK, AUD_ADCLRCK, AUD_DACLRCK, FPGA_I2C_SDAT;
    wire AUD_XCK, AUD_DACDAT, FPGA_I2C_SCLK;
    wire [9:0] LEDR;
    wire [7:0] VGA_R, VGA_G, VGA_B;
    wire VGA_CLK, VGA_HS, VGA_VS, VGA_BLANK_N, VGA_SYNC_N;

    echo_duel_m1 dut (
        .CLOCK_50(CLOCK_50), .KEY(KEY),
        .PS2_CLK(PS2_CLK), .PS2_DAT(PS2_DAT),
        .AUD_ADCDAT(1'b0), .AUD_BCLK(AUD_BCLK), .AUD_ADCLRCK(AUD_ADCLRCK),
        .AUD_DACLRCK(AUD_DACLRCK), .AUD_XCK(AUD_XCK), .AUD_DACDAT(AUD_DACDAT),
        .FPGA_I2C_SCLK(FPGA_I2C_SCLK), .FPGA_I2C_SDAT(FPGA_I2C_SDAT),
        .LEDR(LEDR),
        .VGA_R(VGA_R), .VGA_G(VGA_G), .VGA_B(VGA_B), .VGA_CLK(VGA_CLK),
        .VGA_HS(VGA_HS), .VGA_VS(VGA_VS), .VGA_BLANK_N(VGA_BLANK_N), .VGA_SYNC_N(VGA_SYNC_N)
    );
    always #10 CLOCK_50 = ~CLOCK_50;   // 50 MHz

    localparam GREEN = 9'b001_110_011, WHITE = 9'b111_111_111;
    // A pixel inside key k of player p on Kavin's display: x = 8 + 80p + 16k + 5, y = 82
    function integer key_pixel; input integer p, k; key_pixel = 82*160 + 13 + 80*p + 16*k; endfunction

    integer errors = 0;
    task check; input ok; input [8*44-1:0] msg; begin
        if (ok) $display("PASS: %0s", msg);
        else begin $display("FAIL: %0s", msg); errors = errors + 1; end
    end endtask

    initial begin
        repeat (4) @(negedge CLOCK_50); KEY = 1'b1;   // Let go of reset.
        repeat (4) @(negedge CLOCK_50);

        // Hold D (note 2, Player 1).
        dut.audio.loud_writes = 0;
        dut.ps2.send(8'h23);
        repeat (40000) @(negedge CLOCK_50);
        check(LEDR[3:0] == 4'b0100 && LEDR[9] == 0, "D held -> LEDR[2], player 1");
        check(dut.audio.loud_writes > 0, "D held -> audio samples are loud");
        check(dut.kavin.VGA.VideoMemory.mem[key_pixel(0,2)] == GREEN, "D held -> player 1 key 2 green");
        check(dut.kavin.VGA.VideoMemory.mem[key_pixel(1,2)] == WHITE, "D held -> player 2 key 2 white");

        // Release D.
        dut.ps2.send(8'hF0); dut.ps2.send(8'h23);
        repeat (40000) @(negedge CLOCK_50);
        dut.audio.loud_writes = 0;
        repeat (2000) @(negedge CLOCK_50);
        check(LEDR[3:0] == 0 && dut.audio.loud_writes == 0, "D released -> LEDs off, silent");
        check(dut.kavin.VGA.VideoMemory.mem[key_pixel(0,2)] == WHITE, "D released -> key 2 white again");

        // Hold K (note 2, Player 2).
        dut.ps2.send(8'h42);
        repeat (40000) @(negedge CLOCK_50);
        check(LEDR[3:0] == 4'b0100 && LEDR[9] == 1, "K held -> LEDR[2], player 2");
        check(dut.kavin.VGA.VideoMemory.mem[key_pixel(1,2)] == GREEN, "K held -> player 2 key 2 green");
        check(dut.kavin.VGA.VideoMemory.mem[key_pixel(0,2)] == WHITE, "K held -> player 1 key 2 white");

        if (errors == 0) $display("=== ALL echo_duel_m1 TESTS PASSED ===");
        else             $display("=== %0d echo_duel_m1 TEST(S) FAILED ===", errors);
        $stop;
    end
endmodule
