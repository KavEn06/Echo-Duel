# Run from Integration/ModelSim:  do echo_duel_m1.do
# Uses simple stand-ins for the course PS/2 + audio and Kavin's RAM/PLL models,
# so no Intel libraries are needed. Takes a few seconds (about 3 ms simulated).
vlib work
vlog ../echo_duel_m1.v "../../Milestone 1/Saajan/note_decoder.v" "../../Milestone 1/Saajan/tone_gen.v" \
     "../../Milestone 1/Kavin/game_fsm.v" "../../Milestone 1/Kavin/frame_writer.v" "../../Milestone 1/Kavin/kavin_milestone1.v" \
     "../../Milestone 1/Kavin/vga_adapter/vga_adapter.v" "../../Milestone 1/Kavin/vga_adapter/vga_address_translator.v" \
     "../../Milestone 1/Kavin/vga_adapter/vga_controller.v" \
     "../../Milestone 1/Kavin/tests/sim/vga_pll.v" "../../Milestone 1/Kavin/tests/sim/altsyncram.v" \
     ../tests/sim/course_stubs.v ../tests/tb_echo_duel_m1.v
vsim tb_echo_duel_m1
add wave -radix hex      /tb_echo_duel_m1/dut/ps2_byte
add wave                 /tb_echo_duel_m1/dut/ps2_byte_en
add wave -radix unsigned /tb_echo_duel_m1/dut/note_id
add wave                 /tb_echo_duel_m1/dut/player
add wave                 /tb_echo_duel_m1/dut/note_on
add wave                 /tb_echo_duel_m1/dut/audio_out_allowed
add wave -radix decimal -format analog-step -height 80 -min -10000000 -max 10000000 /tb_echo_duel_m1/dut/sample
add wave -radix binary   /tb_echo_duel_m1/LEDR
run -all
wave zoom full
