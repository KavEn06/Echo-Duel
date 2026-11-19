`timescale 1ns/1ps
module tb_frame_writer;
reg clk=0; always #10 clk=~clk;
reg reset=1;
reg [2:0] state=1;
reg [1:0] note_id=0;
reg active_player=0,note_active=1;
wire [7:0] x; wire [6:0] y; wire [8:0] color; wire write;
integer sweep,pixel,player,note,group,key,left;
frame_writer dut(
 .clk(clk),.reset(reset),.state(state),.note_id(note_id),
 .active_player(active_player),.note_active(note_active),
 .x(x),.y(y),.color(color),.write(write));
task draw_sweep;
 input integer expected_player,expected_note;
 input expected_active;
 begin
  wait(write);
  for(pixel=0;pixel<19200;pixel=pixel+1) begin
   @(negedge clk);
   if(!write || x!==pixel%160 || y!==pixel/160) $fatal(1,"bad framebuffer write at %d",pixel);
   if(y==82) begin
    for(group=0;group<2;group=group+1) begin
     for(key=0;key<4;key=key+1) begin
      left=8+80*group+16*key;
      if(x==left || x==left+13) begin
       if(expected_active && group==expected_player && key==expected_note) begin
        if(color!==9'b001110011) $fatal(1,"selected player's key not highlighted");
       end else if(color!==9'b111111111) $fatal(1,"wrong player/note highlighted");
      end
      if(x==left+14 && color!==9'b000000001) $fatal(1,"key gap missing");
     end
    end
    if(x>=72 && x<88 && color!==9'b000000001) $fatal(1,"player groups need a gap");
   end
   // A (left group) and H (right group) have different top-row strokes.
   if(y==104 && x==14 && color!==9'b111111111) $fatal(1,"A label missing");
   if(y==104 && x==13 && color!==9'b000000001) $fatal(1,"A label wrong shape");
   if(y==104 && x==93 && color!==9'b111111111) $fatal(1,"H label missing");
   // Change player and note mid-sweep; the old scene must remain coherent.
   if(sweep==0 && pixel==100) begin active_player=1; note_id=2; end
  end
  @(negedge clk); if(write) $fatal(1,"sweep boundary missing");
 end
endtask
initial begin
 repeat(2) @(negedge clk); reset=0;
 sweep=0; draw_sweep(0,0,1);
 sweep=1; draw_sweep(1,2,1);
 for(player=0;player<2;player=player+1) begin
  for(note=0;note<4;note=note+1) begin
   active_player=player; note_id=note; note_active=1;
   draw_sweep(player,note,1);
  end
 end
 note_active=0; draw_sweep(1,3,0);
 reset=1; @(negedge clk); if(write) $fatal(1,"reset must disable writes");
 $display("PASS frame writer: two players, four notes each, labels, coherent updates and release"); $finish;
end
initial begin #6000000; $fatal(1,"timeout"); end
endmodule
