`timescale 1ns/1ps
// Combined board test using real course PS/2, VGA and audio RTL.
// Only external keyboard and codec clock/ACK signals are supplied here.
module tb_full_system;
    reg CLOCK_50 = 0;
    reg [0:0] KEY = 1'b0;          // Held down = reset.
    tri1 PS2_CLK, PS2_DAT, FPGA_I2C_SDAT;
    wire AUD_BCLK, AUD_ADCLRCK, AUD_DACLRCK;
    reg kb_clk_low = 0, kb_dat_low = 0;
    assign PS2_CLK = kb_clk_low ? 1'b0 : 1'bz;
    assign PS2_DAT = kb_dat_low ? 1'b0 : 1'bz;

    // The physical audio codec supplies 3.072 MHz bit and 48 kHz frame clocks.
    reg codec_bclk = 0;
    reg [5:0] codec_bit = 0;
    always #162.7604167 codec_bclk = ~codec_bclk;
    always @(negedge codec_bclk) codec_bit <= codec_bit + 1'b1;
    assign AUD_BCLK = codec_bclk;
    assign AUD_ADCLRCK = codec_bit[5];
    assign AUD_DACLRCK = codec_bit[5];
    // Acknowledge setup writes from the real I2C controller.
    assign FPGA_I2C_SDAT = 1'b0;
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
    integer errors = 0;
    integer serial_ones = 0, previous_ones;
    integer horizontal_edges = 0;
    reg [8:0] key_color [0:7];
    integer n;
    reg [7:0] scan_code [0:7];

    // Watch the painter's actual writes into the course VGA framebuffer.
    always @(posedge CLOCK_50)
        if (dut.kavin.write && dut.kavin.y == 82)
            for (n = 0; n < 8; n = n + 1)
                if (dut.kavin.x == 13 + (n/4)*80 + (n%4)*16)
                    key_color[n] <= dut.kavin.color;
    always @(posedge AUD_BCLK)
        if (KEY[0] && AUD_DACDAT === 1'b1) serial_ones = serial_ones + 1;
    always @(negedge VGA_HS) horizontal_edges = horizontal_edges + 1;

    task check;
        input ok;
        input [8*90-1:0] message;
        begin
            if (ok === 1'b1) $display("PASS: %0s", message);
            else begin
                $display("FAIL: %0s", message);
                errors = errors + 1;
            end
        end
    endtask

    // Actual PS/2 start, data, odd parity and stop bits, at keyboard speed.
    task send_bit;
        input b;
        begin
            kb_dat_low = ~b; #15000;
            kb_clk_low = 1; #30000;
            kb_clk_low = 0; #15000;
        end
    endtask
    task send_byte;
        input [7:0] b;
        integer bit_number;
        begin
            send_bit(0);
            for (bit_number = 0; bit_number < 8; bit_number = bit_number + 1)
                send_bit(b[bit_number]);
            send_bit(~^b); send_bit(1);
            kb_dat_low = 0; #100000;
        end
    endtask

    integer key_number;
    initial begin
        scan_code[0]=8'h1c; scan_code[1]=8'h1b; // A, S
        scan_code[2]=8'h23; scan_code[3]=8'h2b; // D, F
        scan_code[4]=8'h33; scan_code[5]=8'h3b; // H, J
        scan_code[6]=8'h42; scan_code[7]=8'h4b; // K, L
        #1000; KEY = 1'b1;
        #100000;
        for (key_number = 0; key_number < 8; key_number = key_number + 1) begin
            $display("--- Key %0d, PS/2 code %h ---", key_number, scan_code[key_number]);
            send_byte(scan_code[key_number]);
            previous_ones = serial_ones;
            #5000000; // Several framebuffer updates and at least one tone period.
            check(dut.note_on && dut.note_id == key_number%4 && dut.player == key_number/4,
                  "real PS/2 receiver -> correct note, player and note_on");
            check(LEDR[3:0] == (4'b0001 << (key_number%4)) && LEDR[9] == key_number/4,
                  "LEDs agree with selected note and player");
            check(key_color[key_number] == GREEN, "VGA painter writes held key green");
            check(key_color[(key_number+4)%8] == WHITE, "other player's matching key stays white");
            check(dut.sample == 32'd10000000 || dut.sample == -32'sd10000000,
                  "tone generator produces signed audio samples");
            check(serial_ones > previous_ones, "real audio FIFO and serializer drive DAC bits");
            send_byte(8'hf0); send_byte(scan_code[key_number]);
            #2000000; // Allow the audio FIFO to drain its earlier samples.
            check(!dut.note_on && dut.sample == 0 && LEDR[3:0] == 0,
                  "release -> tone off, zero sample and LEDs off");
            check(key_color[key_number] == WHITE, "release -> VGA key returns white");
            previous_ones = serial_ones;
            #100000;
            check(serial_ones == previous_ones, "release -> DAC stream returns to silence");
        end
        check(horizontal_edges > 10, "real VGA controller generates horizontal sync");
        if (errors == 0) $display("=== ALL FULL SYSTEM TESTS PASSED ===");
        else $display("=== %0d FULL SYSTEM CHECKS FAILED ===", errors);
        $stop;
    end
    initial begin #100000000; $display("FAIL: simulation timeout"); errors=errors+1; $stop; end
endmodule
