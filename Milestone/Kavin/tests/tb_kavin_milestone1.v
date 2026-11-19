`timescale 1ns/1ps
module tb_kavin_milestone1;
reg clk=0; always #10 clk=~clk;
reg reset=1,start=0,note_active=1,active_player=0;
wire [2:0] state;
wire rec_en,replay_en,match_en;
wire [7:0] r,g,b;
wire vclk,hs,vs,blank_n,sync_n;
integer pixel,h_low=0,v_low=0,visible=0,highlight=0;
kavin_milestone1 dut(
 .CLOCK_50(clk),.reset(reset),.start(start),.finish_record(1'b0),
 .sequence_nonempty(1'b0),.replay_done(1'b0),.match_done(1'b0),
 .note_id(2'd2),.active_player(active_player),.note_active(note_active),.game_state(state),
 .record_enable(rec_en),.replay_enable(replay_en),.match_enable(match_en),
 .VGA_R(r),.VGA_G(g),.VGA_B(b),.VGA_CLK(vclk),.VGA_HS(hs),
 .VGA_VS(vs),.VGA_BLANK_N(blank_n),.VGA_SYNC_N(sync_n));
initial begin
 repeat(4) @(negedge clk); reset=0; start=1;
 @(negedge clk); start=0;
 // Two painter sweeps are enough for the accepted RECORD state to reach RAM.
 repeat(40000) @(negedge clk);
 if(state!==3'd1 || !rec_en || replay_en || match_en) $fatal(1,"FSM top wiring failed");
 if(dut.VGA.VideoMemory.mem[13167]!==9'b001110011) $fatal(1,"highlight missing from adapter RAM"); // Player 1 D key (musical E), x47,y82
 if(dut.VGA.VideoMemory.mem[13247]!==9'b111111111) $fatal(1,"wrong key highlighted");
 if(dut.VGA.VideoMemory.mem[1125]!==9'b110010010) $fatal(1,"record phase missing from adapter RAM"); // y7,x5
 // Inspect the real course controller over one complete physical VGA period.
 repeat(3) @(posedge vclk);
 for(pixel=0;pixel<420000;pixel=pixel+1) begin
  @(posedge vclk); #1;
  if(sync_n!==1'b1) $fatal(1,"course sync output disconnected");
  if(hs===1'b0) h_low=h_low+1;
  if(vs===1'b0) v_low=v_low+1;
  if(blank_n===1'b1) begin
   visible=visible+1;
   if(g>r && g>b) highlight=highlight+1;
  end
 end
 if(h_low!=50400 || v_low!=1600 || visible!=307200) $fatal(1,"bad VGA frame/sync totals");
 if(highlight==0) $fatal(1,"framebuffer highlight never reached VGA RGB");
 // Moving to Player 2 must erase Player 1 and light the corresponding key.
 @(negedge clk); active_player=1;
 repeat(40000) @(negedge clk);
 if(dut.VGA.VideoMemory.mem[13167]!==9'b111111111) $fatal(1,"old player highlight not erased");
 if(dut.VGA.VideoMemory.mem[13247]!==9'b001110011) $fatal(1,"Player 2 K highlight missing");
 @(negedge clk); note_active=0;
 repeat(40000) @(negedge clk);
 if(dut.VGA.VideoMemory.mem[13247]!==9'b111111111) $fatal(1,"released key not erased");
 $display("PASS course-adapter integration: RAM writes, VGA frame, RGB highlight and release"); $finish;
end
initial begin #25000000; $fatal(1,"timeout"); end
endmodule
