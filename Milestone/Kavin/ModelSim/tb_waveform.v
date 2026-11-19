`timescale 1ns/1ps
// Waveform testbench for the actual Intel libraries on ECF.
module tb_waveform;
reg clk=0; always #10 clk=~clk;
reg reset=1,start=0,active=0;
reg [1:0] note=0;
reg player=0;
wire [2:0] state;
wire [7:0] r,g,b;
wire hs,vs,blank_n,sync_n,vclk;
kavin_milestone1 dut(
 .CLOCK_50(clk),.reset(reset),.start(start),.finish_record(1'b0),
 .sequence_nonempty(1'b0),.replay_done(1'b0),.match_done(1'b0),
 .note_id(note),.active_player(player),.note_active(active),.game_state(state),
 .record_enable(),.replay_enable(),.match_enable(),
 .VGA_R(r),.VGA_G(g),.VGA_B(b),.VGA_CLK(vclk),.VGA_HS(hs),
 .VGA_VS(vs),.VGA_BLANK_N(blank_n),.VGA_SYNC_N(sync_n));
initial begin
 #200; @(negedge clk); reset=0; start=1;
 @(negedge clk); start=0; active=1;
 #500000; @(negedge clk); note=2;
 #500000; @(negedge clk); player=1;
 #500000; @(negedge clk); active=0;
 #20000000; $finish;
end
endmodule
