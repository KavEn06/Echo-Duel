`timescale 1ns/1ps
module tb_frame_writer;
reg clk=0; always #10 clk=~clk;
reg reset=1; reg [2:0] state=1,note_id=0; reg note_active=1;
wire [7:0] x; wire [6:0] y; wire [8:0] color; wire write;
integer sweep,pixel;
frame_writer dut(clk,reset,state,note_id,note_active,x,y,color,write);
initial begin
 repeat(2) @(negedge clk); reset=0;
 for(sweep=0;sweep<3;sweep=sweep+1) begin
  wait(write); // Each sweep must cover every pixel exactly once.
  for(pixel=0;pixel<19200;pixel=pixel+1) begin
   @(negedge clk);
   if(!write || x!==pixel%160 || y!==pixel/160) $fatal(1,"bad framebuffer write at %d",pixel);
   if(pixel==160*82+23) begin
    if(sweep<2 && color!==9'b001110011) $fatal(1,"first note highlight missing");
    if(sweep==2 && color!==9'b111111111) $fatal(1,"old highlight was not erased");
   end
   if(pixel==160*82+55 && sweep==2 && color!==9'b001110011) $fatal(1,"new note not highlighted");
   if(pixel==100 && sweep==1) note_id=2; // Must take effect next sweep, not mid-sweep.
  end
  @(negedge clk); if(write) $fatal(1,"sweep boundary missing");
 end
 reset=1; @(negedge clk); if(write) $fatal(1,"reset must disable writes");
 $display("PASS frame writer: coverage, coherent updates, highlight erase, reset"); $finish;
end
initial begin #3000000; $fatal(1,"timeout"); end
endmodule
