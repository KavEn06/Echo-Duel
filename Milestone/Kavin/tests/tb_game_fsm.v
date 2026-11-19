`timescale 1ns/1ps
module tb_game_fsm;
reg clk=0; always #5 clk=~clk;
reg reset=1, start=0, finish_record=0, sequence_nonempty=0, replay_done=0, match_done=0;
wire [2:0] state; wire record_enable,replay_enable,match_enable;
game_fsm dut(clk,reset,start,finish_record,sequence_nonempty,replay_done,match_done,state,record_enable,replay_enable,match_enable);
task tick; begin @(posedge clk); #1; end endtask
task check; input [2:0] expected; begin
 if(state!==expected) $fatal(1,"state %d expected %d",state,expected);
 if({record_enable,replay_enable,match_enable} !== {expected==1,expected==2,expected==3}) $fatal(1,"wrong enables");
end endtask
initial begin
 tick; check(0); reset=0; tick; check(0);
 start=1; tick; start=0; check(1);
 finish_record=1; tick; check(1); // Empty sequences must stay in RECORD.
 sequence_nonempty=1; tick; finish_record=0; check(2);
 tick; check(2); replay_done=1; tick; replay_done=0; check(3);
 tick; check(3); match_done=1; tick; match_done=0; check(4);
 start=1; tick; start=0; check(1);
 reset=1; tick; check(0);
 $display("PASS game FSM"); $finish;
end
initial begin #10000; $fatal(1,"timeout"); end
endmodule
