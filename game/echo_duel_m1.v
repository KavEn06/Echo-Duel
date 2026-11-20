`timescale 1ns/1ps //simulation time units for ModelSim)

// Milestone 1: Connect keyboard to speaker and screen: key press -> sound + screen
module echo_duel_m1 (
    input wire CLOCK_50, //50 MHz clock
    input wire [0:0] KEY, // KEY[0] = reset button
    inout wire PS2_CLK, PS2_DAT, // keyboard wires (clock + data)
    input wire AUD_ADCDAT, // audio chip: mic data in (not used)
    inout wire AUD_BCLK, AUD_ADCLRCK, AUD_DACLRCK, // audio chip: timing wires
    output wire AUD_XCK, AUD_DACDAT, // audio chip: its clock + sound data out
    output wire FPGA_I2C_SCLK, // audio chip setup: clock
    inout wire FPGA_I2C_SDAT, // audio chip setup: data
    output wire [9:0] LEDR, // LEDs
    output wire [7:0] VGA_R, VGA_G, VGA_B, // monitor: red, green, blue colour 8 bit colour
    output wire VGA_CLK, VGA_HS, VGA_VS, VGA_BLANK_N, VGA_SYNC_N // monitor: timing wires
);
    wire reset = ~KEY[0]; // reset = 1 when pressed

    // Keyboard bits -> one byte, ex: A->1C (Provided by Course)
    wire [7:0] ps2_byte; // byte from keyboard
    wire ps2_byte_en; // (1->new entry, 0->no new entry)
    PS2_Controller ps2 (
        .CLOCK_50(CLOCK_50), .reset(reset), // clock + reset
        .the_command(8'h00), .send_command(1'b0), // never send to keyboard (so kept at 0)
        .PS2_CLK(PS2_CLK), .PS2_DAT(PS2_DAT), // keyboard wires
        .command_was_sent(), .error_communication_timed_out(), // only used when sending to keyboard not needed
        .received_data(ps2_byte), .received_data_en(ps2_byte_en) //key byte + flag->new byte just arrived
    );

    // Byte -> note (decodes what note the byte from keyboard is) (Saajan)
    wire [1:0] note_id; // which note (0: A=H, 1: S=J, 2: D=K, 3: F=L)
    wire player; // 0 = ASDF, 1 = HJKL
    wire note_on; // 1 while a note key is held (which key = note_id)

    // instantiation of decoder to get: keyboard byte -> note, player, note_on
    note_decoder decoder (
        .clk(CLOCK_50), .reset(reset), // clock + reset
        .ps2_byte(ps2_byte), .ps2_byte_en(ps2_byte_en), // in: byte from keyboard
        .note_id(note_id), .player(player), .note_on(note_on) // out: note info
    );

    // Note -> sound (Saajan)
    wire [31:0] sample; // sound value goes up and down = sound wave
    tone_gen tone (
        .clk(CLOCK_50), .reset(reset), // clock + reset
        .note_id(note_id), .note_on(note_on), // note_id->which note, note_on->play or not
        .sample(sample) // output number -> sound value
    );

    // Sound output value -> speaker (Provided by Course)
    wire audio_out_allowed; //1 = controller has room for another sound value
    Audio_Controller audio (
        .CLOCK_50(CLOCK_50), .reset(reset), // clock + reset
        .clear_audio_in_memory(1'b0), .read_audio_in(1'b0), // no mic needed
        .clear_audio_out_memory(1'b0), // never clear
        .left_channel_audio_out(sample), .right_channel_audio_out(sample), //output same sound in both speakers
        .write_audio_out(audio_out_allowed), // write sound value when allowed
        .AUD_ADCDAT(AUD_ADCDAT), .AUD_BCLK(AUD_BCLK), // audio chip wires
        .AUD_ADCLRCK(AUD_ADCLRCK), .AUD_DACLRCK(AUD_DACLRCK), // audio chip wires
        .audio_in_available(), .left_channel_audio_in(), .right_channel_audio_in(), // mic outputs not needed
        .audio_out_allowed(audio_out_allowed), // out: 1 = room for another sound value
        .AUD_XCK(AUD_XCK), .AUD_DACDAT(AUD_DACDAT) // audio chip wires
    );

    // Audio chip setup, turns the audio chip on at start (Provided by Course)
    avconf #(.USE_MIC_INPUT(1)) avc (
        .FPGA_I2C_SCLK(FPGA_I2C_SCLK), .FPGA_I2C_SDAT(FPGA_I2C_SDAT), // setup wires to audio chip
        .CLOCK_50(CLOCK_50), .reset(reset) // clock + reset
    );

    // Screen: 2 groups of 4 keys (ASDF, HJKL), held key turns green (Kavin)
    kavin_milestone1 kavin (
        .CLOCK_50(CLOCK_50), .reset(reset), // clock + reset
        .start(1'b0), .finish_record(1'b0), // game controls, not used in milestone 1
        .sequence_nonempty(1'b0), .replay_done(1'b0), .match_done(1'b0), // not used in milestone 1
        .note_id(note_id), .active_player(player), .note_active(note_on), // which key, which player, held
        .game_state(), .record_enable(), .replay_enable(), .match_enable(), // not used in milestone 1
        .VGA_R(VGA_R), .VGA_G(VGA_G), .VGA_B(VGA_B), // monitor colour
        .VGA_CLK(VGA_CLK), .VGA_HS(VGA_HS), .VGA_VS(VGA_VS), // monitor timing
        .VGA_BLANK_N(VGA_BLANK_N), .VGA_SYNC_N(VGA_SYNC_N) // monitor timing
    );

    // LEDs used to test without a monitor
    assign LEDR[0] = note_on && note_id == 0; // A or H held
    assign LEDR[1] = note_on && note_id == 1; // S or J held
    assign LEDR[2] = note_on && note_id == 2; // D or K held
    assign LEDR[3] = note_on && note_id == 3; // F or L held
    assign LEDR[8:4] = 0; // off
    assign LEDR[9] = player; //0=player 1, 1 = player 2
endmodule
