# Run from Milestone 1/Kavin/ModelSim with the ECF Intel simulation libraries mapped.
quit -sim
vlib work
vlog ../game_fsm.v ../frame_writer.v ../kavin_milestone1.v ../vga_adapter/*.v tb_waveform.v
# The adapter MIF path is relative to the simulator's working directory.
file mkdir MIF
file copy -force ../MIF/black_160_9.mif MIF/black_160_9.mif
vsim work.tb_waveform -Lf 220model -Lf altera_mf_ver -Lf verilog
add wave sim:/tb_waveform/clk sim:/tb_waveform/reset sim:/tb_waveform/note sim:/tb_waveform/active
add wave sim:/tb_waveform/state sim:/tb_waveform/dut/painter/*
add wave sim:/tb_waveform/vclk sim:/tb_waveform/hs sim:/tb_waveform/vs sim:/tb_waveform/blank_n
add wave sim:/tb_waveform/r sim:/tb_waveform/g sim:/tb_waveform/b
run -all
