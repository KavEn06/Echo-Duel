`timescale 1ns/1ps
// SIMULATION-ONLY stand-ins for the course PS/2, audio and avconf modules.
// They have the same ports as the real files so the board top can be tested
// with Icarus. Quartus uses the real course files instead; never add these to Quartus.

// PS/2: the testbench calls ps2.send(byte) to fake one received byte.
module PS2_Controller (
    input wire CLOCK_50, reset,
    input wire [7:0] the_command,
    input wire send_command,
    inout wire PS2_CLK, PS2_DAT,
    output wire command_was_sent, error_communication_timed_out,
    output reg [7:0] received_data,
    output reg received_data_en
);
    assign command_was_sent = 0;
    assign error_communication_timed_out = 0;
    initial begin received_data = 0; received_data_en = 0; end
    task send; input [7:0] b; begin
        @(negedge CLOCK_50) begin received_data = b; received_data_en = 1; end
        @(negedge CLOCK_50) received_data_en = 0;
    end endtask
endmodule

// Audio: allows one write every 20 clocks and remembers the last written value.
module Audio_Controller (
    input wire CLOCK_50, reset,
    input wire clear_audio_in_memory, read_audio_in, clear_audio_out_memory,
    input wire [31:0] left_channel_audio_out, right_channel_audio_out,
    input wire write_audio_out,
    input wire AUD_ADCDAT,
    inout wire AUD_BCLK, AUD_ADCLRCK, AUD_DACLRCK,
    output wire audio_in_available,
    output wire [31:0] left_channel_audio_in, right_channel_audio_in,
    output reg audio_out_allowed,
    output wire AUD_XCK, AUD_DACDAT
);
    assign audio_in_available = 0;
    assign left_channel_audio_in = 0;
    assign right_channel_audio_in = 0;
    assign AUD_XCK = 0;
    assign AUD_DACDAT = 0;
    integer tick = 0, loud_writes = 0;
    always @(posedge CLOCK_50) begin
        tick <= (tick == 19) ? 0 : tick + 1;
        audio_out_allowed <= (tick == 0);
        if (write_audio_out && audio_out_allowed && left_channel_audio_out != 0)
            loud_writes = loud_writes + 1;
    end
endmodule

module avconf #(parameter USE_MIC_INPUT = 0) (
    output wire FPGA_I2C_SCLK,
    inout wire FPGA_I2C_SDAT,
    input wire CLOCK_50, reset
);
    assign FPGA_I2C_SCLK = 1;
endmodule
