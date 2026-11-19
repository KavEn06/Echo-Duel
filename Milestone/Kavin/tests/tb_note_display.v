`timescale 1ns/1ps
module tb_note_display;
reg [9:0] x=0,y=0; reg active_video=1;
reg [2:0] state=0,note_id=0; reg note_active=0;
wire [7:0] red,green,blue;
integer i;
note_display dut(x,y,active_video,state,note_id,note_active,red,green,blue);
initial begin
 // Eight note IDs must highlight eight distinct keys.
 for(i=0;i<8;i=i+1) begin
  note_id=i; note_active=1; x=92+64*i; y=330; #1;
  if({red,green,blue}!==24'h30d070) $fatal(1,"note %d not highlighted",i);
  note_active=0; #1;
  if({red,green,blue}!==24'he8e8e8) $fatal(1,"released note stays highlighted");
 end
 note_active=1; note_id=0; x=156; #1;
 if({red,green,blue}!==24'he8e8e8) $fatal(1,"wrong key highlighted");
 x=123; #1; if({red,green,blue}!==24'h101820) $fatal(1,"key gap missing");
 x=20; y=30; state=1; #1;
 if({red,green,blue}!==24'hd05040) $fatal(1,"record phase indicator missing");
 active_video=0; #1;
 if({red,green,blue}!==0) $fatal(1,"RGB must be black outside visible area");
 $display("PASS note display"); $finish;
end
endmodule
