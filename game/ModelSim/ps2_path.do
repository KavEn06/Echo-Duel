# Run from Integration/ModelSim:  do ps2_path.do
# Fake keyboard wires -> real course PS2_Controller -> note_decoder + tone_gen.
vlib work
vlog ../course_ps2/Altera_UP_PS2_Command_Out.v ../course_ps2/Altera_UP_PS2_Data_In.v ../course_ps2/PS2_Controller.v \
     "../../Milestone 1/Saajan/note_decoder.v" "../../Milestone 1/Saajan/tone_gen.v" ../tests/tb_ps2_path.v
vsim tb_ps2_path
add wave                 /tb_ps2_path/PS2_CLK
add wave                 /tb_ps2_path/PS2_DAT
add wave -radix hex      /tb_ps2_path/ps2_byte
add wave                 /tb_ps2_path/ps2_byte_en
add wave -radix unsigned /tb_ps2_path/note_id
add wave                 /tb_ps2_path/player
add wave                 /tb_ps2_path/note_on
add wave -radix decimal -format analog-step -height 80 -min -10000000 -max 10000000 /tb_ps2_path/audio_left
run -all
wave zoom full
