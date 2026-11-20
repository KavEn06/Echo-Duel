# Run from the ModelSim folder:  do tone_gen.do
vlib work
vlog ../tone_gen.v ../tests/tb_tone_gen.v
vsim tb_tone_gen
configure wave -signalnamewidth 1
add wave                 /tb_tone_gen/note_on
add wave -radix unsigned /tb_tone_gen/note_id
add wave                 /tb_tone_gen/high
add wave -radix decimal -format analog-step -height 80 -min -10000000 -max 10000000 /tb_tone_gen/sample
run -all
wave zoom full
