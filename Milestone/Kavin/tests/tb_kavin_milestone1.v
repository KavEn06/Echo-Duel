`timescale 1ns/1ps
module tb_kavin_milestone1;
reg clk=0; always #10 clk=~clk; // Board clock: 50 MHz.
reg reset=1,start=0;
wire [2:0] state;
wire rec_en,replay_en,match_en;
wire [7:0] r,g,b;
wire vclk,hs,vs,blank_n,sync_n;
integer pixel;
kavin_milestone1 dut(
 .CLOCK_50(clk),.reset(reset),.start(start),.finish_record(1'b0),
 .sequence_nonempty(1'b0),.replay_done(1'b0),.match_done(1'b0),
 .note_id(3'd2),.note_active(1'b1),.game_state(state),
 .record_enable(rec_en),.replay_enable(replay_en),.match_enable(match_en),
 .VGA_R(r),.VGA_G(g),.VGA_B(b),.VGA_CLK(vclk),.VGA_HS(hs),
 .VGA_VS(vs),.VGA_BLANK_N(blank_n),.VGA_SYNC_N(sync_n));
initial begin
 repeat(3) @(negedge clk); reset=0; start=1;
 for(pixel=0;pixel<420000;pixel=pixel+1) begin
  @(posedge vclk); #1; start=0;
  if(state!==3'd1 || !rec_en || replay_en || match_en) $fatal(1,"FSM top wiring failed");
  if(sync_n!==0) $fatal(1,"wrong composite sync");
  if(pixel==24020 && {r,g,b}!==24'hd05040) $fatal(1,"record band missing"); // x20,y30
  if(pixel==264220 && {r,g,b}!==24'h30d070) $fatal(1,"note input not routed to VGA"); // E key
  if(pixel==264092 && {r,g,b}!==24'he8e8e8) $fatal(1,"other key should be white");
  if(pixel%800>=640 || pixel/800>=480) begin
   if(blank_n!==0 || {r,g,b}!==0) $fatal(1,"top blanking failed");
  end
 end
 $display("PASS integrated milestone top"); $finish;
end
initial begin #20000000; $fatal(1,"timeout"); end
endmodule
