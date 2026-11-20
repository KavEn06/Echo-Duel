# Run from the ModelSim folder:  do note_decoder.do
vlib work
vlog ../note_decoder.v ../tests/tb_note_decoder.v
vsim tb_note_decoder
add wave -radix hex      /tb_note_decoder/ps2_byte
add wave                 /tb_note_decoder/ps2_byte_en
add wave -radix unsigned /tb_note_decoder/note_id
add wave                 /tb_note_decoder/player
add wave                 /tb_note_decoder/note_on
add wave                 /tb_note_decoder/dut/got_f0
run -all
wave zoom full
