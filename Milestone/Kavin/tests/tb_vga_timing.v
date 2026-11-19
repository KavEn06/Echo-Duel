`timescale 1ns/1ps
module tb_vga_timing;
reg clk=0; always #5 clk=~clk;
reg reset=1;
wire pixel_clk,active_video,hsync_n,vsync_n;
wire [9:0] x,y;
integer pixels=0,active_count=0,h_low=0,v_low=0;
vga_timing dut(clk,reset,pixel_clk,x,y,active_video,hsync_n,vsync_n);
initial begin
 repeat(3) @(negedge clk); reset=0;
 // Sample a complete frame in the monitor's pixel-clock domain.
 repeat(420000) begin
  @(posedge pixel_clk); #1;
  if(x !== pixels%800 || y !== pixels/800) $fatal(1,"coordinate mismatch at %d: %d,%d",pixels,x,y);
  if(active_video !== (x<640 && y<480)) $fatal(1,"blanking mismatch");
  if(hsync_n !== !(x>=656 && x<752)) $fatal(1,"horizontal sync mismatch");
  if(vsync_n !== !(y>=490 && y<492)) $fatal(1,"vertical sync mismatch");
  if(active_video) active_count=active_count+1;
  if(!hsync_n) h_low=h_low+1;
  if(!vsync_n) v_low=v_low+1;
  pixels=pixels+1;
 end
 if(active_count!=307200 || h_low!=50400 || v_low!=1600) $fatal(1,"wrong frame totals");
 @(posedge pixel_clk); #1;
 if(x!=0 || y!=0) $fatal(1,"frame did not wrap");
 reset=1; @(posedge clk); #1;
 if(x!=0 || y!=0 || pixel_clk!=0) $fatal(1,"reset failed");
 $display("PASS VGA timing: full frame and sync widths"); $finish;
end
initial begin #10000000; $fatal(1,"timeout"); end
endmodule
